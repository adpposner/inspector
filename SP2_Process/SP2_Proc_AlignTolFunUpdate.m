%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignTolFunUpdate
%% 
%%  Update order of tolerance range for spectra alignment.
%%
%%  03-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- retrieve value ---
proc.alignTolFun = str2double(get(fm.proc.alignTolFun,'String'));

%--- consistency check ---
proc.alignTolFun = min(max(proc.alignTolFun,1e-25),1e-3);

%--- figure update ---
set(fm.proc.alignTolFun,'String',sprintf('%g',proc.alignTolFun))

%--- window update ---
SP2_Proc_ProcessWinUpdate

end
