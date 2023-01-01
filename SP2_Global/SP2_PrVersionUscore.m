%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function sTrNew = SP2_PrVersionUscore(sTring)
%%
%%  function sTring = printUnderscore(sTring)
%%  checks string for underscores and adds a '%' in front of each underscore.
%%  Doing so, the string can be printed (title, name,...) and MATLAB doesn't
%%  interpret the underscore as subscript command
%%
%%  Ch.Juchem, 03-2004
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--- init ---
sTrNew = '';

%--- format check ---
if ~SP2_Check4Str(sTring)
    return
end

%--- string formating ---
for icnt = 1:length(sTring)
    if strcmp(sTring(icnt),'_')
        sTrNew = [sTrNew '\'];
    end
    sTrNew = [sTrNew sTring(icnt)];
end


