function [elbo,reconstructionLoss,KL] = ELBOloss(x, xPred, zMean, zLogvar, z, epoch, numEpochs)
%disp(['Pred. size: ' mat2str(size(xPred)) ' org. size: ' mat2str(size(x))]);

squares = 0.5*(xPred-x).^2;
reconstructionLoss  = sum(squares, [1,2,3]);
KL = -.5 * sum(1 + zLogvar - zMean.^2 - exp(zLogvar), 1);
elbo = mean(reconstructionLoss + KL);
% For output
reconstructionLoss = mean(reconstructionLoss);
KL = mean(KL);