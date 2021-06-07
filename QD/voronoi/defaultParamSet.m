function p = defaultParamSet(varargin)
% defaultParamSet - loads default parameters for QD algorithm with Voronoi
% feature space
%
% Syntax:  p = defaultParamSet(varargin)
%
% Outputs:
%   p      - struct - QD configuration struct
%
% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Nov 2019; Last revision: 13-Nov-2019
%
%------------- BEGIN CODE --------------

p.nGens                     = 2^10;     % number of generations
p.nChildren                 = 2^5;      % number of children per generation
p.mutSigma                  = 0.1;      % mutation drawn from Gaussian distribution with this \sigma
p.maxBins                   = 512;    
p.extraMapValues            = {};       % user defined metrics per solution

end


%------------- END OF CODE --------------