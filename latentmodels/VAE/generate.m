function generate(decoderNet, latentDim)
%GENERATE Generate bitmaps from random latent vectors (visualization purposes only)
%
% Syntax:  generate(decoderNet, latentDim)
%
% Inputs:
%   decoderNet                - Trained decoder of VAE
%   latentDim                 - Dimensionality of latent space
%
% Outputs:
%   NONE (visualization purposes only)

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jun 2020; Last revision: 11-Jun-2021

randomNoise = dlarray(randn(1,1,latentDim,1000),'SSCB');
generatedImage = sigmoid(predict(decoderNet, randomNoise));
generatedImage = extractdata(generatedImage);

f3 = figure;
figure(f3)
imshow(imtile(generatedImage, "ThumbnailSize", [100,100]))
title("Generated samples of digits")
drawnow
end