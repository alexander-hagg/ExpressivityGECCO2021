function map = createMap(d, p, varargin)
%createMap - Defines map struct and feature space cell divisions
%
% Syntax:  map = createMap(d, p, varargin)
%
% Inputs:
%    d                  - struct - domain configuration
%    p                  - struct - Voronoi-Elites configuration
%
% Outputs:
%    map  - struct with [M(1) X M(2)...X M(N)] matrices for fitness, etc
%
% Example: 

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jul 2019; Last revision: 04-Jul-2019

%------------- BEGIN CODE --------------

map.config.genomeLength         = d.dof;
map.config.maxBins              = p.maxBins;
map.config.infReplacement       = 5;
map.fitness                     = [];
map.genes                       = [];
map.features                    = [];

if isfield(p,'extraMapValues') && ~isempty(p.extraMapValues)
    for iValues = 1:length(p.extraMapValues)
        eval(['map.' p.extraMapValues{iValues} ' = [];']);
    end
end

%------------- END OF CODE --------------