function plotTrainingReconstruction(data,vae)
%PLOTTRAININGRECONSTRUCTION Summary of this function goes here
%   Detailed explanation goes here
trainDataTable = data.trainStore.readall;
XTrain = cat(4,trainDataTable.input{:,1});
XTrain = dlarray(single(XTrain), 'SSCB');
X = gather(extractdata(XTrain));

%if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
XTrain = gpuArray(XTrain);
%end
[z, ~, ~] = sampling(vae.encoderNet, XTrain);
XPred = sigmoid(forward(vae.decoderNet, z));
XPred = gather(extractdata(XPred));

squares = 0.5*(XPred-XTrain).^2;
reconstructionLoss  = sum(squares, [1,2,3]);

disp(['Mean training reconstruction loss: ' num2str(mean(reconstructionLoss))]);

figure(1);
imshow(imtile(X, "ThumbnailSize", [100,100]));
title('Training data');
figure(2);
imshow(imtile(XPred, "ThumbnailSize", [100,100]));
title('Training reconstruction');
end

