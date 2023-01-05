%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotSpecDiff
%%
%%  Process and plot difference of spectra.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_MRSI_ProcAndPlotSpecDiff';


%--- data processing ---
if flag.mrsiUpdateCalc
    if ~SP2_MRSI_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
else
    if ~SP2_MRSI_ProcSpecSumAndDiffOnly
        fprintf('%s ->\nRe-calculation of sum/difference spectra failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- figure creation ---
SP2_MRSI_PlotSpecDiff(1)        % forced new figure
