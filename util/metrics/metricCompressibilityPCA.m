function [compressibility,score,explained] = metricCompressibilityPCA(samples, varThreshold)
%METRICCOMPRESSIBILITYPCA Summary of this function goes here
%   Detailed explanation goes here

if isempty(samples) || size(samples,1) == 1
    compressibility = 0;
    return;
end

[coeff,score,latent,tsquared,explained,mu] = pca(samples);
cumulativeExplained = cumsum(explained,1);
compressibility = find(cumulativeExplained>varThreshold);
compressibility = compressibility(1);
end

