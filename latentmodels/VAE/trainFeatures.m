function model = trainFeatures(phenotypes,model)
%TRAINFEATURES Train VAE model and normalize resulting latent space
%
% Syntax:  model = trainFeatures(phenotypes,model)
%
% Inputs:
%   phenotypes             - Phenotypes (flattened bitmaps)
%   model                  - Initialized VAE model + configuration
%
% Outputs:
%   model                  - Trained model

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jun 2020; Last revision: 11-Jun-2021

model = model.train(phenotypes);
[~,latentNorm] = mapminmax(model.latent,0,1);
model.latentNorm = latentNorm;

end

