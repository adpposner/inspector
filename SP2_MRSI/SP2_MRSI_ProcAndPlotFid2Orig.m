%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotFid2Orig
%%
%%  Process and plot original FID of data set 2
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_ProcAndPlotFid2Orig';


%--- data assignment ---
if ~isfield(mrsi.spec2,'fidOrig')
    fprintf('%s ->\nFID 2 does not exist. Load/assign first.\n\n',FCTNAME)
    return
end

%--- figure creation ---
SP2_MRSI_PlotFid2Orig(1)        % forced new figure
