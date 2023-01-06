%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ParsNspeccUpdate
%% 
%%  Update number of complex points (i.e. FID length).
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- parameter update ---
proc.spec1.nspecC = max(round(str2num(get(fm.proc.dialog1.nspecC,'String'))),0);
proc.spec1.nspecCOrig = proc.spec1.nspecC;

%--- window update ---
set(fm.proc.dialog1.nspecC,'String',num2str(proc.spec1.nspecC))

end
