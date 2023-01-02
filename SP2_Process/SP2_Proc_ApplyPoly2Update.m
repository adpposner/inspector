%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ApplyPoly2Update
%% 
%%  Switch for application of polynomial baseline on/off for spectrum 2.
%%
%%  03-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.procApplyPoly2 = get(fm.proc.applyPoly2,'Value');

%--- consistency check with poly 1 ---
if flag.procApplyPoly2
    flag.procApplyPoly1 = 0;
end

%--- window update ---
set(fm.proc.applyPoly1,'Value',flag.procApplyPoly1)
set(fm.proc.applyPoly2,'Value',flag.procApplyPoly2)

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

