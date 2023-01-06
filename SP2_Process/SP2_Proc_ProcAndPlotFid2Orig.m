%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcAndPlotFid2Orig( f_new )
%%
%%  Process and plot original FID of data set 2
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_ProcAndPlotFid2Orig';


%--- data assignment ---
if ~isfield(proc.spec2,'fidOrig') || ~isfield(proc.spec2,'nspecCOrig')
    fprintf('%s ->\nFID 2 does not exist. Load/assign first.\n\n',FCTNAME);
    return
end

%--- info printout: first FID points ---
if flag.verbose
    fprintf('First data points of original FID 2:\n');
    for iCnt = 1:5
        if imag(proc.spec2.fidOrig(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(proc.spec2.fidOrig(iCnt)),imag(proc.spec2.fidOrig(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(proc.spec2.fidOrig(iCnt)),abs(imag(proc.spec2.fidOrig(iCnt))));
        end
    end
    
    fprintf('\nLast data points of original FID 2:\n');
    for iCnt = proc.spec2.nspecCOrig-4:proc.spec2.nspecCOrig
        if imag(proc.spec2.fidOrig(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(proc.spec2.fidOrig(iCnt)),imag(proc.spec2.fidOrig(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(proc.spec2.fidOrig(iCnt)),abs(imag(proc.spec2.fidOrig(iCnt))));
        end
    end
    fprintf('\n');
end

%--- figure creation ---
if ~SP2_Proc_PlotFid2Orig(f_new)        % forced new figure
    return
end

end
