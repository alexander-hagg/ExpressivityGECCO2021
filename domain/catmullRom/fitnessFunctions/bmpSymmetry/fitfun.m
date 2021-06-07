function [fitness,phenotypes,rawFitness] = fitfun(input,d)
%fitfun - "ui compare to user selected shapes" fitness function
% Fitness is normalized between 0 and 1
%
% Syntax:  [fitness,phenotypes] = npolyObjective(genomes,d)
%
% Inputs:
%    genomes        - [NxM] - N genomes with dof = M
%    d              - cell - Domain configuration.
%
% Outputs:
%    fitness        - [Nx1] - Validation flags
%    phenotypes     - cell[Nx1] - phenotypes (to prevent recalculating
%                                 of phenotypes, we offer them back here
%
%
% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jul 2019; Last revision: 15-Aug-2019
%
%------------- BEGIN CODE --------------
if isempty(input); fitness = []; polygons = []; rawFitness = []; return; end

visualization = false; % Set to true to visualize each fitness evaluation

% Create bitmaps if input is in parameter space
if ~iscell(input)
    phenotypes = d.getPhenotype(input);
else
    phenotypes = input;
end

logicalPhenotypes = phenotypes;

for i=1:length(phenotypes)
    if ~islogical(phenotypes{i})
        %if max(phenotypes{i}(:)) < 0.5
        %    meanDistanceDiagonals(i) = nan;
        %    symmetryFitness(i) = nan;
        %    continue;
        %end
        logicalPhenotypes{i} = imbinarize(phenotypes{i},0.9*max(phenotypes{i}(:)));
    end
    [B,L] = bwboundaries(logicalPhenotypes{i},'noholes');
    countlargeBlobs = 0;
    blobMinSize = 5;
    for bb=1:length(B)
        if size(B{bb},1) > blobMinSize
            countlargeBlobs = countlargeBlobs + 1;
        end
    end
    if countlargeBlobs == 1
        %%
        id = 1; maxVal = size(B{1},1);
        for blobID=1:size(B,1)
            if size(B{blobID},1) > maxVal
                id = blobID; maxVal = size(B{blobID},1);
            end
        end
        boundary = B{id};
        % Get center of mass in pixels
        [row,col] = find(L==id);
        centerY = round(mean(col));
        centerX = round(mean(row));
        % Center around center of mass
        boundary = boundary-[centerX centerY];
        %normalize boundary coordinates for fitness function
        %normBoundary = mapminmax(boundary',-1,1)';

        %%
        if ~mod(size(boundary,1),2)==0; boundary(end,:) = []; end % Make even number # points
        a = boundary(1:ceil(end/2),:); % Take first half of points
        b = boundary(ceil(end/2)+mod(size(boundary,1)+1,2):end,:); % Second half of points
        distances = sqrt(sum(((a+b)'.^2),1));
        lengthAs = sqrt(sum((abs(a)'.^2),1));
        lengthBs = sqrt(sum((abs(b)'.^2),1));
        maxLengths = max(lengthAs,lengthBs); % For normalization of symmetric error (per boundary pixel pair)
        meanDistanceDiagonals(i) = mean(distances./maxLengths);
        symmetryFitness(i) = 1./(1 + meanDistanceDiagonals(i));
        
        if visualization
            figure(2);hold off;scatter(boundary(:,1),boundary(:,2));axis equal;
            hold on;scatter(0,0,32,'r','filled');
            title(symmetryFitness(i));
            drawnow;
            pause(1)
        end
    else
        meanDistanceDiagonals(i) = nan;
        symmetryFitness(i) = nan;
    end
end

rawFitness = meanDistanceDiagonals;
fitness = symmetryFitness';

% Limit fitness between 0 and 1
fitness(fitness>1) = 1;
fitness(fitness<0) = 0;

end

%------------- END CODE --------------