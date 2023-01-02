%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_AmplWinMaxDecr
%% 
%%  10,000 [a.u.] amplitude decrease.
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi

%--- update window limit ---
mrsi.amplMax = mrsi.amplMax - 10000;
set(fm.mrsi.amplMax,'String',sprintf('%.0f',mrsi.amplMax))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
