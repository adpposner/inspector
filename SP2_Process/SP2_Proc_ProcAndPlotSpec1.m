%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcAndPlotSpec1( f_new )
%%
%%  Process and plot manipulated spectrum of data set 1
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag proc

FCTNAME = 'SP2_Proc_ProcAndPlotSpec1';


%--- check data existence ---
if ~isfield(proc.spec1,'fidOrig') ||  ~isfield(proc.spec1,'nspecCOrig')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- data processing ---
if flag.procUpdateCalc
    if ~SP2_Proc_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif ~isfield(proc.spec1,'spec')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- figure creation ---
if ~SP2_Proc_PlotSpec1(f_new)        % forced new figure
    return
end

%--- figure selection ---
flag.procFigSelect = 1;


