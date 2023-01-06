%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotSpec1
%%
%%  Process and plot manipulated spectrum of data set 1
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag mrsi

FCTNAME = 'SP2_MRSI_ProcAndPlotSpec1';


%--- data processing ---
if flag.mrsiUpdateCalc
    if ~SP2_MRSI_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif ~isfield(mrsi,'spec1')
    fprintf('%s ->\nSpectrum 1 does not exist. Load/reconstruct first.\n',FCTNAME);
    return
elseif ~isfield(mrsi.spec1,'specimg')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- figure creation ---
SP2_MRSI_PlotSpec1(1)        % forced new figure

end
