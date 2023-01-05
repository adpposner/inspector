%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_RecoZeroPhaseInc
%% 
%%  10 degrees increment of PHC0.
%%
%%  08-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm


%--- zero order phase offset ---
mm.phaseZero = mm.phaseZero + 10;
set(fm.mm.phaseZero,'String',num2str(mm.phaseZero))

%--- window update ---
SP2_MM_MacroWinUpdate


