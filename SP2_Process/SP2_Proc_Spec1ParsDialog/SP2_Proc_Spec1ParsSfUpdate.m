%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ParsSfUpdate
%% 
%%  Update SF.
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- parameter update ---
proc.spec1.sf = max(str2num(get(fm.proc.dialog1.sf,'String')),0);

%--- window update ---
set(fm.proc.dialog1.sf,'String',num2str(proc.spec1.sf))

end
