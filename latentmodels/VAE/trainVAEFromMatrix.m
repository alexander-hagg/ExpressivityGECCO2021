function vae = trainVAEFromMatrix(vae,data,numEpochs,maxBatchSize)
%TRAINVAE Summary of this function goes here
%   Detailed explanation goes here

encoderNet = dlnetwork(vae.encoderLG);
decoderNet = dlnetwork(vae.decoderLG);

executionEnvironment = "gpu"; %auto cpu gpu

numTrainImages = size(data.train,3);

miniBatchSize = min(maxBatchSize,numTrainImages);
numIterations = floor(numTrainImages/miniBatchSize);

numTestImages = size(data.test,3);

miniBatchSizeTest = min(maxBatchSize,numTestImages);
numIterationsTest = floor(numTestImages/miniBatchSize);


iteration = 0;

%lr = 1e-3;
lr = 5e-4;

avgGradientsEncoder = [];
avgGradientsSquaredEncoder = [];
avgGradientsDecoder = [];
avgGradientsSquaredDecoder = [];


for epoch = 1:numEpochs
    tic;
    for i = 1:numIterations
        disp(['Batch ' int2str(i) '/' int2str(numIterations)]);
        iteration = iteration + 1;
        
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        XBatch = data.train(:,:,idx);
        test(1,:,:,:) = XBatch;
        XBatch = permute(test,[2 3 1 4]);
        XBatch = dlarray(single(XBatch), 'SSCB');
        
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
            XBatch = gpuArray(XBatch);
        end
        
        [infGrad, genGrad] = dlfeval(...
            @modelGradients, encoderNet, decoderNet, XBatch, epoch, numEpochs);
        
        [decoderNet.Learnables, avgGradientsDecoder, avgGradientsSquaredDecoder] = ...
            adamupdate(decoderNet.Learnables, ...
            genGrad, avgGradientsDecoder, avgGradientsSquaredDecoder, iteration, lr);
        [encoderNet.Learnables, avgGradientsEncoder, avgGradientsSquaredEncoder] = ...
            adamupdate(encoderNet.Learnables, ...
            infGrad, avgGradientsEncoder, avgGradientsSquaredEncoder, iteration, lr);
    end
    elapsedTime = toc;
    
    % Batch sample test data
    iteration = 0;
    elbo = []; reconstructionLoss = []; KL = [];
    for i = 1:numIterationsTest
        iteration = iteration + 1;
        
        idx = (i-1)*miniBatchSizeTest+1:i*miniBatchSizeTest;
        XTest = data.test(:,:,idx);
        clear test; test(1,:,:,:) = XTest;
        XTest = permute(test,[2 3 1 4]);
        XTest = dlarray(single(XTest), 'SSCB');
        
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
            XTest = gpuArray(XTest);
        end
        
        [z, zMean, zLogvar] = sampling(encoderNet, XTest);
        xPred = sigmoid(forward(decoderNet, z));
        [elbo_t,reconstructionLoss_t,KL_t] = ELBOloss(XTest, xPred, zMean, zLogvar, epoch, numEpochs);
        elbo(i) = gather(extractdata(elbo_t));
        reconstructionLoss(i) = gather(extractdata(reconstructionLoss_t));
        KL(i) = gather(extractdata(KL_t));
    end
    
    disp("Epoch : " + epoch + ...
        " Test ELBO loss = "+mean(elbo)+ ...
        " Test reconstruction loss = "+mean(reconstructionLoss)+ ...
        " Test KL loss = "+mean(KL)+ ...
        ". Time taken for epoch = "+ elapsedTime + "s")
    vae.losses(epoch) = mean(elbo);
end

vae.encoderNet = encoderNet;
vae.decoderNet = decoderNet;

end

