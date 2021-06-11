function [features,unnormalizedFeatures] = categorize(polygons,d)
%CATEGORIZE Determine features for Catmull-Rom artifacts
%
% Syntax: [features,unnormalizedFeatures] = categorize(polygons,d)
%
% Inputs:
%   polygons               - struct - Polygons
%   d                      - struct - Domain configuration
%
% Outputs:
%   features               - [NxF] - normalized feature values [0-1]
%   unnormalizedFeatures   - [NxF] - unnormalized feature values

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Nov 2019; Last revision: 11-Jun-2021

for i=1:length(polygons)
    if ~isa(polygons{i},'double')
        pgon = simplify(polygons{i});
    
        % Feature 1: Area
        unnormalizedFeatures(i,1) = area(pgon);
    
        % Feature 2: Perimeter
        unnormalizedFeatures(i,2) = perimeter(pgon);
    else
        unnormalizedFeatures(i,1) = nan;
        unnormalizedFeatures(i,2) = nan;
    end
end
features(:,1) = (unnormalizedFeatures(:,1)-d.featureMin(1))./(d.featureMax(1)-d.featureMin(1));
features(:,2) = (unnormalizedFeatures(:,2)-d.featureMin(2))./(d.featureMax(2)-d.featureMin(2));
features(features>1) = 1; features(features<0) = 0;
end

