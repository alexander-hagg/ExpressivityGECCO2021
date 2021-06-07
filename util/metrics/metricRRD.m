function [result,distMetric] = metricRRD(X, Y, XFit, YFit, varargin)
% metric: relative rank diversity
% returns rank diversity of X wrt Y (as well as Y wrt X, which is 1-x)

distMetric = 'euclidean';
if nargin > 4
    distMetric = varargin{1};
end

XIDs = 1:size(X,1);
YIDs = max(XIDs) + (1:size(Y,1));

allPts = [X;Y];
ptIDs = [XIDs,YIDs];
D = pdist2(allPts,allPts,distMetric);
D(logical(eye(size(D)))) = inf;

[sortedD, IDsorted] = sort(D,2,'ascend');
metricX = [];
betterXID = [];
for i=1:max(XIDs)
    nonMembership = IDsorted(i,:)>max(XIDs);
    cutoff = find(~nonMembership);
    cutoff = cutoff(1);
    if (cutoff-1) == 0
        % Member is closer to its own group, so will be counted towards
        % rank diversity if it is the best of the group
        tcutoff = find(nonMembership);
        betterFit = (XFit(i) > XFit(IDsorted(i,1:(tcutoff-1))) );
        if sum(betterFit) == length(betterFit)
            metricX(i) = 1;
            betterXID = [betterXID, i]
        else
            metricX(i) = 0;
        end
    else
        betterFit = (XFit(i) > YFit(IDsorted(i,1:(cutoff-1))-max(XIDs)) );
        metricX(i) = sum(betterFit);
    end
end


metricY = [];
for i=(max(XIDs)+1):max(YIDs)
    nonMembership = IDsorted(i,:) < min(YIDs);
    cutoff = find(~nonMembership);
    cutoff = cutoff(1);
    if (cutoff-1) == 0
        % Member is closer to its own group, so will be counted towards rank diversity
        tcutoff = find(nonMembership);
        betterFit = (YFit(i-max(XIDs)) > YFit(IDsorted(i,1:(tcutoff-1))-max(XIDs)) );
        if sum(betterFit) == length(betterFit)
            metricY(i) = 1;
        else
            metricY(i) = 0;
        end
    else
        betterFit = (YFit(i-max(XIDs)) > XFit(IDsorted(i,1:(cutoff-1))) );
        metricY(i) = sum(betterFit);
    end
    
end

result = [sum(metricX)/(sum(metricX)+sum(metricY)), sum(metricY)/(sum(metricX)+sum(metricY))];