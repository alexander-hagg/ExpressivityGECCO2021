function [Score,distMetric] = metricPD(samples, varargin)
%METRIC Pure Diversity
%------------------------------- Reference --------------------------------
% H. Wang, Y. Jin, and X. Yao, Diversity assessment in many-objective
% optimization, IEEE Transactions on Cybernetics, 2017, 47(6): 1510-1522.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------
% L0.1 norm is fixed in Pure Diversity
distMetric = 'minkowski';
if nargin > 1
    distMetric = varargin{1};
end


if isempty(samples)
    result = nan;
    return;
end


N = size(samples,1);
C = false(N);
C(logical(eye(size(C)))) = true;

if strcmp(distMetric,'minkowski')
    D = pdist2(samples,samples,distMetric,0.1);
else
    D = pdist2(samples,samples,distMetric);
end

D(logical(eye(size(D)))) = inf;
Score = 0;
for k = 1 : N-1
    while true
        [d,J] = min(D,[],2);
        [~,i] = max(d);
        if D(J(i),i) ~= -inf
            D(J(i),i) = inf;
        end
        if D(i,J(i)) ~= -inf
            D(i,J(i)) = inf;
        end
        P = any(C(i,:),1);
        while ~P(J(i))
            newP = any(C(P,:),1);
            if P == newP
                break;
            else
                P = newP;
            end
        end
        if ~P(J(i))
            break;
        end
    end
    C(i,J(i)) = true;
    C(J(i),i) = true;
    D(i,:)    = -inf;
    Score     = Score + d(i);
end
end

