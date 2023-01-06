%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_AmplAutoUpdate
%% 
%%  Updates radiobutton setting: automatic determination of reasonable
%%  amplitude limits
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.mrsiAmpl = ~get(fm.mrsi.amplAuto,'Value');

%--- switch radiobutton ---
set(fm.mrsi.amplAuto,'Value',~flag.mrsiAmpl)
set(fm.mrsi.amplDirect,'Value',flag.mrsiAmpl)

%--- update window ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
