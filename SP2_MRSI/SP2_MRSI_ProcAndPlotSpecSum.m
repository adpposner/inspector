%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotSpecSum
%%
%%  Process and plot sum of spectra.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_MRSI_ProcAndPlotSpecSum';


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
SP2_MRSI_PlotSpecSum(1)        % forced new figure

end
