clear;clc;
%%
DOF = 16;DOMAIN = 'catmullRom';ALGORITHM = 'grid';LATENTMODEL = 'VAE';
addpath(genpath('/home/alex/IPPM')); rmpath(genpath('domain')); addpath(genpath(['domain/' DOMAIN])); rmpath('QD/grid'); rmpath('QD/voronoi'); addpath(['QD/' ALGORITHM]); rmpath(genpath('latentmodels')); addpath(genpath(['latentmodels/' LATENTMODEL]));
d = domain(DOF);

initSamples = [ones(1,8) zeros(1,8)];
initSamples = [rand(1,8) 0.0*randn(1,8)];
%[~,polygons] = fitfun(initSamples,d);

%%
figs = figure(1);hold off;
[~,pgon,ctlPts] = showPhenotype(initSamples,d,figs);
hold on;
scatter(ctlPts{1}(:,2),ctlPts{1}(:,1),64,'w','filled')
scatter(ctlPts{1}(:,2),ctlPts{1}(:,1),32,'r','filled')
scatter(0,0,64,'w','filled')
scatter(0,0,32,'b','filled')
axis equal;

save_figures(figs,'.',['catmullrom_phenotype'],12,[4 4])
