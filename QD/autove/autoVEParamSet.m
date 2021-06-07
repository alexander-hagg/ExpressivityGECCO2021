function config = autoVEParamSet(mapDefaults,AEDefaults)

config.map                           = mapDefaults;
config.model                         = AEDefaults;
config.map.numInitSamples            = 512;

config.mutSelection                  = 0.1;
config.retryInvalid                  = true;

% Visualization and data management
config.display.illu                 = false;
config.display.illuMod              = 1;
end

