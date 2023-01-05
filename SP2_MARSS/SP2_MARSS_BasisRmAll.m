%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_BasisRmAll
%% 
%%  Remove all metabolites from basis selection.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss fm

FCTNAME = 'SP2_MARSS_BasisRmAll';


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

%--- remove all spin systems from basis selection ---
marss.basis.select      = [];
marss.basis.selectN     = 0;
marss.basis.selectNames = {};

%--- update basis selection ---
set(fm.marss.basisBox,'String',marss.basis.selectNames,'Value',[])

%--- update display ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;

