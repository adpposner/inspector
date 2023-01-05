%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignPolyOrderDec
%% 
%%  Decrease order of polynomial alignment.
%%
%%  08-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- keep old value ---
procAlignPolyOrder = proc.alignPolyOrder;

%--- update percentage value ---
proc.alignPolyOrder = max(proc.alignPolyOrder - 1,0);
set(fm.proc.alignPolyOrder,'String',num2str(proc.alignPolyOrder))

%--- reset polynomial coefficients ---
if proc.alignPolyOrder<procAlignPolyOrder
    proc.spec1.polycoeff = zeros(1,11);      % polynomial coefficients 0..10th order
    proc.spec2.polycoeff = zeros(1,11);      % polynomial coefficients 0..10th order
    fprintf('Info: Polynomial coefficients reset\n');
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
