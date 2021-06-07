function [result,distMetric] = metricMeanDistance(samples, varargin)
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
result = mean(mean(triu(distances)));
end

