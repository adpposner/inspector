%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotFidSuperpos
%%
%%  Process and plot superposition of FIDs.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag mrsi

FCTNAME = 'SP2_MRSI_ProcAndPlotFidSuperpos';


%--- data processing ---
if flag.mrsiUpdateCalc
    if ~SP2_MRSI_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif ~isfield(mrsi,'spec1') || ~isfield(mrsi,'spec2')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
elseif ~isfield(mrsi.spec1,'fid') || ~isfield(mrsi.spec2,'fid')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- figure creation ---
SP2_MRSI_PlotFidSuperpos(1)        % forced new figure
