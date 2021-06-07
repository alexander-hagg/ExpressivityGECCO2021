function [axHandle,phenotypes,ctlPts] = showPhenotype(genomes,d,phenoDistMult,varargin)
%showPhenotype - Either show an example phenotype, or, when given, show
%                multiple phenotypes that are positioned on predefined placement positions.
%                Yes, this visualization script does too many things at the same time.
%
% Syntax:   showPhenotype(genomes,d,varargin)
%
% Inputs:
%    figHandle      - [1] - figure handle
%    d              - struct - Domain description struct
%
% Optional Inputs:
%    varargin{1}    - [NxM] - genomes
%    varargin{2}    - [Nx2] - placement
%    varargin{3}    - [Nx1] - selection labels (1 or 2)
%
%
% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Aug 2019; Last revision: 15-Aug-2019
%
%------------- BEGIN CODE --------------
nShapes = size(genomes,1);
xPos = 0:ceil(sqrt(nShapes))-1; [X,Y] = ndgrid(xPos,xPos);
placement = [X(:) Y(:)]; placement = placement(1:nShapes,:); 
if nargin>3
    if ~isempty(varargin{1})
        axHandle = varargin{1};
    else
        figure();
        axHandle = gca;
    end
else
    figure();
    axHandle = gca;
end
if nargin>4
    if ~isempty(varargin{2})
        placement = varargin{2};
        if size(placement,2) > 2
            [~, pcascore, ~, ~, explained] = pca(placement);
            disp(['Placement Dimensionality > 2, running PCA to reduce to 2 dim., explained: ' num2str(100*sum(explained(1:2)))]);
            placement = pcascore(:,1:2);
        end
    end
end

if nargin>5
    clrs = varargin{3};
else
    clrs = [0 0 0];
end

if nargin>6
    faceAlpha = varargin{4};
else
    faceAlpha = ones(nShapes,1);
end


%%
placement(:,2) = -placement(:,2);
%placement =  phenoDistMult * mapminmax(placement',0,1)';
placement =  phenoDistMult * placement;
[phenotypes,ctlPts] = d.getPhenotype(genomes);
hold(axHandle,'off');
for i=1:nShapes
    % Change placement if necessary
    if isa(phenotypes{i},'polyshape')
        if exist('placement','var') && ~isempty(placement)
            phenotypes{i}.Vertices = [phenotypes{i}.Vertices(:,2) phenotypes{i}.Vertices(:,1)];
            phenotypes{i}.Vertices = phenotypes{i}.Vertices + placement(i,:);
        end    
        if size(clrs,1) == nShapes
            plot(axHandle,phenotypes{i},'FaceColor',clrs(i,:),'FaceAlpha',faceAlpha(i),'EdgeAlpha',faceAlpha(i));
        elseif ~isempty(clrs)
            plot(axHandle,phenotypes{i},'FaceColor',clrs(1,:),'FaceAlpha',faceAlpha(i),'EdgeAlpha',faceAlpha(i));
        else
            plot(axHandle,phenotypes{i},'FaceAlpha',faceAlpha(i),'EdgeAlpha',faceAlpha(i));
        end
        axHandle.Children(1).UserData.ID = i;
    end
    hold(axHandle,'on');
end

axHandle.XAxis.Visible = false;
axHandle.YAxis.Visible = false;
axHandle.Color = 'None';
end

