%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_JdeEfficiencyParsUpdate
%% 
%%  Parameter update for JDE efficiency calculation.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- parameter retrieval ---
proc.jdeEffPpmRg(1) = str2num(get(fm.proc.jdeEff.ppmRgMin,'String'));
proc.jdeEffPpmRg(1) = min(proc.jdeEffPpmRg);
set(fm.proc.jdeEff.ppmRgMin,'String',num2str(proc.jdeEffPpmRg(1)))

proc.jdeEffPpmRg(2) = str2num(get(fm.proc.jdeEff.ppmRgMax,'String'));
proc.jdeEffPpmRg(2) = max(proc.jdeEffPpmRg);
set(fm.proc.jdeEff.ppmRgMax,'String',num2str(proc.jdeEffPpmRg(2)))

proc.jdeEffOffset = str2num(get(fm.proc.jdeEff.offsetVal,'String'));

%--- window update ---
SP2_Proc_JdeEfficiencyWinUpdate


     