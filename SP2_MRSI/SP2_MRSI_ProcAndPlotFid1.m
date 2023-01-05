%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotFid1
%%
%%  Process and plot manipulated FID of data set 1
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag mrsi

FCTNAME = 'SP2_MRSI_ProcAndPlotFid1';


%--- data processing ---
if flag.mrsiUpdateCalc
    if ~SP2_MRSI_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif isfield(mrsi,'spec1')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- figure creation ---
SP2_MRSI_PlotFid1(1)        % forced new figure
