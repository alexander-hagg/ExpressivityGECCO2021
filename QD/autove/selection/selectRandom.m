function newObservations = selectRandom(candidates,p)
%SELECTERROR Summary of this function goes here
%   Detailed explanation goes here
numNewSolutions = ceil((p.selectPerc/100)*size(candidates,1));
randomOrder = randperm(size(candidates,1));
randomOrder = randomOrder(1:numNewSolutions);
newObservations = candidates(randomOrder,:);

end

