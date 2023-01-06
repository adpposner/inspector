%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcAndPlotSpecSum( f_new )
%%
%%  Process and plot sum of spectra.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag proc

FCTNAME = 'SP2_Proc_ProcAndPlotSpecSum';


%--- check data existence ---
if ~isfield(proc.spec1,'fidOrig') ||  ~isfield(proc.spec1,'nspecCOrig')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end
if ~isfield(proc.spec2,'fidOrig') ||  ~isfield(proc.spec2,'nspecCOrig')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME);
    return
end

%--- data processing ---
if flag.procUpdateCalc
    if ~SP2_Proc_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
else
    if ~SP2_Proc_ProcSpecSumAndDiffOnly
        fprintf('%s ->\nRe-calculation of sum/difference spectra failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- figure creation ---
if ~SP2_Proc_PlotSpecSum(f_new)        % forced new figure
    return
end

%--- figure selection ---
flag.procFigSelect = 4;

end
