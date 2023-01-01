%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotSpecSuperpos
%%
%%  Process and plot superposition of spectra.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag mrsi

FCTNAME = 'SP2_MRSI_ProcAndPlotSpecSuperpos';


%--- data processing ---
if flag.mrsiUpdateCalc
    if ~SP2_MRSI_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME)
        return
    end
elseif ~isfield(mrsi,'spec1') || ~isfield(mrsi,'spec2')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME)
    return
elseif ~isfield(mrsi.spec1,'spec') || ~isfield(mrsi.spec2,'spec')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME)
    return
end

%--- figure creation ---
SP2_MRSI_PlotSpecSuperpos(1)        % forced new figure
