%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SelectLrUpdate
%% 
%%  Select single FID/spectrum along left-to-right dimension.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi


%--- update amplitude window ---
mrsi.selectLR = str2double(get(fm.mrsi.selectLR,'String'));

%--- consistency check ---
mrsi.selectLR = max(mrsi.selectLR,1);
set(fm.mrsi.selectLR,'String',sprintf('%.0f',mrsi.selectLR))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
