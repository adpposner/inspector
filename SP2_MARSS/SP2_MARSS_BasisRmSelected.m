%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_BasisRmSelected
%% 
%%  Remove selected spin system(s) from basis selection.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss fm

FCTNAME = 'SP2_MARSS_BasisRmSelected';


%--- init success flag ---
f_succ = 0;

%--- check for existence of basis selection ---
if ~isfield(marss.basis,'selectN')
    fprintf('%s ->\nThe basis selection is undefined. Nothing to be removed.\n',FCTNAME);
    return
end
if marss.basis.selectN==0
    fprintf('%s ->\nThe basis selection is empty. Nothing to be removed.\n',FCTNAME);
    return
end

%--- retrieve basis selection to be removed ---
selectRm = get(fm.marss.basisBox,'Value');

%--- remove selected ---
if ~isempty(selectRm)
    %--- add to basis selection ---
    marss.basis.select      = marss.basis.select(setdiff(1:marss.basis.selectN,selectRm));
    marss.basis.selectN     = length(marss.basis.select);
    marss.basis.selectNames = marss.spinSys.nameCell(marss.basis.select);

    %--- update basis selection ---
    if marss.basis.selectN>0
        set(fm.marss.basisBox,'String',marss.basis.selectNames,'Value',max(selectRm(1)-1,1))
    else
        set(fm.marss.basisBox,'String',marss.basis.selectNames,'Value',[])
    end
else
    fprintf('%s ->\nNo basis metabolite selected. Select and try again.\n',FCTNAME);
end

%--- update display ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;
