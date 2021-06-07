function visualizeTrainingDatainLatentSpace(vae,data)
%VISUALIZETRAININGDATAINLATENTSPACE Summary of this function goes here
%   Detailed explanation goes here

if isa(data,'augmentedImageDatastore')
    dataTable = data.readall;
    X = cat(4,dataTable.input{:,1});
    X = dlarray(single(X), 'SSCB');
else
    X = data;
end
[zSampled, ~, ~] = sampling(vae.encoderNet, X);
zSampled = squeeze(zSampled);
zSampled = gather(extractdata(zSampled));

figure;
if size(zSampled,1) == 2
    scatter(zSampled(1,:),zSampled(2,:));axis([-3 3 -3 3]);
    xlabel('X');ylabel('Y');
    title('2D latent space');
elseif size(zSampled,1) == 3
    scatter3(zSampled(1,:),zSampled(2,:),zSampled(3,:));axis([-3 3 -3 3 -3 3]);
    title('3D latent space');
    xlabel('X');ylabel('Y');zlabel('Z');
end
end

