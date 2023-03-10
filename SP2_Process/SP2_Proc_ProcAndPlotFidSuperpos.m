%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcAndPlotFidSuperpos( f_new )
%%
%%  Process and plot superposition of FIDs.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag proc

FCTNAME = 'SP2_Proc_ProcAndPlotFidSuperpos';


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
elseif ~isfield(proc.spec1,'fid') || ~isfield(proc.spec2,'fid')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- figure creation ---
if ~SP2_Proc_PlotFidSuperpos(f_new)        % forced new figure
    return
end

end
