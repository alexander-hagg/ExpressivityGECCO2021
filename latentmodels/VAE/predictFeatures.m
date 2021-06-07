function normfeatures = predictFeatures(phenotypes,model)
%GETAEFEATURES Summary of this function goes here
%   Detailed explanation goes here
features = getPrediction(phenotypes,model);
%if size(features,2) > 2
%    features = features*model.pcaCoeff;
%end

normfeatures = mapminmax('apply',features',model.latentNorm);
normfeatures = double(normfeatures');


end

