function data = getDataPoly(phenotypes,imgDir,resolution,trainPerc)
%GETDATAPOLY Summary of this function goes here
%   Detailed explanation goes here
system(['rm -rf ' imgDir '/*']);
writePhenoToDisk(phenotypes,imgDir);

dataDir = [imgDir '/'];
imds = imageDatastore(dataDir, ...
    'IncludeSubfolders',false, ...
    'LabelSource','foldernames');

augmenter = imageDataAugmenter( ...
    'FillValue', 0);

if trainPerc < 1
    [ds1,ds2] = splitEachLabel(imds,trainPerc,'randomized');
    data.trainStore = augmentedImageDatastore([resolution resolution],ds1,'DataAugmentation',augmenter);
    data.testStore = augmentedImageDatastore([resolution resolution],ds2,'DataAugmentation',augmenter);
else
    data.trainStore = augmentedImageDatastore([resolution resolution],imds,'DataAugmentation',augmenter);
    data.testStore = 'emptyStore';
end

end

