%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmShowDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignment of (zoomed) ppm range
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.mrsiPpmShow = get(fm.mrsi.ppmShowDirect,'Value');

%--- switch radiobutton ---
set(fm.mrsi.ppmShowFull,'Value',~flag.mrsiPpmShow)
set(fm.mrsi.ppmShowDirect,'Value',flag.mrsiPpmShow)

%--- update window ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
