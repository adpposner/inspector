%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmCalibUpdate
%% 
%%  Update frequency calibration
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update percentage value ---
proc.ppmCalib = str2num(get(fm.proc.ppmCalib,'String'));
set(fm.proc.ppmCalib,'String',num2str(proc.ppmCalib))

%--- ppm position update ---
if flag.procPpmShowPos
    SP2_Proc_PpmShowPosValUpdate
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
