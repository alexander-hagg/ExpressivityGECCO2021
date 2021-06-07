clear;
%% Configuration
addpath(genpath(pwd))                           % Set path to all modules
DOF = 16;                                       % Degrees of freedom, Catmull-Rom spline domain
d = domain(DOF);                                % Domain configuration
fileName = ['catmullRom_Id_dof_8'];

load([fileName]);

pxThreshold = 0.9;

%% Visualize base shapes
fig(1) = figure(1);
showPhenotypeBMP(flipud(shapeParams),d,fig(1));

%% Visualize shape sets
% Set positions of shapes
for shapeID=1:size(shapeParams,1)
    
    for i=1:4
        % Adjust placement to missing shapes
        fig(end+1) = figure; hold off;
        showPhenotypeBMP(allGenomes{shapeID,i},d,fig(end),selectedShapes{i}*d.resolution);axis equal;
    end
end

%% Visualize losses
clear losses reconstructionLosses regTerms
for rep=1:length(latentDOFs)
    
    for shapeID=1:size(shapeParams,1)
        for i=1:4
            losses(rep,shapeID,i,:) = [allModels{rep,shapeID,i}.statistics.loss(1) allModels{rep,shapeID,i}.statistics.loss(50:50:end)];
            reconstructionLosses(rep,shapeID,i,:) = [allModels{rep,shapeID,i}.statistics.reconstructionLoss(1) allModels{rep,shapeID,i}.statistics.reconstructionLoss(50:50:end)];
            regTerms(rep,shapeID,i,:) = [allModels{rep,shapeID,i}.statistics.regTerm(1) allModels{rep,shapeID,i}.statistics.regTerm(50:50:end)];
        end
    end
