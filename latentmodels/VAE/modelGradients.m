function [infGrad, genGrad] = modelGradients(encoderNet, decoderNet, x, epoch, numEpochs)
[z, zMean, zLogvar, zOrg] = sampling(encoderNet, x);
xPred = sigmoid(forward(decoderNet, z));
loss = ELBOloss(x, xPred, zMean, zLogvar, zOrg, epoch, numEpochs);
[genGrad, infGrad] = dlgradient(loss, decoderNet.Learnables, encoderNet.Learnables);
end