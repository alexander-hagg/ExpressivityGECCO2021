function [map,p,stats] = autoVE(observations,p,d,varargin)
%AUTOVE
% Main run script of autoVE algorithm
%
% Syntax: [map,configs,stats] = autoVE(observations,p,d,varargin)
%
% Inputs:
%   observations    - [NXM] - observations/genomes
%   p               - struct - Voronoi-Elites configuration
%   d               - struct - domain configuration
%
% Outputs:
%   map             - struct - population archive
%   p               - struct - Voronoi-Elites configuration
%   stats           - struct - statistics

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Nov 2019; Last revision: 12-Nov-2019

p.map.categorize = p.categorize;

if p.display.illu
    figID = 2;
    figPhenotypes = figure(figID);hold off;
end

% 1. Train VAE
if nargin > 3
   disp('User provided pretrained latent model');
    p.map.model = varargin{1};
    [fitness,phenotypes] = fitfun(observations,d);
    features = p.categorize(observations,phenotypes,p.map,d);
else
    disp('Training latent model');
    [fitness,phenotypes] = fitfun(observations,d);
    p.map.model = trainFeatures(phenotypes,p.model);
    features = p.categorize(observations,phenotypes,p.map,d);
end
stats.models = p.map.model;

if p.display.illu
    figure(figPhenotypes); subplot(2,2,1);
    fits = fitfun(observations,d);
    fitcolor = [0 1 0].*fits + [1 0 0].*(1-fits); fitcolor = discretize(fitcolor,0:0.25:1)./5;
    showPhenotype(observations,d,figPhenotypes,features,fitcolor); drawnow;
end

% 2. Illuminate with QD
disp('Illuminate latent space with QD');
map = createMap(d, p.map);
[replaced, replacement] = nicheCompete(observations,fitness,map,d,p.map,features);
map = updateMap(replaced,replacement,map,fitness,observations,features);
map = illuminate(map,p.map,d,p.model);

% 3. Statistics
disp('Get statistics');
stats.fitness.mean = nanmean(map.fitness(:)); stats.fitness.median = nanmedian(map.fitness(:)); stats.fitness.std = nanstd(map.fitness(:)); stats.fitness.total = nansum(map.fitness(:));
stats.elites.number = sum(~isnan(map.fitness(:)));
stats.map = map;

if p.display.illu
    figure(figPhenotypes);
    subplot(2,2,3)
    fits = fitfun(observations,d);
    fitcolor = [0 1 0].*fits + [1 0 0].*(1-fits);
    fitcolor = discretize(fitcolor,0:0.25:1)./5;
    showPhenotype(observations,d,figPhenotypes,features,fitcolor);
    drawnow;

    features = p.categorize(observations,phenotypes,p.map,d);
    figure(figPhenotypes);
    subplot(1,p.numIterations+1,iter+1)
    fits = fitfun(observations,d);
    fitcolor = [0 1 0].*fits + [1 0 0].*(1-fits);
    fitcolor = discretize(fitcolor,0:0.25:1)./5;
    showPhenotype(observations,d,figPhenotypes,features,fitcolor);
    drawnow;
end

end
