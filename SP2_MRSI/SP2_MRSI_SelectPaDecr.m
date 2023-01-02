%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SelectPaDecr
%% 
%%  Decrease posterior-to-anterior value of FID/spectrum selection.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi

%--- update window limit ---
mrsi.selectPA = max(mrsi.selectPA-1,1);
set(fm.mrsi.selectPA,'String',sprintf('%.0f',mrsi.selectPA))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
