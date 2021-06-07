function writePhenoToDisk(phenotypes,dir)
%WRITEPHENOTODISK Write phenotype images to disk

for i=1:length(phenotypes)
    imwrite(phenotypes{i},[dir '/' int2str(i) '.png'],'png');
end
end

