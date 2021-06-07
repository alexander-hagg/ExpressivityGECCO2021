function [replaced, replacement, features, percImprovement] = nicheCompete(newInds,fitness,map,d,p,features)
%nicheCompete - results of competition with map's existing elites
%
% Syntax:  [replaced, replacement, features, percImprovement] = nicheCompete(newInds,fitness,map,d,p,varargin)
%
% Inputs:
%   newInds - [NXM]     - New population to compete for niches
%   fitness - [NX1]     - Fitness values fo new population
%   map     - struct    - Population archive
%   d       - struct    - Domain definition
%   p       - struct    - QD configuration
%
% Outputs:
%   replaced    - [NX1] - Linear index of map cells to recieve replacements
%   replacement - [NX1] - Index of newInds to replace current elites in niche
%   features    - [NxNumFeatures] - return features
%
%
% Other m-files required: getBestPerCell.m
%
% See also: createMap, getBestPerCell, updateMap

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jul 2019; Last revision: 15-Aug-2019

%------------- BEGIN CODE --------------
percImprovement = nan;

mapMembers = 1:size(map.features,1);
newMembers = size(map.features,1)+(1:size(features,1));
allMembers = [mapMembers,newMembers];
distances = pdist2([map.features;features],[map.features;features]);
distances(logical(eye(size(distances,1)))) = nan; % Prevent comparisons of a candidate with itself

% If map is overflowing, perform niching
allFitness = [map.fitness;fitness];
while length(allMembers)>p.maxBins
    tDistances = distances(allMembers,allMembers);
    [sorted,sortDistID] = sort(min(tDistances),'descend');
    [~,competeID] = min(tDistances(sortDistID(end),:));
    %%
    tFitness = allFitness(allMembers);
    if tFitness(sortDistID(end)) < tFitness(competeID)
        allMembers(sortDistID(end)) = [];
    else
        allMembers(competeID) = [];
    end
end

replaced = true(1,length(mapMembers));
replaced(allMembers(allMembers <= length(mapMembers))) = false;
replacement = false(1,length(newMembers));
replacement(allMembers(allMembers > length(mapMembers))-length(mapMembers)) = true;

%------------- END OF CODE --------------