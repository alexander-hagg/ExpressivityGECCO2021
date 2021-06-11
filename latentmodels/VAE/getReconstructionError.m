function [reconstructionError,xTrue,xPred] = getReconstructionError(phenotypes,model)
%GETRECONSTRUCTIONERROR Get VAE reconstruction error
%
% Syntax:  [reconstructionError,xTrue,xPred] = getReconstructionError(phenotypes,model)
%
% Inputs:
%   phenotypes                - Phenotypes
%   model                     - Full VAE
%
% Outputs:
%   normfeatures              - Normalized features                  

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jun 2020; Last revision: 11-Jun-2021

[xPred,xTrue] = getPrediction(phenotypes,model);
reconstructionError = zeros(size(phenotypes,1),1);
for i=1:size(xTrue,4)
    reconstructionError(i) = gather(extractdata(loss(xTrue(:,:,:,i), xPred(:,:,:,i), [], [])));
end
end

    