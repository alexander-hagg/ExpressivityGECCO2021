function zMean = getLatent(XTest,model)
if iscell(XTest)
    XBatch = cat(4,XTest{:});
else
    XBatch = cat(4,XTest);
end
XBatch = dlarray(single(XBatch), 'SSCB');

executionEnvironment = "gpu"; %auto cpu gpu

if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
    XBatch = gpuArray(XBatch);
end

[~, zMean] = sampling(model.encoderNet, XBatch);
zMean = stripdims(zMean)';
zMean = gather(extractdata(zMean));
zMean = zMean';
end
