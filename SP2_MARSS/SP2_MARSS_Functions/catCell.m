function [catMat] = catCell(dimensionToConcatenate,inputCell)

if (length(inputCell) > 1)
    catMat = cat(dimensionToConcatenate,inputCell{1},inputCell{2});
else
    catMat = inputCell{1};
end
for ii = 3:length(inputCell)
    catMat = cat(dimensionToConcatenate,catMat,inputCell{ii});
end