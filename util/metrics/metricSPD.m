function [result,distMetric] = metricSPD(samples, varargin)
%METRIC Summary of this function goes here

distMetric = 'euclidean';
if nargin > 1
    distMetric = varargin{1};
end

theta = 1;
if nargin > 2
    theta = varargin{2};
end

if isempty(samples) || size(samples,1) == 1
    result = 0;
    return;
end

ddd = pdist2(samples,samples,distMetric);
ddd = exp(-theta.*ddd);
result = ones(1,size(ddd,1))*pinv(ddd)*ones(1,size(ddd,1))';

end

