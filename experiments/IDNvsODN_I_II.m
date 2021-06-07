clear;
%% Configuration
addpath(genpath(pwd))                           % Set path to all modules
DOF = 16;                                       % Degrees of freedom, Catmull-Rom spline domain
d = domain(DOF);                                % Domain configuration
baseFilename = ['catmullRom_Id'];


%% Create 5 base shapes
clear shapeParams
shapeParams(1,:) = [0.95 0.4 0.95 0.4 0.95 0.4 0.95 0.4 zeros(1,8)];
shapeParams(2,:) = [0.95 0.4 0.95 0.4 0.95 0.4 0.95 0.4 0.25 -0.25 0.25 -0.25 0.25 -0.25 0.25 -0.25];
shapeParams(3,:) = [0.95 0.6 0.95 0.6 0.95 0.6 0.95 0.6 zeros(1,8)];
shapeParams(4,:) = [0.25 0.3 0.95 0.3 0.25 0.3 0.95 0.3 zeros(1,8)];
shapeParams(5,:) = [0.2 0.9 0.95 0.9 0.2 0.9 0.95 0.9 zeros(1,8)];
fig(1) = figure(1); showPhenotypeBMP(reshape(shapeParams,[],16),d,fig(1))

%% Set shape variation parameters
numShapes = 16; scaling = [0.1 1.0]; rotation = [0 0.5*pi];
x = 1:numShapes; y = x; [X,Y] = ndgrid(x,y); 
clear selectedShapes;
selectedShapes{1} = [X(:),Y(:)];
midpoint = ceil(numShapes/2); 
des = ismember(selectedShapes{1}(:,1),[midpoint-3,midpoint-2,midpoint-1,midpoint,midpoint+1,midpoint+2,midpoint+3])&ismember(selectedShapes{1}(:,2),[midpoint-3,midpoint-2,midpoint-1,midpoint,midpoint+1,midpoint+2,midpoint+3]);
selectedShapes{2} = selectedShapes{1}(~des,:);
des = ismember(selectedShapes{1}(:,1),[midpoint-1,midpoint,midpoint+1]);
selectedShapes{3} = selectedShapes{1}(~des,:);
des = ismember(selectedShapes{1}(:,1),[numShapes-2,numShapes-1,numShapes]);
selectedShapes{4} = selectedShapes{1}(~des,:);

fig(2) = figure(2); hold off;
scatter(selectedShapes{1}(:,1),selectedShapes{1}(:,2),32,'k','filled');hold on;
scatter(selectedShapes{2}(:,1)+0.1,selectedShapes{2}(:,2)+0.1,32,'r','filled');hold on;
scatter(selectedShapes{3}(:,1)-0.1,selectedShapes{3}(:,2)-0.1,32,'g','filled');hold on;
scatter(selectedShapes{4}(:,1)-0.1,selectedShapes{4}(:,2)+0.1,32,'b','filled');hold on;


clear allGenomes phenotypes allModels

%%
latentDOFs = [4 8 16];
for rep=1:length(latentDOFs)
    % VAE configuration
    numLatentDims = latentDOFs(rep);
    m = cfgLatentModel('data/workdir',d.resolution, numLatentDims);

    for shapeID=1:size(shapeParams,1)
        disp(['Shape ID: ' int2str(shapeID)]);
        % Create shapes variations
        genomes = createShapeVariations(shapeParams(shapeID,:),numShapes,scaling,rotation);
        %showPhenotypeBMP(reshape(genomes,[],16),d);
        %pause(1);
        fileName = [baseFilename '_dof_' int2str(latentDOFs(rep))];
        %% Three datasets: last two miss part of the training data
        for i=1:4
            disp(['Model: ' int2str(i) '/4']);
            allGenomes{shapeID,i} = genomes;
            allGenomes{shapeID,i} = reshape(allGenomes{shapeID,i},[],d.dof);
            allGenomes{shapeID,i} = allGenomes{shapeID,i}(sub2ind([numShapes numShapes],selectedShapes{i}(:,1),selectedShapes{i}(:,2)),:);
            phenotypes{shapeID,i} = d.getPhenotype(allGenomes{shapeID,i});
            % Train models
            allModels{rep,shapeID,i} = trainFeatures(phenotypes{shapeID,i},m);
        end
        save(fileName);
        
    end
end

