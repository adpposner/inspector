%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ParsSwhUpdate
%% 
%%  Update sweep width in Hertz.
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- parameter update ---
proc.spec2.sw_h = max(str2num(get(fm.proc.dialog2.swh,'String')),0);

%--- window update ---
set(fm.proc.dialog2.swh,'String',num2str(proc.spec2.sw_h))
