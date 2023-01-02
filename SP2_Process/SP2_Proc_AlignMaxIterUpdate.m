%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignMaxIterUpdate
%% 
%%  Update maximum number of iterations for spectra alignment.
%%
%%  03-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc


%--- retrieve value ---
proc.alignMaxIter = str2double(get(fm.proc.alignMaxIter,'String'));

%--- consistency check ---
proc.alignMaxIter = min(max(proc.alignMaxIter,10),1e3);

%--- figure update ---
set(fm.proc.alignMaxIter,'String',num2str(proc.alignMaxIter))

%--- window update ---
SP2_Proc_ProcessWinUpdate
