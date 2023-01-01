%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [RowIndex,ColIndex] = SP2_MaxMatInd(matrix)
%%
%%  [RowIndex,ColIndex] = SP2_MaxMatInd(matrix)
%%  determination of the indices of the maximum value of a data matrix
%%
%%  Christoph Juchem, 10-2002
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[NoRows,NoColumns] = size(matrix);
if nargin ~= 1 
	fprintf('Usage : SP2_MaxMatInd(matrix)')
    return
end
[val1,ind1] = max(matrix);      % min of columns
[val2,ind2] = max(val1);

RowIndex    = ind1(ind2);
ColIndex    = ind2;

fakeline = 1;


