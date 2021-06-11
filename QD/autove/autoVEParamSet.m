function p = autoVEParamSet(mapDefaults,AEDefaults)
%AUTOVEPARAMSET
% Auto-Voronoi-Elites configuration
%
% Syntax: config = autoVEParamSet(mapDefaults,AEDefaults)
%
% Inputs:
%   mapDefaults               - struct - VE configuration
%   AEDefaults                - struct - Autoencoder configuration
%
% Outputs:
%   p          - struct - configuration (p)

p.map                           = mapDefaults;
p.model                         = AEDefaults;
p.map.numInitSamples            = 512;

p.mutSelection                  = 0.1;
p.retryInvalid                  = true;

% Visualization and data management
p.display.illu                 = false;
p.display.illuMod              = 1;
end

