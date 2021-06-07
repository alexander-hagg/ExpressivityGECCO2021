function [result,distMetric] = metricSumOfDistances(samples, varargin)
%METRIC Summary of this function goes here

distMetric = 'euclidean';
if nargin > 1
    distMetric = varargin{1};
end

if isempty(samples) || size(samples,1) == 1
    result = 0;
    return;
end
distances = pdist2(samples,samples,distMetric);
result = sum(sum(triu(distances)));
end

