function [elbo,reconstructionLoss,KL] = ELBOloss(x, xPred, zMean, zLogvar, z, epoch, numEpochs)
beta = 0.1;
squares = 0.5*(xPred-x).^2;
reconstructionLoss  = sum(squares, [1,2,3]);

KL = -.5 * sum(1 + zLogvar - zMean.^2 - exp(zLogvar), 1);

elbo = mean(reconstructionLoss + beta * KL);

% For output
reconstructionLoss = mean(reconstructionLoss);
KL = mean(KL);