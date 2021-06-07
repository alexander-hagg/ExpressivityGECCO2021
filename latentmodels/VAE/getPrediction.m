function [latent,xPred,xTrue] = getPrediction(phenotypes,model)
%GETPREDICTION Summary of this function goes here
%   Detailed explanation goes here
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

