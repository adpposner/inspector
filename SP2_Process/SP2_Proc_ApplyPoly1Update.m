%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ApplyPoly1Update
%% 
%%  Switch for application of polynomial baseline on/off for spectrum 1.
%%
%%  03-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.procApplyPoly1 = get(fm.proc.applyPoly1,'Value');

%--- consistency check with poly 2 ---
if flag.procApplyPoly1
    flag.procApplyPoly2 = 0;
end

%--- window update ---
set(fm.proc.applyPoly1,'Value',flag.procApplyPoly1)
set(fm.proc.applyPoly2,'Value',flag.procApplyPoly2)

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

