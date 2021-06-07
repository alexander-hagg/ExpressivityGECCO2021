function genomes = createShapeVariations(matchedParams,numShapes,scaling,rotation)
%CREATESHAPEVARIATIONS Summary of this function goes here
%   Detailed explanation goes here

DOF = size(matchedParams,2);

scaleArray = [scaling(1):(scaling(2)-scaling(1))/(numShapes-1):scaling(2)]';
rotationArray = [rotation(1):(rotation(2)-rotation(1))/(numShapes-1):rotation(2)]';

genomes = []; iter = 1;
for i=1:size(matchedParams,1)
    for j=1:length(scaleArray)
        for k=1:length(rotationArray)
            genomes(j,k,:) = [scaleArray(j).*matchedParams(i,1:DOF/2) rotationArray(k) + matchedParams(i,DOF/2+1:end)];
        end
    end
end

end

