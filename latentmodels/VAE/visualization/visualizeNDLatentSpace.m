function visualizeNDLatentSpace(vae,latentDim,filename,numSteps,minAbsSample,maxAbsSample)
%VISUALIZENDLATENTSPACE Summary of this function goes here
%   Detailed explanation goes here
h = figure(3);

h.Position = [10 10 1000 1000];
ax = gca;
x = minAbsSample:(maxAbsSample-minAbsSample)/(numSteps-1):maxAbsSample;
if latentDim==1
    latentVector = x';
    img = sampleVAE(latentVector',vae.decoderNet);
    imshow(imtile(img,'GridSize', [1 length(latentVector)],"ThumbnailSize", [100,100]));
    
elseif latentDim==2
    y = x;
    for j=1:length(y)
        for i=1:length(x)
            latentVector(i + (j-1)*length(x),:) = [x(i) y(j)]';
        end
    end
    img = sampleVAE(latentVector',vae.decoderNet);
    img(img>0.7) = 1;img(img<=0.3) = 0;
    
    
    imshow(imtile(img, "ThumbnailSize", [100,100]));
elseif latentDim==3
    
    y = x;
    z = x;
    for k=1:length(z)
        for j=1:length(y)
            for i=1:length(x)
                latentVector(k,i + (j-1)*length(x),:) = [x(i) y(j) z(k)]';
            end
        end
    end
    for k=1:length(z)
        img = sampleVAE(squeeze(latentVector(k,:,:))',vae.decoderNet);
        imagesc(ax,imtile(img,"ThumbnailSize", [100,100]));
        %thresh=0.9;img(img>thresh) = 1;img(img<=thresh) = 0;
        colormap(gray(64));
        title(['Equidistant Sampling of Latent Space']);
        drawnow;
        filename = [filename '.gif'];
        if k==1; gif(filename,'frame',h.Children(1),'DelayTime',1/2); else; gif('frame',h.Children(1)); end
    end
else
    disp(['No visualization yet for ' int2str(latentDim) ' latent dimensions']);
end

title(['Latent Space, Range: ' num2str(minAbsSample) ':' num2str(maxAbsSample)]);

end

