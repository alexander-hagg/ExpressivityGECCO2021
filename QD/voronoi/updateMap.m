function map = updateMap(replaced,replacement,map,fitness,genes,features,extraMapValues,values)
%updateMap - Replaces all values in a set of map cells
%
% Syntax:  map = updateMap(replaced,replacement,map,fitness,drag,lift,children)
%
% Inputs:
%   replaced    - [1XM]  - linear index of map cells to be replaced
%   replacement - [1XM]  - linear index of children values to place in map
%   map         - struct - population archive
%   fitness     - [1XN]  - Child fitness
%   genes       - [NXD]  - Child genomesextraMapValues
%   values      - [1XN]  - extra values of interest, e.g. 'cD'
%
% Outputs:
%   map         - struct - population archive
%
%
% See also: createMap, nicheCompete

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jul 2019; Last revision: 04-Jul-2019

%------------- BEGIN CODE --------------

% Assign Fitness
if ~isempty(replaced);map.fitness(replaced) = [];end
map.fitness = [map.fitness; fitness(replacement)];

% Assign Genes
if ~isempty(replaced);map.genes(replaced,:) = [];end
map.genes = [map.genes; genes(replacement,:)];

% Assign Features
if ~isempty(replaced);map.features(replaced,:) = [];end
map.features = [map.features; features(replacement,:)];

% Assign Miscellaneous Map values
if exist('extraMapValues','var') && ~isempty(extraMapValues)
    for iValues = 1:length(extraMapValues)
        if ~isempty(replaced); eval(['map.' extraMapValues{iValues} '(replaced) = [];']);end
        eval(['map.' extraMapValues{iValues} ' = [ map.' extraMapValues{iValues} ' values{' int2str(iValues) '}(replacement)];']);
    end
end

%------------- END OF CODE --------------