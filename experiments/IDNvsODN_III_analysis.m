clear;
%% Configuration
addpath(genpath(pwd))                           % Set path to all modules
DOF = 16;                                       % Degrees of freedom, Catmull-Rom spline domain
d = domain(DOF);                                % Domain configuration
FITNESSFUNCTION = 'bmpSymmetry'; rmpath(genpath('domain/catmullRom/fitnessFunctions')); addpath(genpath(['domain/catmullRom/fitnessFunctions/' FITNESSFUNCTION]));

%% Visualize
    
BMIN = 0.5; BMAX = 1; 
%clear counts fitnesses score

for replicate=1:10
    disp(['Loading replicate: ' int2str(replicate)]);
    fileName = ['catmullRom_IIIb'];
    load(['' fileName '_replicate_' int2str(replicate) '.mat'],'config','map','results','dimRange','latentDOFs','latentDomain');
    
    for rep=1:length(latentDOFs)
        disp(['Latent DOF: ' int2str(latentDOFs(rep))]);
        
        % For fitness histograms
        counts(replicate,1,rep,:) = histcounts(map{rep,1}.fitness(:),20,'BinLimits',[BMIN,BMAX],'Normalization','count');
        counts(replicate,2,rep,:) = histcounts(map{rep,2}.fitness(:),20,'BinLimits',[BMIN,BMAX],'Normalization','count');
        counts(replicate,3,rep,:) = histcounts(map{rep,3}.fitness(:),20,'BinLimits',[BMIN,BMAX],'Normalization','count');
        counts(replicate,4,rep,:) = histcounts(map{rep,4}.fitness(:),20,'BinLimits',[BMIN,BMAX],'Normalization','count');
        
        % Get total fitness ("QD-score")
        fitnesses(replicate,rep,1) = sum(map{rep,1}.fitness);
        fitnesses(replicate,rep,2) = sum(map{rep,2}.fitness);
        fitnesses(replicate,rep,3) = sum(map{rep,3}.fitness);
        fitnesses(replicate,rep,4) = sum(map{rep,4}.fitness);
        
        % Get PD metrics
        genes = reshape(map{rep,1}.genes,[],d.dof); genes = genes(all(~isnan(genes)'),:);
        [~,flatbitmaps] = d.getPhenotype(genes);
        [score(replicate,rep,1)] = metricPD(flatbitmaps, 'hamming');
        
        genes = reshape(map{rep,2}.genes,[],latentDOFs(rep)); genes = genes(all(~isnan(genes)'),:);
        bitmaps = sampleVAE(genes,results{rep,1}.models(1).decoderNet);
        flatbitmaps = [];
        for i=1:length(bitmaps)
            bitmap = repairVAEoutput(bitmaps{i});
            flatbitmaps(i,:) = bitmap(:);
        end
        [score(replicate,rep,2)] = metricPD(flatbitmaps, 'hamming');
        
        genes = reshape(map{rep,3}.genes,[],d.dof); genes = genes(all(~isnan(genes)'),:);
        [~,flatbitmaps] = d.getPhenotype(genes);
        [score(replicate,rep,3)] = metricPD(flatbitmaps, 'hamming');
        
        genes = reshape(map{rep,4}.genes,[],latentDOFs(rep)); genes = genes(all(~isnan(genes)'),:);
        bitmaps = sampleVAE(genes,results{rep,3}.models(1).decoderNet);
        flatbitmaps = [];
        for i=1:length(bitmaps)
            bitmap = repairVAEoutput(bitmaps{i});
            flatbitmaps(i,:) = bitmap(:);
        end
        [score(replicate,rep,4)] = metricPD(flatbitmaps, 'hamming');
        
        losses(replicate,rep,1,:) = [results{rep,1}.models(1).statistics.loss(1) results{rep,1}.models(1).statistics.loss(50:50:end)];
        reconstructionLosses(replicate,rep,1,:) = [results{rep,1}.models(1).statistics.reconstructionLoss(1) results{rep,1}.models(1).statistics.reconstructionLoss(50:50:end)];
        regTerms(replicate,rep,1,:) = [results{rep,1}.models(1).statistics.regTerm(1) results{rep,1}.models(1).statistics.regTerm(50:50:end)];
        
        losses(replicate,rep,2,:) = [results{rep,3}.models(1).statistics.loss(1) results{rep,3}.models(1).statistics.loss(50:50:end)];
        reconstructionLosses(replicate,rep,2,:) = [results{rep,3}.models(1).statistics.reconstructionLoss(1) results{rep,3}.models(1).statistics.reconstructionLoss(50:50:end)];
        regTerms(replicate,rep,2,:) = [results{rep,3}.models(1).statistics.regTerm(1) results{rep,3}.models(1).statistics.regTerm(50:50:end)];
        
        
    end
end


%% Losses
nRuns = size(reconstructionLosses(:,:,1,:),1)*size(reconstructionLosses(:,:,1,:),2);
nEpochs = size(reconstructionLosses(:,:,1,:),4);

fig(199) = figure(199)
subplot(3,2,1);hold off;
semilogy(prctile(reshape(reconstructionLosses(:,:,1,:),nRuns,nEpochs),90));
hold on;
semilogy(squeeze(median(reconstructionLosses(:,:,1,:),[1 2 3])));
semilogy(prctile(reshape(reconstructionLosses(:,:,1,:),nRuns,nEpochs),10));
ax = gca;ax.XTick = 0:2:nEpochs; 
ax.XTickLabel = ax.XTick*50;ylabel('Reconstruction Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^0 10^4];

subplot(3,2,2);hold off;
semilogy(prctile(reshape(reconstructionLosses(:,:,2,:),nRuns,nEpochs),90));
hold on;
semilogy(squeeze(median(reconstructionLosses(:,:,2,:),[1 2 3])));
semilogy(prctile(reshape(reconstructionLosses(:,:,2,:),nRuns,nEpochs),10));
ax = gca;ax.XTick = 0:2:nEpochs; 
ax.XTickLabel = ax.XTick*50;ylabel('Reconstruction Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^0 10^4];
%

subplot(3,2,3);hold off;
semilogy(prctile(reshape(regTerms(:,:,1,:),nRuns,nEpochs),90));
hold on;
semilogy(squeeze(median(regTerms(:,:,1,:),[1 2 3])));
semilogy(prctile(reshape(regTerms(:,:,1,:),nRuns,nEpochs),10));
ax = gca;ax.XTick = 0:2:nEpochs; 
ax.XTickLabel = ax.XTick*50;ylabel('KL Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^0 10^2];

subplot(3,2,4);hold off;
semilogy(prctile(reshape(regTerms(:,:,2,:),nRuns,nEpochs),90));
hold on;
semilogy(squeeze(median(regTerms(:,:,2,:),[1 2 3])));
semilogy(prctile(reshape(regTerms(:,:,2,:),nRuns,nEpochs),10));
ax = gca;ax.XTick = 0:2:nEpochs; 
ax.XTickLabel = ax.XTick*50;ylabel('KL Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^0 10^2];
%

subplot(3,2,5);hold off;
semilogy(prctile(reshape(losses(:,:,1,:),nRuns,nEpochs),90));
hold on;
semilogy(squeeze(median(losses(:,:,1,:),[1 2 3])));
semilogy(prctile(reshape(losses(:,:,1,:),nRuns,nEpochs),10));
ax = gca;ax.XTick = 0:2:nEpochs; 
ax.XTickLabel = ax.XTick*50;ylabel('Total \beta-Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^0 10^4];

subplot(3,2,6);hold off;
semilogy(prctile(reshape(losses(:,:,2,:),nRuns,nEpochs),90));
hold on;
semilogy(squeeze(median(losses(:,:,2,:),[1 2 3])));
semilogy(prctile(reshape(losses(:,:,2,:),nRuns,nEpochs),10));
ax = gca;ax.XTick = 0:2:nEpochs; 
ax.XTickLabel = ax.XTick*50;ylabel('Total \beta-Loss Term');xlabel('Epochs');grid on;
ax.YLim = [10^0 10^4];

save_figures(fig, '.', 'IDNODNIII-losses', 12, [7 5])

%% Histograms
YMAX = 100;
fig(1) = figure(1);
edges = BMIN:(BMAX-BMIN)./(20):BMAX;
subplot(4,1,1);
histogram('BinEdges',edges,'BinCounts',mean(squeeze(mean(squeeze(counts(:,1,:,:)),1)),1))

title('Parameter Search, Random')
ax = gca;ax.YLim = [0 YMAX];grid on;xlabel('fitness');ylabel('count');

subplot(4,1,2);
histogram('BinEdges',edges,'BinCounts',mean(squeeze(mean(squeeze(counts(:,2,:,:)),1)),1))
title('Latent Search, Random')
ax = gca;ax.YLim = [0 YMAX];grid on;xlabel('fitness');ylabel('count');

subplot(4,1,3);
histogram('BinEdges',edges,'BinCounts',mean(squeeze(mean(squeeze(counts(:,3,:,:)),1)),1))
title('Parameter Search, Continue')
ax = gca;ax.YLim = [0 YMAX];grid on;xlabel('fitness');ylabel('count');

subplot(4,1,4);
histogram('BinEdges',edges,'BinCounts',mean(squeeze(mean(squeeze(counts(:,4,:,:)),1)),1))
title('Latent Search, Continue')
ax = gca;ax.YLim = [0 YMAX];grid on;xlabel('fitness');ylabel('count');

%% Visualization

for i=1:3
    fig(end+1) = figure;
    boxplot(squeeze(score(:,i,:)),'PlotStyle','compact','BoxStyle', 'filled');
    ax = gca; ax.XTick = 1:4;ax.XTickLabel = {'par rng', 'lat rng', 'par cont','lat cont'};
    title(['Lat. Dim. ' int2str(latentDOFs(i))]);
    ax.YLim = [0 65];
    grid on;    
end

%%
for i=1:3
    fig(end+1) = figure;
    boxplot(squeeze(fitnesses(:,i,:)),'PlotStyle','compact','BoxStyle', 'filled');
    ax = gca; ax.XTick = 1:4;ax.XTickLabel = {'par rng', 'lat rng', 'par cont','lat cont'};
    title(['Lat. Dim. ' int2str(latentDOFs(i))]);
    ax.YLim = [380 460];
    grid on;
end

%% Significance testing
disp('Two-Sample t-test significance PD');
for i=1:3
%p = ranksum(score(:,i,1),score(:,i,2))
%p = ranksum(score(:,i,3),score(:,i,4))
[~,p] = ttest2(score(:,i,1),score(:,i,2))
[~,p] = ttest2(score(:,i,3),score(:,i,4))
end
disp('Two-Sample t-test significance fitness');

 for i=1:3
%p = ranksum(score(:,i,1),score(:,i,2))
%p = ranksum(score(:,i,3),score(:,i,4))
[~,p] = ttest2(fitnesses(:,i,1),fitnesses(:,i,2))
[~,p] = ttest2(fitnesses(:,i,3),fitnesses(:,i,4))
end
    

%%
% plot(repmat(latentDOFs',1,4), squeeze(mean(score,1)),'o-')
% legend('Parameter, from random', 'Latent, from random', 'Parameter, continuation','Latent, continuation','Location','SouthEast')
% xlabel('Latent DOF');
% ylabel('Pure Diversity');
% ax=gca;ax.XTick = latentDOFs;
% ax.YAxis.Limits = [0 60];
% grid on
% title('Diversity of solution sets');
% 
% fig(3) = figure(3);
% plot(repmat(latentDOFs',1,4), squeeze(mean(fitnesses,1))./pm.map.numInitSamples,'o-')
% legend('Parameter, from random', 'Latent, from random', 'Parameter, continuation','Latent, continuation','Location','NorthEast')
% xlabel(' Latent DOF');
% ylabel('Avg. Fitness');
% ax=gca;ax.XTick = latentDOFs;
% ax.YAxis.Limits = [0.75 1];
% grid on
% title('Avg. Fitness');
% 
% save_figures(fig, '.', 'IDNODNIII', 12, [5 5])

%% Show some shapes
rep = 1;

genes = reshape(map{rep,1}.genes,[],d.dof); genes = genes(all(~isnan(genes)'),:);
fig(end+1) = figure;
bitmaps{1} = showPhenotypeBMP(genes,d,fig(end));

genes = reshape(map{rep,2}.genes,[],latentDOFs(rep)); genes = genes(all(~isnan(genes)'),:);
bitmapsVAE = sampleVAE(genes,results{rep,2}.models(1).decoderNet);
fig(end+1) = figure;
bitmaps{2} = showPhenotypeBMP(bitmapsVAE,latentDomain{replicate,rep,2},fig(end));

genes = reshape(map{rep,3}.genes,[],d.dof); genes = genes(all(~isnan(genes)'),:);
bitmapsPAR = d.getPhenotype(genes);
fig(end+1) = figure;
bitmaps{3} = showPhenotypeBMP(genes,d,fig(end));

genes = reshape(map{rep,4}.genes,[],latentDOFs(rep)); genes = genes(all(~isnan(genes)'),:);
bitmapsVAE = sampleVAE(genes,results{rep,4}.models(1).decoderNet);
fig(end+1) = figure;
bitmaps{4} = showPhenotypeBMP(bitmapsVAE,latentDomain{replicate,rep,4},fig(end));

%% Show some shapes with t-SNE
rep = 2;
fileName = ['catmullRom_IIIb'];
load(['' fileName '_replicate_' int2str(rep) '.mat'],'config','map','results','dimRange','latentDOFs','latentDomain');
    
genes1 = map{rep,1}.genes;
features1 = map{rep,1}.features;
bitmaps = d.getPhenotype(genes1);

genes2 = map{rep,2}.genes;
bitmapsVAE = sampleVAE(genes2,results{rep,2}.models(1).decoderNet);
features2 = map{rep,2}.features;


tsneCoords = tsne([features1;features2],'Standardize',true,'Perplexity',20,'NumDimensions',2,'NumPCAComponents',8);

%%
fig(1) = figure(1);
showPhenotypeBMP(bitmaps,d,gcf,1+30*ceil(tsneCoords(1:512,:)-min(tsneCoords(:))));
axis([0 2200 0 2200]);

fig(2) = figure(2);
showPhenotypeBMP(bitmapsVAE,d,gcf,1+30*ceil(tsneCoords(513:1024,:)-min(tsneCoords(:))));
axis([0 2200 0 2200]);


%%
save_figures(fig, '.', 'IDNODNIII', 12, [5 5])

%%

%%
rep = 2
% Get phenotypes from genes from PS
genes = reshape(map{rep,2}.genes,[],d.dof); genes = genes(all(~isnan(genes)'),:);
bitmapsPS = d.getPhenotype(genes);
input = [];
for i=1:length(bitmapsPS)
    input(:,:,1,i) = bitmapsPS{i};
end

input = dlarray(single(input), 'SSCB');
input = gpuArray(input);
[latentCoordsPS,~,~] = sampling(results{rep,4}.models(1).encoderNet, input);
modelOut = sigmoid(forward(results{rep,4}.models(1).decoderNet, latentCoordsPS));
modelOut = double(gather(extractdata(modelOut)));
bitmapsPSreconstruction = {};
for i=1:size(modelOut,4)
    bitmapsPSreconstruction{i} = squeeze(modelOut(:,:,1,i));
	threshold = 0.9*max(bitmapsPSreconstruction{i}(:));
    bitmapsPSreconstruction{i} = bitmapsPSreconstruction{i}>threshold;
    xPred = bitmapsPSreconstruction{i}(:);
    x = bitmapsPS{i}(:);
    %reconstructionErrorsPS(i) = crossentropy(xPred,x,'TargetCategories','independent');
    [~,reconstructionErrorsPS(i)] = ELBOloss(x, xPred, 0, 0, 0, 1, 1);
end
% Get phenotypes from genes from LS
genes = reshape(map{rep,4}.genes,[],16); genes = genes(all(~isnan(genes)'),:);
bitmapsLS = sampleVAE(genes,results{rep,4}.models(1).decoderNet); 
for i=1:length(bitmapsLS)
    threshold = 0.9*max(bitmapsLS{i}(:));
    bitmapsLSreconstruction{i} = bitmapsLS{i}>threshold;
    xPred = bitmapsLSreconstruction{i}(:);
    x = bitmapsLS{i}(:);
    %reconstructionErrorsPS(i) = crossentropy(xPred,x,'TargetCategories','independent');
    [~,reconstructionErrorsLS(i)] = ELBOloss(x, xPred, 0, 0, 0, 1, 1);
end

input = [];
for i=1:length(bitmapsLS)
    input(:,:,1,i) = bitmapsLS{i};
end
input = dlarray(single(input), 'SSCB');
input = gpuArray(input);
[latentCoordsLS,~,~] = sampling(results{rep,4}.models(1).encoderNet, input);

%%
% flatbmps = [];
% for i=1:length(bitmapsPS)    
%     flatbmps(end+1,:) = double(bitmapsPS{i}(:));    
% end
% for i=1:length(bitmapsLS)    
%     flatbmps(end+1,:) = double(bitmapsLS{i}(:));    
% end

%%
tsneCoords = tsne([squeeze(gather(extractdata(latentCoordsPS)))';squeeze(gather(extractdata(latentCoordsLS)))'],'Standardize',true,'Perplexity',20,'NumDimensions',2,'NumPCAComponents',4);

%%
nShapes = size(tsneCoords,1)/2;
errL200 = reconstructionErrorsPS>200 & reconstructionErrorsPS<=400;
errL400 = reconstructionErrorsPS>400 & reconstructionErrorsPS<=600;
errL600 = reconstructionErrorsPS>600 & reconstructionErrorsPS<=800;
errL800 = reconstructionErrorsPS>800;
%%
PScoords = tsneCoords(1:nShapes,:);

%cmap = [0.4 0 0; 0.6 0 0; 0.8 0 0; 1 0 0];
cmap = [0.7 0.3 0.3; 0.8 0.3 0.3; 0.9 0.3 0.3; 1 0.3 0.3];
sz = 32;

clear fig;fig(5) = figure(5);hold off;

%plot3([tsneCoords(1:nShapes,1) tsneCoords(1:nShapes,1)]',[reconstructionErrorsLS; reconstructionErrorsPS],[tsneCoords(1:nShapes,2) tsneCoords(1:nShapes,2)]','Color',[0.7 0.7 0.7],'LineWidth',0.5);hold on;
scatter3(PScoords(errL200,1),reconstructionErrorsPS(errL200),PScoords(errL200,2),sz,cmap(1,:),'filled');hold on;
scatter3(PScoords(errL400,1),reconstructionErrorsPS(errL400),PScoords(errL400,2),sz,cmap(2,:),'filled');hold on;
scatter3(PScoords(errL600,1),reconstructionErrorsPS(errL600),PScoords(errL600,2),sz,cmap(3,:),'filled');hold on;
scatter3(PScoords(errL800,1),reconstructionErrorsPS(errL800),PScoords(errL800,2),sz,cmap(4,:),'filled');hold on;
scatter3(tsneCoords(nShapes+1:2*nShapes,1),reconstructionErrorsLS,tsneCoords(nShapes+1:2*nShapes,2),sz,'k','filled');hold on;
alpha = 0.5; minVal = -30; maxVal = -minVal;
axis([minVal maxVal 0 1000 minVal maxVal]);
faceClr = [1 0.95 0.95];
err = 200;patch([maxVal maxVal minVal minVal],[err err err err],[minVal maxVal maxVal minVal],faceClr,'FaceAlpha',alpha)
err = 400;patch([maxVal maxVal minVal minVal],[err err err err],[minVal maxVal maxVal minVal],faceClr,'FaceAlpha',alpha)
err = 600;patch([maxVal maxVal minVal minVal],[err err err err],[minVal maxVal maxVal minVal],faceClr,'FaceAlpha',alpha)
err = 800;patch([maxVal maxVal minVal minVal],[err err err err],[minVal maxVal maxVal minVal],faceClr,'FaceAlpha',alpha)

%legend('PS','LS');
xlabel('Latent Space 1');
ylabel('Reconstruction Error');
zlabel('Latent Space 2');
%set(gca, 'Projection','perspective')
ax = gca;
ax.XTick = [];
ax.YTick = 0:200:1000;
ax.ZTick = [];
view(80,30)
save_figures(fig, '.', 'IDNODNIII_extrapolation', 12, [15 5])

%%


