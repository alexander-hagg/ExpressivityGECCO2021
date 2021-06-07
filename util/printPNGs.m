

pgon = d.getPhenotype(QD_genomes{3,rep});
[~,booleanMap32] = getPhenotypeBoolean(pgon,32);
[~,booleanMap64] = getPhenotypeBoolean(pgon,64);
[~,booleanMap128] = getPhenotypeBoolean(pgon,128);
mkdir('32');
mkdir('64');
mkdir('128');
writePhenoToDisk(booleanMap32,'32/.');
writePhenoToDisk(booleanMap64,'64/.');
writePhenoToDisk(booleanMap128,'128/.');
