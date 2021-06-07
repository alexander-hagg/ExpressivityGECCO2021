function figHandle = visualizeSimspacePerturbed(genomes,encodeFcn,simSpaceRes,perturb,getPhenotype,selectDim,mainLabel)
%VISUALIZESIMSPACEPERTURBED Summary of this function goes here
%   Detailed explanation goes here
[phenotypes,booleanMap,~,flatbooleanMap] = getPhenotype(genomes);

normSimSpace = encodeFcn(genomes,booleanMap,flatbooleanMap);
simspaceRanges = [min(normSimSpace(:)) max(normSimSpace(:))];

normSimSpace = (normSimSpace-simspaceRanges(1))./range(simspaceRanges);

axesLengths = [-1 -1; simSpaceRes+3 simSpaceRes+3];
cmap = parula(length(phenotypes));

figHandle = figure;
subplot(ceil(sqrt(length(perturb)+1)),ceil(sqrt(length(perturb)+1)),1);
hold off;
for i=1:length(phenotypes)
    pheno = phenotypes{i};
    if numel(selectDim)==1
        pheno.Vertices(:,1) = pheno.Vertices(:,1) + ceil(normSimSpace(selectDim(1),i)'*simSpaceRes);
    else
        pheno.Vertices = pheno.Vertices + ceil(normSimSpace([selectDim(1),selectDim(2)],i)'*simSpaceRes);
    end
    plot(pheno,'FaceColor',cmap(i,:),'EdgeColor','k','FaceAlpha',0.2);
    hold on;
end
axis equal;
if numel(selectDim)==1
    axis([axesLengths(1,1) axesLengths(2,1) -1.5 1.5]);
else
    axis([axesLengths(1,1) axesLengths(2,1) axesLengths(1,2) axesLengths(2,2)]);
end
title([mainLabel]);

for k = 1:length(perturb)
    newGenomes = genomes;
    newGenomes(:,1:end/2) = newGenomes(:,1:end/2) + perturb(k)*randn(size(genomes,1),size(genomes,2)/2);
    newGenomes(:,end/2+1:end) = newGenomes(:,end/2+1:end) + perturb(k)*randn(size(genomes,1),size(genomes,2)/2);
    [newPhenotypes,newBooleanMap,~,flatbooleanMap] = getPhenotype(newGenomes);
    subplot(ceil(sqrt(length(perturb)+1)),ceil(sqrt(length(perturb)+1)),k+1);

    hold off;
    newSimspaceCoordinates = encodeFcn(newGenomes,newBooleanMap,flatbooleanMap);
    newSimspaceCoordinates = (newSimspaceCoordinates-simspaceRanges(1))./range(simspaceRanges);

    
    for j=1:length(newPhenotypes)
        pheno = newPhenotypes{j};
        if numel(selectDim)==1
            pheno.Vertices(:,1) = pheno.Vertices(:,1) + ceil(newSimspaceCoordinates(selectDim(1),j)'*simSpaceRes);
        else
            pheno.Vertices = pheno.Vertices + ceil(newSimspaceCoordinates([selectDim(1),selectDim(2)],j)'*simSpaceRes);
        end
        
        plot(pheno,'FaceColor',cmap(j,:),'EdgeColor','k','FaceAlpha',0.2);
        hold on;
    end
    axis equal;
    if numel(selectDim)==1
        axis([axesLengths(1,1) axesLengths(2,1) -1.5 1.5]);
    else
        axis([axesLengths(1,1) axesLengths(2,1) axesLengths(1,2) axesLengths(2,2)]);
    end
    
    title(['Perturbed: ' num2str(100*perturb(k)) '%']);
end
hold off


end
