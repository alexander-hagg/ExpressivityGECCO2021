function [reconstructionError,xTrue,xPred] = getReconstructionError(phenotypes,model)
%GETRECONSTRUCTIONERROR Summary of this function goes here
%   Detailed explanation goes here
[xPred,xTrue] = getPrediction(phenotypes,model);
reconstructionError = zeros(size(phenotypes,1),1);
for i=1:size(xTrue,4)
    reconstructionError(i) = gather(extractdata(loss(xTrue(:,:,:,i), xPred(:,:,:,i), [], [])));
end
end

    