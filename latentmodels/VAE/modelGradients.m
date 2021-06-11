function [infGrad, genGrad] = modelGradients(encoderNet, decoderNet, x, epoch, numEpochs)
%MODELGRADIENTS Calculate VAE gradients for training
%
% Syntax:  [infGrad, genGrad] = modelGradients(encoderNet, decoderNet, x, epoch, numEpochs)
%
% Inputs:
%   encoderNet                - Encoder of VAE
%   decoderNet                - Decoder of VAE
%   x                         - Inputs
%   epoch                     - Current epoch
%   numEpochs                 - Total number of epochs
%
% Outputs:
%   infGrad                   
%   genGrad                    

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jun 2020; Last revision: 11-Jun-2021

[z, zMean, zLogvar, zOrg] = sampling(encoderNet, x);
xPred = sigmoid(forward(decoderNet, z));
loss = ELBOloss(x, xPred, zMean, zLogvar, zOrg, epoch, numEpochs);
[genGrad, infGrad] = dlgradient(loss, decoderNet.Learnables, encoderNet.Learnables);
end