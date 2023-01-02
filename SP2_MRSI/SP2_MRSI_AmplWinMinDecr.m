%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_AmplWinMinDecr
%% 
%%  10,000 [a.u.] amplitude decrease.
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi

%--- update window limit ---
mrsi.amplMin = mrsi.amplMin - 10000;
set(fm.mrsi.amplMin,'String',sprintf('%.0f',mrsi.amplMin))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
