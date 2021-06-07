%% DEMO

% This demo contains two autoVE runs, one searching the domain's explicit
% encoding (parameter search, PS) and one searching in a VAE's latent space
% (latent search, LS)

% Note that the demo is configured to finish quite early. To get better
% results, use the proposed parameters (= BETTER)

% Note that the viewMap visualization automatically reduces the number of
% displayed features to 2 using principal component analysis. 

%% Configuration
clear;
addpath(genpath(pwd))                           % Set path
DOF = 16;                                       % Degrees of freedom for the Catmull-Rom spline domain
d = domain(DOF);                                % Catmull-Rom spline domain configuration
numInitSamples = 64;                            % Set number of initial solutions drawn from Sobol sequence (BETTER: 512)
latentDOFs = 2;                                 % Set VAE bottleneck (higher is more accurate) (BETTER: 16).
fileName = 'fileName';     

p = defaultParamSet();                          % Base Quality Diversity (QD) configuration (MAP-Elites)
p.nGens = 128;                                  % Set number of generations ((BETTER: 1024)

m = cfgLatentModel('data/workdir',d.resolution,latentDOFs); % VAE configuration
pm = autoVEParamSet(p,m);                       % autoVE configuration
pm.map.numInitSamples = numInitSamples;         % Set number of initial samples in VE
pm.map.maxBins = numInitSamples;                % Set maximum number of VE bins

%% Initialize solution set using space filling Sobol sequence in genetic space
sobSequence = scramble(sobolset(d.dof,'Skip',1e3),'MatousekAffineOwen');  sobPoint = 1;
initSamples = range(d.ranges').*sobSequence(sobPoint:(sobPoint+numInitSamples)-1,:)+d.ranges(:,1)';
[~,initPhenotypes] = fitfun(initSamples,d);
        
%% 1. Run autoVE, search in parameter space, niching in latent space of VAE
pm.categorize = @(geno,pheno,p,d) predictFeatures(pheno,p.model);       % Anonymous function pointing to VE's phenotypic categorization function (= VAE)
[mapPS, configPS, resultsPS] = autoVE(initSamples,pm,d);
save([fileName '.mat']);

%% 2. Run autoVE, search in latent space, niching in latent space of VAE
latentDomain = d; 
latentDomain.dof = latentDOFs;                  % Update domain degrees of freedom to VAE's latent space dimensionality
dimRange = [-3, 3]; latentDomain.ranges = repmat(dimRange,latentDOFs,1); % Set range of latent space to constrain search

% Reuse the VAE from the first run. Note that it was trained on the initial
% Sobol sequence. If you plan to run a stand-alone autoVE with latent
% search, please pretrain the VAE model
initSamplesLatent = getPrediction(initPhenotypes, resultsPS.models(1)); 
latentDomain.getPhenotype = @(latentCoords)sampleVAE(latentCoords,resultsPS.models(1).decoderNet);

[mapLS, configLS, resultsLS] = autoVE(initSamplesLatent,pm,latentDomain,resultsPS.models(1));        
save([fileName '.mat']);

%% Visualization of resulting archives
viewMap(mapPS,'fitness',d);
viewMap(mapLS,'fitness',d);

%% Visualization of resulting shapes
shapesPS = showPhenotypeBMP(mapPS.genes,d);

% Generate original bitmaps from latent coordinates
bitmapsVAE = sampleVAE(mapLS.genes,resultsLS.models(1).decoderNet);
shapesLS = showPhenotypeBMP(bitmapsVAE,latentDomain);

