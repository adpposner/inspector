%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotSpec2
%%
%%  Process and plot manipulated spectrum of data set 2
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag mrsi

FCTNAME = 'SP2_MRSI_ProcAndPlotSpec2';


%--- data processing ---
if flag.mrsiUpdateCalc
    if ~SP2_MRSI_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif ~isfield(mrsi,'spec2')
    fprintf('%s ->\nSpectrum 2 does not exist. Load/reconstruct first.\n',FCTNAME);
    return
elseif ~isfield(mrsi.spec2,'spec')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- figure creation ---
SP2_MRSI_PlotSpec2(1)        % forced new figure
