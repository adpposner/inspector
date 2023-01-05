%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ResetSpec
%% 
%%  Function to exit and restart (i.e. reset) the SPEC software
%%  As a consequence, the current parameter set is written to file, all
%%  data is removed from the memory and recalculated if necessary.
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fmfig pars

FCTNAME = 'SP2_Data_ResetSpec';


%--- update window position ---
pars.figPos = get(fmfig,'Position');

%--- exit FMAP ---
SP2_Exit_ExitFct

%--- clear stuff ---
clear all

%--- restart FMAP ---
INSPECTOR
