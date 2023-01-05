%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_SpinSysAddSelected
%% 
%%  Add spin system selection to basis selection.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss fm

FCTNAME = 'SP2_MARSS_SpinSysAddSelected';


%--- init success flag ---
f_succ = 0;

%--- check for existence of spin system library ---
if marss.spinSys.n==0
    fprintf('%s ->\nNo spin system library found. Load first.\n',FCTNAME);
    return
end

%--- retrieve spin system selection ---
marss.spinSys.select = get(fm.marss.spinSysBox,'Value');

%--- check for selection ---
if ~isempty(marss.spinSys.select)
    %--- add to basis selection ---
    marss.basis.select      = unique([marss.basis.select marss.spinSys.select]);
    marss.basis.selectN     = length(marss.basis.select);
    marss.basis.selectNames = marss.spinSys.nameCell(marss.basis.select);

    %--- update basis selection ---
    set(fm.marss.basisBox,'String',marss.basis.selectNames)
else
    fprintf('%s ->\nNo spin system selected. Select and try again.\n',FCTNAME);
end

%--- update display ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;
