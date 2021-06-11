function bitmaps = sampleVAE(latentVectors,decoderNet)
%SAMPLEVAE Generate bitmaps from latent vectors
%
% Syntax:  bitmaps = sampleVAE(latentVectors,decoderNet)
%
% Inputs:
%   latentVectors             - Latent coordinates
%   decoderNet                - Trained decoder of VAE
%
% Outputs:
%   bitmaps                   - Resulting bitmaps

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jun 2020; Last revision: 11-Jun-2021

input(1,1,:,:) = latentVectors';
input = dlarray(input,'SSCB');
generatedImage = sigmoid(predict(decoderNet, input));
returnImage = gather(extractdata(generatedImage));
for i=1:size(returnImage,4)
    bitmaps{i} = squeeze(returnImage(:,:,1,i));
end
end
