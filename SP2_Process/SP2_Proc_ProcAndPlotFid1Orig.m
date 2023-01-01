%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcAndPlotFid1Orig( f_new )
%%
%%  Process and plot original FID of data set 1
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_ProcAndPlotFid1Orig';


%--- data assignment ---
if ~isfield(proc.spec1,'fidOrig') || ~isfield(proc.spec1,'nspecCOrig')
    fprintf('%s ->\nFID 1 does not exist. Load/assign first.\n\n',FCTNAME)
    return
end

%--- info printout: first FID points ---
if flag.verbose
    fprintf('First data points of original FID 1:\n')
    for iCnt = 1:5
        if imag(proc.spec1.fidOrig(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(proc.spec1.fidOrig(iCnt)),imag(proc.spec1.fidOrig(iCnt)))
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(proc.spec1.fidOrig(iCnt)),abs(imag(proc.spec1.fidOrig(iCnt))))
        end
    end

    fprintf('\nLast data points of original FID 1:\n')
    for iCnt = proc.spec1.nspecCOrig-4:proc.spec1.nspecCOrig
        if imag(proc.spec1.fidOrig(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(proc.spec1.fidOrig(iCnt)),imag(proc.spec1.fidOrig(iCnt)))
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(proc.spec1.fidOrig(iCnt)),abs(imag(proc.spec1.fidOrig(iCnt))))
        end
    end
    fprintf('\n')
end

%--- figure creation ---
if ~SP2_Proc_PlotFid1Orig(f_new)        % forced new figure
    return
end
