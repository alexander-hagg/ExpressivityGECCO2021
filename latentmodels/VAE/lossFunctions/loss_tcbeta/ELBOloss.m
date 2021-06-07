function [loss,reconstructionLoss,regTerm] = ELBOloss(x, xPred, zMean, zLogvar, z, epoch, numEpochs)
% https://github.com/google-research/disentanglement_lib/blob/master/disentanglement_lib/methods/unsupervised/vae.py
% https://github.com/google-research/disentanglement_lib/blob/master/disentanglement_lib/methods/shared/losses.py
% https://wandb.ai/syllogismos/disentanglement/reports/Introduction--VmlldzoxNjY3NQ

beta = 2;

% Gather data
zMean = double(gather(extractdata(zMean)))';
zLogvar = double(gather(extractdata(zLogvar)))';
if isa(z,'dlarray')
    z = gather(extractdata(z));
    z = squeeze(z);
end
z = z';

%% Reconstruction Error
reconstructionLoss = crossentropy(xPred,x,'TargetCategories','independent');

%% Regularization
% Google code
%klLoss = compute_gaussian_kl(zMean, zLogvar)
klLoss = (-.5 * mean (sum(1 + zLogvar - zMean.^2 - exp(zLogvar), 2)));
%annealingScalar = linear_annealing(0, 1, epoch, numEpochs);
tc = (beta - 1) * total_correlation(z, zMean, zLogvar);
regTerm = klLoss + tc;

% Convert to correct datatype for dl/gpu
temp = zeros(1,1,1,size(regTerm,1));temp(1,1,1,:) = regTerm;regTerm = dlarray(single(temp), 'SSCB');regTerm = gpuArray(regTerm);
loss = mean(reconstructionLoss + regTerm);

% Extra outputs for logging
reconstructionLoss = mean(reconstructionLoss);
regTerm = mean(regTerm);
regTerm = gpuArray(dlarray(regTerm));


function tc = total_correlation(z, zMean, zLogvar)
log_qz_prob = gaussian_log_density(z, zMean, zLogvar);
log_qz_product = sum(log(squeeze(sum(exp(log_qz_prob),2))),2);
log_qz = log(sum(exp(sum(log_qz_prob,3)),2));
tc = mean(log_qz - log_qz_product); 

function klLoss = compute_gaussian_kl(zMean, zLogvar)
klLoss = mean(0.5 * sum(zMean.^2 + exp(zLogvar) - zLogvar - 1, 2));
      
function logDensity = gaussian_log_density(z, zMean, zLogvar)
z = reshape(z,size(z,1),1,size(z,2));
zMean = reshape(zMean,1,size(zMean,1),size(zMean,2));
zLogvar = reshape(zLogvar,1,size(zLogvar,1),size(zLogvar,2));
normalization = log(2. * pi);
inv_sigma = exp(-zLogvar);
tmp = (z - zMean);
logDensity = - 0.5 .* (tmp .* tmp .* inv_sigma + zLogvar + normalization);

function anneal = linear_annealing(init, fin, step, maxSteps)
if step == 0
    anneal = fin;
    return;
end
if fin <= init
    disp('Annealing: final value is not larger than initial value!');
    anneal = fin;
    return;
end
delta = fin - init;
anneal = init + step*(delta/maxSteps);