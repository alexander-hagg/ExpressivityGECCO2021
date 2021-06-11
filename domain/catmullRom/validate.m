function validInds = validate(genomes,d)
%validate - Validate individuals
% Can be used to add validation of individuals to enforce constraints or
% prevent faulty, disallowed solutions
%
% Syntax:  validInds = validate(genomes,d)
%
% Inputs:
%    genomes        - [NxM] - N genomes with dof = M
%    d              - struct - Domain description struct
%
% Outputs:
%    validInds      - [Nx1] - Validation flags
%
%
% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Nov 2018; Last revision: 15-Aug-2019
%
%------------- BEGIN CODE --------------

%% All children are valid
validInds = true(1, size(genomes,1));
end

%------------- END CODE --------------