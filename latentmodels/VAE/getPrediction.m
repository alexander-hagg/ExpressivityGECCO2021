function [latent,xPred,xTrue] = getPrediction(phenotypes,model)
%GETPREDICTION Get VAE prediction (latent coordinates and reconstruction)
%for bitmap phenotypes
%
% Syntax:  [latent,xPred,xTrue] = getPrediction(phenotypes,model)
%
% Inputs:
%   phenotypes                - Bitmap phenotypes
%   model                     - VAE
%
% Outputs:
%   latent                    - Latent coordinates
%   xPred                     - Predicted phenotypes
%   xTrue                     - True phenotypes

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jun 2020; Last revision: 11-Jun-2021

xTrue = cat(4,phenotypes);
latent = getLatent(phenotypes,model);
latX(1,1,:,:) = cat(4,latent);
latX = dlarray(single(latX), 'SSCB');
latent = latent';

if nargin == 1
    return;
end

result = sigmoid(predict(model.decoderNet, latX));

xPred = gather(extractdata(result));
end

