function [map, percImproved, percValid, allMaps, percFilled, stats] = illuminate(map,p,d,varargin)
%illuminate - QD with Voronoi Multi-dimensional Archive of Phenotypic Elites algorithm
%
% Syntax:  [map, percImproved, percValid, h, allMaps, percFilled] = illuminate(d.fitfun,map,p,d,varargin)
%
% Inputs:
%   d.fitfun - funct  - returns fitness of vector of individuals
%   map             - struct - initial solutions in F-dimensional map
%   p               - struct - Hyperparameters for algorithm, visualization, and data gathering
%   d               - struct - Domain definition
%
% Outputs:
%   map             - struct - population archive
%   percImproved    - percentage of children which improved on elites
%   percValid       - percentage of children which are valid members of selected classes
%   h               - [1X2]  - axes handle, data handle
%   allMap          - all maps created in sequence
%   percFilled      - percentage of map filled
%
%
% See also: createChildren, getBestPerCell, updateMap
%
% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jul 2019; Last revision: 04-Jul-2019

%------------- BEGIN CODE --------------
% View Initial Map

percImproved = 0;   percValid = 0;  h = 0;  percFilled = 0;
%figure(1);ax = gca;
stats = [];
iGen = 1;
while (iGen <= p.nGens)
    %% Create and Evaluate Children
    % Continue to remutate until enough children which satisfy geometric constraints are created
    children = [];
    while size(children,1) < p.nChildren
        newChildren = createChildren(map, p, d);
        validInds = feval(d.validate,newChildren,d);
        children = [children ; newChildren(validInds,:)] ; %#ok<AGROW>
    end
    children = children(1:p.nChildren,:);    
    [fitness, phenotypes] = d.fitfun(children,d); 
    % Ignore nan fitness
    nanfitness = isnan(fitness); children(nanfitness,:) = []; fitness(nanfitness,:) = []; phenotypes(nanfitness) = [];
    
    %% Add Children to Map
    features = p.categorize(children,phenotypes,p,d);

    [replaced, replacement] = nicheCompete(children, fitness, map, d, p, features);
    percImproved(iGen) = 100*sum(replacement)/length(replacement);
    map = updateMap(replaced,replacement,map,fitness,children,features,p.extraMapValues);
    
    map.stats.fitnessMean(iGen) = nanmean(map.fitness);
    map.stats.fitnessTotal(iGen) = nansum(map.fitness);
    
    allMaps{iGen} = map;
        
    if ~mod(iGen,25) || iGen==1
        disp([char(9) 'Illumination Generation: ' int2str(iGen) ' - % improved: ' num2str(percImproved(iGen)) ' - % Filled: ' num2str(100*(size(map.genes,1)/p.maxBins))]);        
        disp([char(9) 'Mean Fitness: ' num2str(map.stats.fitnessMean(iGen)) ' - Total Fitness: ' num2str(map.stats.fitnessTotal(iGen))]);        
        [~,phen] = fitfun(map.genes,d);
        allPhenotypes = [];
        for pp=1:length(phen)
            if ~islogical(phen{pp})
                allPhenotypes(pp,:) = imbinarize(phen{pp}(:),0.9*max(phen{pp}(:)));
            else
                allPhenotypes(pp,:) = phen{pp}(:);
            end
        end
        map.stats.diversity(iGen) = metricPD(allPhenotypes, 'hamming');
    
        disp([char(9) 'Pure Diversity: ' num2str(map.stats.diversity(iGen))]);        
    end
    iGen = iGen+1;
    
end
%if percImproved(end) > 0.05; disp('Warning: MAP-Elites finished while still making improvements ( >5% / generation )');end
end


%------------- END OF CODE --------------
