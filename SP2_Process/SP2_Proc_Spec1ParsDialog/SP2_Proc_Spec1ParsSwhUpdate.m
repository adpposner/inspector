%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ParsSwhUpdate
%% 
%%  Update sweep width in Hertz.
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc


%--- parameter update ---
proc.spec1.sw_h = max(str2num(get(fm.proc.dialog1.swh,'String')),0);

%--- window update ---
set(fm.proc.dialog1.swh,'String',num2str(proc.spec1.sw_h))
