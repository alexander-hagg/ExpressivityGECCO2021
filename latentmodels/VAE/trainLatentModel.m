function model = trainLatentModel(model,data,numEpochs,maxBatchSize,learnRate,waitingPeriod)
%TRAINVAE Summary of this function goes here
%   Detailed explanation goes here

minValLoss = 10^10;
minValLossEpoch = 1;

encoderNet = dlnetwork(model.encoderLG);
decoderNet = dlnetwork(model.decoderLG);

executionEnvironment = "auto"; %auto cpu gpu

numTrainImages = data.trainStore.NumObservations;

miniBatchSize = min(maxBatchSize,numTrainImages);
data.trainStore.MiniBatchSize = miniBatchSize;

iteration = 0;

avgGradientsEncoder = [];
avgGradientsSquaredEncoder = [];
avgGradientsDecoder = [];
avgGradientsSquaredDecoder = [];


for epoch = 1:numEpochs
    tic;
    % Reset and shuffle datastore.
    reset(data.trainStore);
    data.trainStore = shuffle(data.trainStore);
    while hasdata(data.trainStore)
        iteration = iteration + 1;
        
        % Read mini-batch of data.
        batchDataTable = read(data.trainStore);
        
        % Ignore last partial mini-batch of epoch.
        if size(batchDataTable,1) < miniBatchSize
            continue
        end
        
        XBatch = cat(4,batchDataTable.input{:,1});
        XBatch = dlarray(single(XBatch), 'SSCB');
        
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
            XBatch = gpuArray(XBatch);
        end
        
        [infGrad, genGrad] = dlfeval(...
            @modelGradients, encoderNet, decoderNet, XBatch, epoch, numEpochs);
        
        [decoderNet.Learnables, avgGradientsDecoder, avgGradientsSquaredDecoder] = ...
            adamupdate(decoderNet.Learnables, genGrad, avgGradientsDecoder, avgGradientsSquaredDecoder, iteration, learnRate);
        [encoderNet.Learnables, avgGradientsEncoder, avgGradientsSquaredEncoder] = ...
            adamupdate(encoderNet.Learnables, infGrad, avgGradientsEncoder, avgGradientsSquaredEncoder, iteration, learnRate);
    end
    elapsedTime = toc;
    
    % Get training and validation loss
    %if epoch>waitingPeriod && mod(epoch,10)==0
    if mod(epoch,1)==0
        
        % If we are testing at all
        if ~strcmp(data.testStore,'emptyStore')
            clear loss reconstructionLoss regTerm;
            it=1;
            data.testStore.reset;
            while hasdata(data.testStore)
                % Read mini-batch of data.
                batchDataTable = read(data.testStore);
                
                XBatch = cat(4,batchDataTable.input{:,1});
                XBatch = dlarray(single(XBatch), 'SSCB');
                
                if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
                    XBatch = gpuArray(XBatch);
                end
                
                
                [z, zMean, zLogvar] = sampling(encoderNet, XBatch);
                xPred = sigmoid(forward(decoderNet, z));
                [loss(it),reconstructionLoss(it),regTerm(it)] = ELBOloss(XBatch, xPred, zMean, zLogvar, z, epoch, numEpochs);
                it = it + 1;
                
            end
            
            model.statistics.loss(epoch) = mean(gather(extractdata(loss)));
            model.statistics.reconstructionLoss(epoch) = mean(gather(extractdata(reconstructionLoss)));
            model.statistics.regTerm(epoch) = mean(gather(extractdata(regTerm)));
            if model.statistics.loss(epoch) < minValLoss
                bestEncoder = encoderNet;
                bestDecoder = decoderNet;
                minValLoss = model.statistics.loss(epoch);
                minRecoLoss= model.statistics.reconstructionLoss(epoch);
                minReguLoss = model.statistics.regTerm(epoch);
                minValLossEpoch = epoch;
            end
        end
        if epoch==1 || mod(epoch,50)==0
            disp('>>>>>>>>>>>>>>>')
            disp(['>>>       Min. validation loss found: ' num2str(minValLoss)]);
            disp(['>>>       Best model was saved at epoch ' int2str(minValLossEpoch)]);
            disp('>>>>>>>>>>>>>>>')
            
            
            disp("Epoch : " + epoch + ...
                " Mean Validation loss = "+ model.statistics.loss(epoch) + ...
                " Mean Validation reconstruction loss = "+ model.statistics.reconstructionLoss(epoch) + ...
                " Mean Validation regularization term = "+ model.statistics.regTerm(epoch) + ...
                ". Time taken for epoch = "+ elapsedTime + "s");
            clear loss reconstructionLoss regTerm;
            it=1;
            data.trainStore.reset;
            while hasdata(data.trainStore)
                % Read mini-batch of data.
                batchDataTable = read(data.trainStore);
                
                % Ignore last partial mini-batch of epoch.
                %if size(batchDataTable,1) < miniBatchSize
                %    continue
                %end
                
                XBatch = cat(4,batchDataTable.input{:,1});
                XBatch = dlarray(single(XBatch), 'SSCB');
                
                if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
                    XBatch = gpuArray(XBatch);
                end
                
                
                [z, zMean, zLogvar] = sampling(encoderNet, XBatch);
                xPred = sigmoid(forward(decoderNet, z));
                [loss(it),reconstructionLoss(it),regTerm(it)] = ELBOloss(XBatch, xPred, zMean, zLogvar, z, epoch, numEpochs);
                it = it + 1;
            end
            
            model.statistics.training.loss(epoch) = mean(gather(extractdata(loss)));
            model.statistics.training.reconstructionLoss(epoch) = mean(gather(extractdata(reconstructionLoss)));
            model.statistics.training.regTerm(epoch) = mean(gather(extractdata(regTerm)));
            
            disp("Epoch : " + epoch + ...
                " Mean Training loss = "+ model.statistics.training.loss(epoch) + ...
                " Mean Training reconstruction loss = "+ model.statistics.training.reconstructionLoss(epoch) + ...
                " Mean Training regularization term = "+ model.statistics.training.regTerm(epoch) + ...
                ". Time taken for epoch = "+ elapsedTime + "s")
            disp(".........................................");
        end
    end
end

model.statistics.minValLoss = minValLoss;
model.statistics.minRecoLoss = minRecoLoss;
model.statistics.minReguLoss = minReguLoss;
model.statistics.minValLossEpoch = minValLossEpoch;
                
model.encoderNet = bestEncoder;
model.decoderNet = bestDecoder;

% Normalize latent space
if ~strcmp(data.testStore,'emptyStore')
    allData = [readall(data.trainStore); readall(data.testStore)];
else
    allData = readall(data.trainStore);
end

model.latent = getLatent(allData{:,1},model);

%if size(model.latent,1) > 2
%    [coeff, score, latent, tsquared, explained] = pca(model.latent');
%    model.latent = score(:,1:2);
%    model.pcaCoeff = coeff(:,1:2);
%else
%    model.latent = model.latent';
%end

%model.latent = model.latent';

%[model.latent,model.normalization] = mapminmax(model.latent',0,1);
%model.latent = model.latent';



end

