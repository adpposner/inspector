%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SaveIndivMetabsFlagUpdate
%% 
%%  Save individual metabolites to file in addition to basis set.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag fm

FCTNAME = 'SP2_MARSS_SaveIndivMetabsFlagUpdate';


%--- flag handling ---
flag.marssSaveIndiv = get(fm.marss.saveIndiv,'Value');

%--- update flag displays ---
set(fm.marss.saveIndiv,'Value',flag.marssSaveIndiv)

%--- window update ---
SP2_MARSS_MARSSWinUpdate


