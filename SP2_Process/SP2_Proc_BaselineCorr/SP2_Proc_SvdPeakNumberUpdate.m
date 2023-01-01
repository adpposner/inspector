%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SvdPeakNumberUpdate
%% 
%%  Update number of peaks (main components) to be considered with the SVD-
%%  based removal algorithm.
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- update amplitude window ---
proc.baseSvdPeakN = str2double(get(fm.proc.base.svdPeakN,'String'));
set(fm.proc.base.svdPeakN,'String',num2str(proc.baseSvdPeakN))

%--- window update ---
SP2_Proc_ProcessWinUpdate
