%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmAssignUpdate
%% 
%%  Update frequency assignment value in [ppm].
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi


%--- update percentage value ---
mrsi.ppmAssign = str2num(get(fm.mrsi.ppmAssign,'String'));
set(fm.mrsi.ppmAssign,'String',num2str(mrsi.ppmAssign))

%--- window update ---
SP2_MRSI_MrsiWinUpdate


end
