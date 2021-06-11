function [axHandle, imageHandle, cHandle] = viewMap(map, mapValueStr, d, varargin)
%VIEWMAP - View Map
%
% Syntax:  [axHandle, imageHandle, cHandle] = viewMap(map, mapValueStr, d, varargin)
%
% Inputs:
%   map         - struct - feature map
%   mapValueStr - string - indicates which value from the map is displayed
%   d           - struct - Domain definition
%
% Outputs:
%   axHandle    - handle of resulting axis object
%   imageHandle - handle of resulting map image
%   cHandle     - handle of colorbar
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: createMap, updateMap, createPredictionMap

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Jul 2019; Last revision: 15-Aug-2019

%------------- BEGIN CODE --------------
if nargin > 3; axHandle = varargin{1}; else; figure; axHandle = gca;end

%% PCA when dimensionality of feature space is larger than 2
elites = map.features;

if size(elites,2) > 2
    [~, SCORE] = pca(elites);
    elites = SCORE(:,[1 2]);
end

[elites] = unique(elites,'rows');
value = eval(['map.' mapValueStr '(ids)']);
hold(axHandle,'off');
h = imagesc(axHandle,1);delete(h);

[v,c]=voronoin(double(elites));
imageHandle = voronoi(axHandle,elites(:,1),elites(:,2));
v1 = shiftdim(reshape([imageHandle(2).XData;imageHandle(2).YData],2,3,[]),2); % Arranged one edge per row, one vertex per slice in the third dimension
nUnbounded = sum(cellfun(@(ic)ismember(1,ic),c));
v1Unbounded = v1(end-(nUnbounded-1):end,:,:);
[~,iBounded] = min(pdist2(v,v1Unbounded(:,:,1))); % Index of the bounded vertex
vUnbounded = v1Unbounded(:,:,2); % Displayed coordinate of the unbounded end of the cell edge

l = 0;
maxPatch = 100;
patchesX = nan(maxPatch,size(elites,1));patchesY = nan(maxPatch,size(elites,1));
for s=1:size(elites,1)
    l=l+1;
    if l > length(c); continue;end
    cPatch = c{l}; % List of vertex indices
    vPatch = v(cPatch,:); % Vertex coordinates which may contain Inf
    idx = find(cPatch==1); % Check if cell has unbounded edges
    if idx
        cPatch = circshift(cPatch,-idx); % Move the 1 to the end of the list of vertex indices
        vPatch = [vPatch(1:idx-1,:)
            vUnbounded(iBounded == cPatch(end-1),:)
            vUnbounded(iBounded == cPatch(1),:)
            vPatch(idx+1:end,:)]; % Replace Inf values at idx with coordinates from the unbounded edges that meet the two adjacent finite vertices
    end
    vPatch = padarray(vPatch,[maxPatch-size(vPatch,1) 1],'replicate','post');
    patchesX(1:length(vPatch(:,1)),s) = vPatch(:,1);
    patchesY(1:length(vPatch(:,2)),s) = vPatch(:,2);
end

hold(axHandle,'on');
patch(axHandle,patchesX,patchesY,value);
cmap = hot(33); cmap(end,:) = [];
colormap(axHandle,cmap);
cHandle = colorbar(axHandle);
cHandle.Label.String = mapValueStr;
scatter(axHandle,elites(:,1),elites(:,2),8,[0 0 0],'filled');
ax = gca;
ax.XTick = [];
ax.YTick = [];
%axis(axHandle,[min(elites(:,1)) max(elites(:,1)) min(elites(:,2)) max(elites(:,2))]);
axis([0 1 0 1]);
%axis(axHandle,'equal');

xlabel(axHandle, [d.featureLabels{1} '\rightarrow']);
ylabel(axHandle, ['\leftarrow' d.featureLabels{2}]);



%------------- END OF CODE --------------