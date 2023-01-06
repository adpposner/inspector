%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignAmpWeightUpdate
%% 
%%  Update amplitude weighting factor for spectrum alignment.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc

%--- update percentage value ---
proc.alignAmpWeight = min(max(str2double(get(fm.proc.alignAmpWeight,'String')),1e-5),1e3);
set(fm.proc.alignAmpWeight,'String',num2str(proc.alignAmpWeight))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
