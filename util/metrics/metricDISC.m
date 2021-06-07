function [result,distMetric] = metricDISC(samples, varargin)
%METRIC Summary of this function goes here

distMetric = 'euclidean';
if nargin > 1
    distMetric = varargin{1};
end

if isempty(samples) || size(samples,1) == 1
    result = 0;
    return;
end

resultLeft = 0;
for i=1:size(samples,1)
    for j=1:size(samples,1)
        res = 1;
        for s=1:size(samples,2)
            res = res .* (1-max(samples(i,s),samples(j,s))).*min(samples(i,s),samples(j,s));
        end
        resultLeft = resultLeft + res;
    end
end
resultLeft = resultLeft./(size(samples,1).^2);

resultRight = 0;
for i=1:size(samples,1)
    res = 1;
    for s=1:size(samples,2)
        res = res .* (1-samples(i,s).^2);
    end
    resultRight = resultRight + res;
end
resultRight = (2^(1-size(samples,2))) .* resultRight./(size(samples,1));



result = resultLeft - resultRight + 12^(-size(samples,2));

end