end
%%
fig(99) = figure(99);
subplot(3,2,1);hold off;
semilogy(prctile(reshape(reconstructionLosses(1,:,:,:),20,size(reconstructionLosses,4)),90));
hold on;
semilogy(squeeze(median(reconstructionLosses(1,:,:,:),[1 2 3])));
semilogy(prctile(reshape(reconstructionLosses(1,:,:,:),20,size(reconstructionLosses,4)),10));
ax = gca;ax.XTickLabel = ax.XTick*50;ylabel('Reconstruction Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^1 10^4];

subplot(3,2,2);hold off;
semilogy(prctile(reshape(reconstructionLosses(2,:,:,:),20,size(reconstructionLosses,4)),90));
hold on;
semilogy(squeeze(median(reconstructionLosses(2,:,:,:),[1 2 3])));
semilogy(prctile(reshape(reconstructionLosses(2,:,:,:),20,size(reconstructionLosses,4)),10));
ax = gca;ax.XTickLabel = ax.XTick*50;ylabel('Reconstruction Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^1 10^4];

subplot(3,2,3);hold off;
semilogy(prctile(reshape(regTerms(1,:,:,:),20,size(reconstructionLosses,4)),90));
hold on;
semilogy(squeeze(median(regTerms(1,:,:,:),[1 2 3])));
semilogy(prctile(reshape(regTerms(1,:,:,:),20,size(reconstructionLosses,4)),10));
ax = gca;ax.XTickLabel = ax.XTick*50;ylabel('KL Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^0 10^2];

subplot(3,2,4);hold off;
semilogy(prctile(reshape(regTerms(2,:,:,:),20,size(reconstructionLosses,4)),90));
hold on;
semilogy(squeeze(median(regTerms(2,:,:,:),[1 2 3])));
semilogy(prctile(reshape(regTerms(2,:,:,:),20,size(reconstructionLosses,4)),10));
ax = gca;ax.XTickLabel = ax.XTick*50;ylabel('KL Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^0 10^2];
%

subplot(3,2,5);hold off;
semilogy(prctile(reshape(losses(1,:,:,:),20,size(reconstructionLosses,4)),90));
hold on;
semilogy(squeeze(median(losses(1,:,:,:),[1 2 3])));
semilogy(prctile(reshape(losses(1,:,:,:),20,size(reconstructionLosses,4)),10));
ax = gca;ax.XTickLabel = ax.XTick*50;ylabel('Total \beta-Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^1 10^4];

subplot(3,2,6);hold off;
semilogy(prctile(reshape(losses(2,:,:,:),20,size(reconstructionLosses,4)),90));
hold on;
semilogy(squeeze(median(losses(2,:,:,:),[1 2 3])));
semilogy(prctile(reshape(losses(2,:,:,:),20,size(reconstructionLosses,4)),10));
ax = gca;ax.XTickLabel = ax.XTick*50;ylabel('Total \beta-Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^1 10^4];

save_figures(fig, '.', 'IDNODNI-II_losses', 12, [5 5])


%% Analysis: sample all models
% Get samples and training/missing shapes' reconstruction and latent
% coordinates (features)
for rep=1:length(latentDOFs)
    
    for shapeID=1:size(shapeParams,1)
        disp([int2str(shapeID) '/' int2str(size(shapeParams,1))]);
        for i=1:4
            % Get predicted features for *all* shapes, incl. the ones missing from
            % training data for particular model.
            features{rep,shapeID,i} = getPrediction(phenotypes{shapeID,1},allModels{rep,shapeID,i});
            
            % Create latent samples
            minFeatures = min(features{rep,shapeID,i}(:)); maxFeatures = max(features{rep,shapeID,i}(:));
            nSamples = 10;
            x = minFeatures:(maxFeatures-minFeatures)/(nSamples-1):maxFeatures; y = x; [X,Y] = ndgrid(x,y);
            varyCoords = [X(:),Y(:),ones(100,latentDOFs(rep)-2)]';
            input = []; input(1,1,:,:) = varyCoords; input = dlarray(input,'SSCB');
            genImgSample{rep,shapeID,i} = sigmoid(predict(allModels{rep,shapeID,i}.decoderNet, input));
            genImgSample{rep,shapeID,i} = gather(extractdata(genImgSample{rep,shapeID,i}));
            
            % Place collected VAE outputs in latent space, normalized for
            % visualization and comparison
            [normVaryCoords{rep,shapeID,i},mapping{rep,shapeID,i}] = mapminmax(varyCoords,-nSamples,nSamples);
            bitmapCoords{rep,shapeID,i} = 1 + (ceil(d.resolution*normVaryCoords{rep,shapeID,i})-min(ceil(d.resolution*normVaryCoords{rep,shapeID,i}(:))));
            
            % Get reproduced shapes from training data (remove deselected)
            subSelected = sub2ind([numShapes numShapes],selectedShapes{i}(:,1),selectedShapes{i}(:,2));
            input = []; input(1,1,:,:) = features{rep,shapeID,i}(subSelected,:)';
            input = dlarray(input,'SSCB');
            genImgTrain{rep,shapeID,i} = sigmoid(predict(allModels{rep,shapeID,i}.decoderNet, input));
            genImgTrain{rep,shapeID,i} = gather(extractdata(genImgTrain{rep,shapeID,i}));    %reproduced
            
            % Get reproduced shapes from missing training data (only deselected)
            subdeselected=1:numShapes*numShapes; subdeselected(subSelected) = [];
            input = []; input(1,1,:,:) = features{rep,shapeID,i}'; input = input(:,:,:,subdeselected); input = dlarray(input,'SSCB');
            if ~isempty(input)
                genImgMissing{rep,shapeID,i} = sigmoid(predict(allModels{rep,shapeID,i}.decoderNet, input));
                genImgMissing{rep,shapeID,i} = gather(extractdata(genImgMissing{rep,shapeID,i}));    %reproduced
            else
                genImgMissing{rep,shapeID,i} = [];
            end
        end
    end
end



%% RQI Analysis: calculate reconstruction errors of missing shapes (relative hamming error)
clear hamming relHammingError meanHammingError    l0dot1error rell0dot1error meanl0dot1error
for rep=1:length(latentDOFs)
    
    for shapeID=1:size(shapeParams,1)
        for i=1:4
            % Reconstruction error training data
            for jj=1:length(phenotypes{shapeID,i})
                originalPhen = phenotypes{shapeID,i}{jj};
                reconstructedPhen = genImgTrain{rep,shapeID,i}(:,:,1,jj);
                hamming{rep,shapeID,i,1}(jj) = sum(xor(originalPhen(:),(reconstructedPhen(:)>pxThreshold)));
                l0dot1error{rep,shapeID,i,1}(jj) = pdist2(originalPhen(:)',reconstructedPhen(:)','minkowski',0.1);
            end
            relHammingError{rep,shapeID,i,1} = hamming{rep,shapeID,i,1}/(64*64);
            meanHammingError(rep,shapeID,i,1) = mean(relHammingError{rep,shapeID,i,1});
            rell0dot1error{rep,shapeID,i,1} = l0dot1error{rep,shapeID,i,1}/(64*64);
            meanl0dot1error(rep,shapeID,i,1) = mean(l0dot1error{rep,shapeID,i,1});
            
            subSelected = sub2ind([numShapes numShapes],selectedShapes{i}(:,1),selectedShapes{i}(:,2));
            subdeselected=1:numShapes*numShapes; subdeselected(subSelected) = [];
            
            % Reconstruction error missing data
            missingphenotypes = phenotypes{shapeID,1};
            missingphenotypes = missingphenotypes(subdeselected);
            if ~isempty(subdeselected)
                for jj=1:length(missingphenotypes)
                    originalPhen = missingphenotypes{jj};
                    reconstructedPhen = genImgMissing{rep,shapeID,i}(:,:,1,jj)>pxThreshold;
                    %figure(1);subplot(2,1,1);imagesc(originalPhen);subplot(2,1,2);imagesc(reconstructedPhen);
                    hamming{rep,shapeID,i,2}(jj) = sum(xor(originalPhen(:),(reconstructedPhen(:))));
                    l0dot1error{rep,shapeID,i,2}(jj) = pdist2(originalPhen(:)',reconstructedPhen(:)','minkowski',0.1);
                end
                relHammingError{rep,shapeID,i,2} = hamming{rep,shapeID,i,2}/(64*64);
                meanHammingError(rep,shapeID,i,2) = mean(relHammingError{rep,shapeID,i,2});
                rell0dot1error{rep,shapeID,i,2} = l0dot1error{rep,shapeID,i,2}/(64*64);
                meanl0dot1error(rep,shapeID,i,2) = mean(l0dot1error{rep,shapeID,i,2});
                
            end
        end
    end
end

%% display mean reconstruction errors
for rep=1:length(latentDOFs)
    disp(['mu Rel. Hamming errors: ']); disp(squeeze(mean(meanHammingError(rep,:,:,:),2)));
    disp(['std Rel. Hamming errors: ']); disp(squeeze(std(meanHammingError(rep,:,:,:),[],2)));
    %disp(['mu Rel. L0.1 errors: ']); disp(squeeze(mean(meanl0dot1error(rep,:,:,:),2)));
    %disp(['std Rel. L0.1 errors: ']); disp(squeeze(std(meanl0dot1error(rep,:,:,:),[],2)));
end

%% display error boxplots
allErrors = reshape(relHammingError,[],4,2);
trainErrors = [];
trainBoxplotGroup = [];
for i=1:4
    trainErrors = [trainErrors; reshape(cell2mat(allErrors(:,i,1)),[],1)];
    trainErrors = [trainErrors; reshape(cell2mat(allErrors(:,i,2)),[],1)];
    trainBoxplotGroup = [trainBoxplotGroup; ones(size(reshape(cell2mat(allErrors(:,i,1)),[],1)))];
    trainBoxplotGroup = [trainBoxplotGroup; ((i-1)*2+2)*ones(size(reshape(cell2mat(allErrors(:,i,2)),[],1)))];
end


%% boxplots
fig(end+1) = figure;
boxplot(trainErrors,trainBoxplotGroup,'PlotStyle','compact','BoxStyle', 'filled');
% remove outleirs
h=findobj(gca,'tag','Outliers');
delete(h)
ax = gca;
ax.YAxis.Scale = 'log';
ax.XTick = [1 2 3 4 5 6 7];
ax.XTickLabel = {'Training', 'Recombination', 'Interpolation', 'Extrapolation'};
ax.XTickLabelRotation = 90;
grid on;
ylabel('Reconstruction Error');


%% RQII Analysis: calculate latent distance of missing shapes to all shapes
% best:
% worst:
%
nBins = 20;
BMIN = 0; BMAX = 5; YMAX = 0.4;
distances = []; distanceBoxplotGroup = [];
for rep=1:length(latentDOFs)
    for shapeID=1:size(shapeParams,1)
        
        % get distances between shapes in model A
        dd = reshape(pdist2(features{rep,shapeID,1},features{rep,shapeID,1}),1,[]);
        dd(dd==0) = []; % Leave out distances from elements to themselves
        avgDistance(rep,shapeID,1) = mean(dd(:));
        distances = [distances, reshape(dd,1,[])];
        distanceBoxplotGroup = [distanceBoxplotGroup, ones(1,numel(dd))];
        
        for i=2:4
            subSelected = sub2ind([numShapes numShapes],selectedShapes{i}(:,1),selectedShapes{i}(:,2));
            subdeselected=1:numShapes*numShapes; subdeselected(subSelected) = [];
            
            trainFeatures = features{rep,shapeID,i}(subSelected,:);% trainFeatures(deselectInd{i},:) = [];
            missingFeatures = features{rep,shapeID,i}(subdeselected,:);
            
            % Distance between training shapes in model B-D
            dd = pdist2(trainFeatures,trainFeatures);
            dd(dd==0) = []; % Leave out distances from elements to themselves
            avgDistance(rep,shapeID,2) = mean(dd(:));
        
            distances = [distances, reshape(dd,1,[])];
            distanceBoxplotGroup = [distanceBoxplotGroup, ones(1,numel(dd))];
            
            % Distance between training and missing shapes in model B-D
            dd = pdist2(missingFeatures,trainFeatures);
            dd(dd==0) = []; % Leave out distances from elements to themselves
            avgDistance(rep,shapeID,3) = mean(dd(:));
        
            distances = [distances, reshape(dd,1,[])];
            distanceBoxplotGroup = [distanceBoxplotGroup, i*ones(1,numel(dd))];
            
            % Distance between missing shapes in model B-D
            dd = pdist2(missingFeatures,missingFeatures);
            dd(dd==0) = []; % Leave out distances from elements to themselves
            avgDistance(rep,shapeID,4) = mean(dd(:));
        
            distances = [distances, reshape(dd,1,[])];
            distanceBoxplotGroup = [distanceBoxplotGroup, i*ones(1,numel(dd))];
            
        end
    end
end



%% boxplots
fig(end+1) = figure;
boxplot(distances,distanceBoxplotGroup,'PlotStyle','compact','BoxStyle', 'filled');
% remove outleirs
h=findobj(gca,'tag','Outliers');
delete(h)
ax = gca;
%ax.YAxis.Scale = 'log';
ax.XTick = [1 2 3 4 5 6 7];
ax.XTickLabel = {'Training', 'Recombination', 'Interpolation', 'Extrapolation'};
ax.XTickLabelRotation = 90;
grid on;
ylabel('Latent Distance');


%% Significance tests errors and distances
% 1 4 6 8

[~,p] = ttest2(trainErrors(trainBoxplotGroup==1),trainErrors(trainBoxplotGroup==4))
[~,p] = ttest2(trainErrors(trainBoxplotGroup==1),trainErrors(trainBoxplotGroup==6))
[~,p] = ttest2(trainErrors(trainBoxplotGroup==1),trainErrors(trainBoxplotGroup==8))

% 1 2 3 4
distances = double(distances);
[~,p] = ttest2(reshape(avgDistance(:,:,1),[],1),reshape(avgDistance(:,:,2),[],1))
[~,p] = ttest2(reshape(avgDistance(:,:,1),[],1),reshape(avgDistance(:,:,3),[],1))
[~,p] = ttest2(reshape(avgDistance(:,:,1),[],1),reshape(avgDistance(:,:,4),[],1))

%% Visualization of shapes (training and missing) in latent coordinates
useVAEoutputThreshold = true;
totalResolution = 1024;
titleLabels = {'All Shapes','Recombination','Interpolation','Extrapolation'};
for rep=1%1:length(latentDOFs)
    
    for shapeID=5%1:size(shapeParams,1)
        
        for i=1:4
            %%
            subSelected = sub2ind([numShapes numShapes],selectedShapes{i}(:,1),selectedShapes{i}(:,2));
            subdeselected=1:numShapes*numShapes; subdeselected(subSelected) = [];
            
            % Turn latent coordinates into pixel coordinates
            allFeatures = features{rep,shapeID,i};
            
            tsneCoords = tsne(allFeatures,'Standardize',true,'Perplexity',40,'NumDimensions',2,'NumPCAComponents',size(allFeatures,2));

            allFeatures = mapminmax(tsneCoords',0,1)';
            allFeatures = 1+ceil(allFeatures*totalResolution);
            trainFeatures = allFeatures(subSelected,:); missingFeatures = allFeatures(subdeselected,:);
            
            % Create image with samples in latent coordinates
            imgSize = [0 totalResolution + d.resolution];
            clear img; img{1} = (zeros(range(imgSize),range(imgSize)));img{2} = img{1}; img{3} = img{1}; img{4} = img{1};
            %for jj=1:size(genImgSample{rep,shapeID,i},4)
            %    coords = bitmapCoords{rep,shapeID,i}(:,jj)';
            %    img{1}([coords(1):(coords(1)+d.resolution-1)],[coords(2):(coords(2)+d.resolution-1)]) = img{1}([coords(1):(coords(1)+d.resolution-1)],[coords(2):(coords(2)+d.resolution-1)]) + squeeze(genImgSample{rep,shapeID,i}(:,:,:,jj));
            %end
            %mask{1} = img{1}>0;
            %if useVAEoutputThreshold; img{1} = img{1} > pxThreshold;end
            
            % Create image with training examples in latent coordinates
            for jj=1:size(trainFeatures,1)
                coords = trainFeatures(jj,:);
                img{2}([coords(1):(coords(1)+d.resolution-1)],[coords(2):(coords(2)+d.resolution-1)]) = img{2}([coords(1):(coords(1)+d.resolution-1)],[coords(2):(coords(2)+d.resolution-1)]) + squeeze(genImgTrain{rep,shapeID,i}(:,:,:,jj));
            end
            mask{2} = img{2}>pxThreshold;
            if useVAEoutputThreshold; img{2} = img{2} > pxThreshold;end
            
            % Create image with missing training examples in latent coordinates
            if ~isempty(subdeselected)
                for jj=1:size(missingFeatures,1)
                    coords = missingFeatures(jj,:);
                    img{3}([coords(1):(coords(1)+d.resolution-1)],[coords(2):(coords(2)+d.resolution-1)]) = img{3}([coords(1):(coords(1)+d.resolution-1)],[coords(2):(coords(2)+d.resolution-1)]) + squeeze(genImgMissing{rep,shapeID,i}(:,:,:,jj));
                end
            end
            mask{3} = img{3}>pxThreshold;
            if useVAEoutputThreshold; img{3} = img{3} > pxThreshold;end
            
            % Create image with ground truth training examples in latent coordinates
            tImg = img{4};
            for jj=1:size(allFeatures,1)
                I = double(phenotypes{shapeID,1}{jj}); BW = imbinarize(I); [B,L] = bwboundaries(BW,'holes');
                shape = zeros(size(phenotypes{shapeID,1}{jj}));
                for boundary=1:length(B)
                    for pix=1:length(B{boundary}(:,1))
                        shape(B{boundary}(pix,1),B{boundary}(pix,2)) = 1;
                    end
                end
                shape = imdilate(shape, strel('disk', 1));
                coords = allFeatures(jj,:);
                tImg([coords(1):(coords(1)+d.resolution-1)],[coords(2):(coords(2)+d.resolution-1)]) = tImg([coords(1):(coords(1)+d.resolution-1)],[coords(2):(coords(2)+d.resolution-1)]) + shape;
            end
            img{4} = tImg > 0; mask{4} = img{4};
            
            % Show image
            fig(end+1) = figure;
            %rgbImage1 = cat(3, 1-img{1}, 1-img{1}, 1-img{1});
            rgbImage2 = cat(3, img{2}.*ones(size(img{2})),img{2}.*ones(size(img{2})), img{2}.*1-img{2});
            rgbImage3 = cat(3, img{3}.*1-img{3}, img{3}.*1-img{3},img{3}.*ones(size(img{3})));
            rgbImage4 = cat(3, 1-img{4}, 1-img{4}, 1-img{4});
            C = ones(size(rgbImage2));
            %C(repmat(mask{1},1,1,3)) = rgbImage1(repmat(mask{1},1,1,3));
            C(repmat(mask{2},1,1,3)) = rgbImage2(repmat(mask{2},1,1,3));
            C(repmat(mask{3},1,1,3)) = rgbImage3(repmat(mask{3},1,1,3));
            C(repmat(mask{4},1,1,3)) = rgbImage4(repmat(mask{4},1,1,3));
            imshow(C);
            title(titleLabels{i});
            drawnow
        end
    end
end
%%
drawnow;
save_figures(fig, '.', 'IDNODNI-II', 12, [8 8])





