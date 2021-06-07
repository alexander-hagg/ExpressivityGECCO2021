function figHandle = visualizeSimspace(genomes,encodeFcn,simSpaceRes,getPhenotype)
%VISUALIZESIMSPACEPERTURBED Summary of this function goes here
%   Detailed explanation goes here
[phenotypes,booleanMap] = getPhenotype(genomes);
normSimSpace = encodeFcn(booleanMap);

%simspaceRanges = [min(normSimSpace(:)) max(normSimSpace(:))];
%normSimSpace = (normSimSpace-simspaceRanges(1))./range(simspaceRanges);

% Apply PCA to reduce to two dimensions
if size(normSimSpace,1) > 2
    [COEFF, SCORE, LATENT, TSQUARED, EXPLAINED] = pca(normSimSpace');
    disp(['First 2 principal components explain ' num2str(sum(EXPLAINED(1:2))) '% of the variance in the latent space']);
    normSimSpace = SCORE(:,1:2)';
    normSimSpace = mapminmax(normSimSpace,0,1);
end

axesLengths = [-1 -1; simSpaceRes+3 simSpaceRes+3];
cmap = parula(length(phenotypes));

figHandle = figure;
hold off;
for i=1:length(phenotypes)
    pheno = phenotypes{i};
    %pheno.Vertices = pheno.Vertices + ceil(normSimSpace(:,i)'*simSpaceRes);
    pheno.Vertices = pheno.Vertices + (normSimSpace(:,i)'*simSpaceRes);
    ax = gca;
    h = plot(pheno,'FaceColor',cmap(i,:),'EdgeColor',cmap(i,:),'FaceAlpha',0.1);
    hold on;
end
axis equal;
axis([axesLengths(1,1) axesLengths(2,1) axesLengths(1,2) axesLengths(2,2)]);
grid on;
xlabel('Similarity 1');
ylabel('Similarity 2');

end
