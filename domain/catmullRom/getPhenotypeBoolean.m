function [booleanMap,flatbooleanMap] = getPhenotypeBoolean(polyshapes,varargin)
%GETPHENOTYPEBOOLEAN Summary of this function goes here
%   [flatbooleanMap,booleanMap] = getPhenotypeBoolean(polyshapes,varargin)
%   resolution = 64; if nargin>1;resolution = varargin{1};end

resolution = 64; if nargin>1;resolution = varargin{1};end

if isempty(polyshapes)
    flatbooleanMap = [];
    booleanMap = [];
    return;
end

for i=1:length(polyshapes)
    if isa(polyshapes{i},'polyshape')
        pixelCoordinates = ceil(polyshapes{i}.Vertices*(resolution))+resolution/2;
        pixelCoordinates(all(isnan(pixelCoordinates)'),:) = [];
        booleanMap{i} = poly2mask(pixelCoordinates(:,1),pixelCoordinates(:,2),resolution,resolution);
    else
        booleanMap{i} = zeros(resolution,resolution);
    end
end


flatbooleanMap = cat(3,[],booleanMap{:});
flatbooleanMap = reshape(flatbooleanMap,[],size(flatbooleanMap,3));
flatbooleanMap = flatbooleanMap';

end

