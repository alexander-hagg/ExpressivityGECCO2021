function normfeatures = predictFeatures(phenotypes,model)
%PREDICTFEATURES get latent features for AutoVE
%
% Syntax:  normfeatures = predictFeatures(phenotypes,model)
%
% Inputs:
%   phenotypes                - Phenotypes
%   model                     - Full VAE
%
% Outputs:
%   normfeatures              - Normalized features                  

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jun 2020; Last revision: 11-Jun-2021

features = getPrediction(phenotypes,model);
normfeatures = mapminmax('apply',features',model.latentNorm);
normfeatures = double(normfeatures');


end

