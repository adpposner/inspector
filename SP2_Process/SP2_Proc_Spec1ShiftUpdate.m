%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ShiftUpdate
%% 
%%  Update line frequency shift [Hz] for spectrum 1
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- update percentage value ---
proc.spec1.shift = str2num(get(fm.proc.spec1ShiftVal,'String'));
set(fm.proc.spec1ShiftVal,'String',sprintf('%.3f',proc.spec1.shift))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
