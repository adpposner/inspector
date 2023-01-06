%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotFidDiff
%%
%%  Process and plot difference of FIDs.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag mrsi

FCTNAME = 'SP2_MRSI_ProcAndPlotFidDiff';


%--- data processing ---
if flag.mrsiUpdateCalc
    if ~SP2_MRSI_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif ~isfield(mrsi,'fidDiff')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- figure creation ---
SP2_MRSI_PlotFidDiff(1)        % forced new figure

end
