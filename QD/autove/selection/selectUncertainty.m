function newObservations = selectUncertainty(candidates,uncertainty,p,minmax)
%SELECTERROR Summary of this function goes here
%   Detailed explanation goes here
numNewSolutions = ceil((p.selectPerc/100)*size(candidates,1));
if strcmp(minmax,'min')
    [~,sortID] = sort(uncertainty,'ascend');
elseif strcmp(minmax,'max')
    [~,sortID] = sort(uncertainty,'descend');
end
newObservations = candidates(sortID(1:numNewSolutions),:);

end

