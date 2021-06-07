function compressibility = metricCompressibilityAE(samples)
%METRICCOMPRESSIBILITYAE Summary of this function goes here
%   Detailed explanation goes here

manifold = getAEConfig('data/workdir');
manifold = manifold.train(booleanMap);
simX = manifold.latent';


%compressibility
end

