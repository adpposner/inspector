%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_SpinSysAddAll
%% 
%%  Add all spin system from library to basis selection.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss fm

FCTNAME = 'SP2_MARSS_SpinSysAddAll';


%--- init success flag ---
f_succ = 0;

%--- check for existence of spin system library ---
if marss.spinSys.n==0
    fprintf('%s ->\nNo spin system library found. Load first.\n',FCTNAME);
    return
end

%--- add all spin systems to basis selection ---
marss.basis.select      = 1:marss.spinSys.n;
marss.basis.selectN     = length(marss.basis.select);
marss.basis.selectNames = marss.spinSys.nameCell(marss.basis.select);

%--- update basis selection ---
set(fm.marss.basisBox,'String',marss.basis.selectNames)

%--- update display ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;


end
