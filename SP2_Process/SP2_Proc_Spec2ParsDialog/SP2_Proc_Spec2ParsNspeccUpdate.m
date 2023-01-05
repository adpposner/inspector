%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ParsNspeccUpdate
%% 
%%  Update number of complex points (i.e. FID length).
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- parameter update ---
proc.spec2.nspecC = max(round(str2num(get(fm.proc.dialog2.nspecC,'String'))),0);
proc.spec2.nspecCOrig = proc.spec2.nspecC;

%--- window update ---
set(fm.proc.dialog2.nspecC,'String',num2str(proc.spec2.nspecC))
