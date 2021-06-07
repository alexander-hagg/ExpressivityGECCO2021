function vae = convDefault_nodropout_larger(latentDim,resolution,numFilters,filterSize,stride)
%CONFIGUREVAE VAE is configured as in 
% Burgess, C. P., Higgins, I., Pal, A., Matthey, L., Watters, N., Desjardins, G., & Lerchner, A. (2017). 
% Understanding disentangling in ? -VAE
% 10 Apr 2018, (Nips).
%
imageSize = [resolution resolution 1];
weightsInitializer = 'glorot'; %he narrow-normal glorot
vae.encoderLG = layerGraph([
    imageInputLayer(imageSize,'Name','input_encoder','Normalization','none')
    convolution2dLayer(filterSize, numFilters/8, 'Padding','same', 'Stride', stride, 'Name', 'conv1', 'WeightsInitializer', weightsInitializer)
    reluLayer('Name','relu01')
    maxPooling2dLayer(2,'Stride',2,'Name','mpool1','HasUnpoolingOutputs',true)
    convolution2dLayer(filterSize, numFilters/4, 'Padding','same', 'Stride', stride, 'Name', 'conv2', 'WeightsInitializer', weightsInitializer)
    reluLayer('Name','relu02')
    maxPooling2dLayer(2,'Stride',2,'Name','mpool2','HasUnpoolingOutputs',true)
    convolution2dLayer(filterSize, numFilters/2, 'Padding','same', 'Stride', stride, 'Name', 'conv3', 'WeightsInitializer', weightsInitializer)
    reluLayer('Name','relu03')
    maxPooling2dLayer(2,'Stride',2,'Name','mpool3','HasUnpoolingOutputs',true)
    fullyConnectedLayer(2 * latentDim, 'Name', 'fc_encoder', 'WeightsInitializer', weightsInitializer)
    ]);

%projectAndReshapeLayer(projectionSize,numLatentInputs,'proj');

vae.decoderLG = layerGraph([
    imageInputLayer([1 1 latentDim],'Name','i','Normalization','none')
    maxUnpooling2dLayer('Name','unpool1');    
    transposedConv2dLayer(filterSize*2, numFilters, 'Cropping', 'same', 'Stride', stride*4, 'Name', 'transpose1', 'WeightsInitializer', weightsInitializer)
    reluLayer('Name','relu11')
    maxUnpooling2dLayer('Name','unpool2');    
    transposedConv2dLayer(filterSize, numFilters/2, 'Cropping', 'same', 'Stride', stride, 'Name', 'transpose2', 'WeightsInitializer', weightsInitializer)
    reluLayer('Name','relu12')
    maxUnpooling2dLayer('Name','unpool3');    
    transposedConv2dLayer(filterSize, numFilters/4, 'Cropping', 'same', 'Stride', stride, 'Name', 'transpose3', 'WeightsInitializer', weightsInitializer)
    reluLayer('Name','relu13')
    ]);


lgraph = connectLayers(lgraph,'mpool/indices','unpool/indices');
lgraph = connectLayers(lgraph,'mpool/size','unpool/size');
end

