%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_OffsetPpmWinUpdate
%% 
%%  Update offset entries.
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- update amplitude window ---
proc.ppmOffsetMin = str2double(get(fm.proc.ppmOffsetMin,'String'));
proc.ppmOffsetMax = str2double(get(fm.proc.ppmOffsetMax,'String'));
set(fm.proc.ppmOffsetMin,'String',sprintf('%.2f',proc.ppmOffsetMin))
set(fm.proc.ppmOffsetMax,'String',sprintf('%.2f',proc.ppmOffsetMax))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
