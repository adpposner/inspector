%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ParsSfUpdate
%% 
%%  Update SF.
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc


%--- parameter update ---
proc.spec2.sf = max(str2num(get(fm.proc.dialog2.sf,'String')),0);

%--- window update ---
set(fm.proc.dialog2.sf,'String',num2str(proc.spec2.sf))
