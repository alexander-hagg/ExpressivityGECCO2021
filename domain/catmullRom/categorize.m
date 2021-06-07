function [features,unnormalizedFeatures] = categorize(polygons,d)
%CATEGORIZESYMMETRY Summary of this function goes here
%   Detailed explanation goes here
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

