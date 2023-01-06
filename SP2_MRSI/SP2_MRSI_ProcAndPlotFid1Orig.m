%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotFid1Orig
%%
%%  Process and plot original FID of data set 1
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_ProcAndPlotFid1Orig';


%--- data assignment ---
if ~isfield(mrsi.spec1,'fidimg_orig')
    fprintf('%s ->\nFID image does not exist. Reconstruct first.\n\n',FCTNAME);
    return
end

%--- figure creation ---
SP2_MRSI_PlotFid1Orig(1)        % forced new figure

end
