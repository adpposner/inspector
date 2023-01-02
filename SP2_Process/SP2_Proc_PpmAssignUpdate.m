%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmAssignUpdate
%% 
%%  Update frequency assignment value in [ppm].
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc


%--- update percentage value ---
proc.ppmAssign = str2num(get(fm.proc.ppmAssign,'String'));
set(fm.proc.ppmAssign,'String',num2str(proc.ppmAssign))

%--- window update ---
SP2_Proc_ProcessWinUpdate

