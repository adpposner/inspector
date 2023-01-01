%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AnaTOneModeFixedUpdate
%% 
%%  Leave T1 components flexible in multi-exponential fit.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.mmAnaTOneMode = get(fm.mm.anaTOneModeFix,'Value');

%--- switch radiobutton ---
set(fm.mm.anaTOneModeFix,'Value',flag.mmAnaTOneMode)
set(fm.mm.anaTOneModeFlex,'Value',~flag.mmAnaTOneMode)

%--- update window ---
SP2_MM_MacroWinUpdate


