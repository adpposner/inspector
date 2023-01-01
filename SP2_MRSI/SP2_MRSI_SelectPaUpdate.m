%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SelectPaUpdate
%% 
%%  Select single FID/spectrum along posterior-to-anterior dimension.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi


%--- update amplitude window ---
mrsi.selectPA = str2double(get(fm.mrsi.selectPA,'String'));

%--- consistency check ---
mrsi.selectPA = max(mrsi.selectPA,1);
set(fm.mrsi.selectPA,'String',sprintf('%.0f',mrsi.selectPA))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
