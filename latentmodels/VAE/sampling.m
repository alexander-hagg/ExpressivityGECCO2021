function [zSampled, zMean, zLogvar, zOrg] = sampling(encoderNet, x)
compressed = forward(encoderNet, x);
d = size(compressed,1)/2;
zMean = compressed(1:d,:);
zLogvar = compressed(1+d:end,:);

sz = size(zMean);
epsilon = randn(sz);
sigma = exp(.5 * zLogvar);
zOrg = epsilon .* sigma + zMean;
z = reshape(zOrg, [1,1,sz]);
zSampled = dlarray(z, 'SSCB');
end