%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function cellPrint = SP2_PrVersionUscoreCell(cellOrig)
%%
%%  function cEll = SP2_PrVersionUscoreCell(cEll)
%%  checks string for underscores and adds a '%' in front of each underscore.
%%  Doing so, the string can be printed (title, name,...) and MATLAB doesn't
%%  interpret the underscore as subscript command
%%
%%  Ch.Juchem, 04-2016
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--- init ---
cellPrint = {};

%--- format check ---
if ~SP2_Check4Cell(cellOrig)
    return
end

%--- field conversion ---
for cCnt = 1:length(cellOrig)
   cellPrint{cCnt} = SP2_PrVersionUscore(cellOrig{cCnt});
end




end
