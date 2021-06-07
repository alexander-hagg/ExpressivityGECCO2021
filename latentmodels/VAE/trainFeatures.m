function model = trainFeatures(phenotypes,model)
%TRAINFEATURES Summary of this function goes here
%   Detailed explanation goes here
model = model.train(phenotypes);
[~,latentNorm] = mapminmax(model.latent,0,1);
model.latentNorm = latentNorm;

end

