%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ProcAndPlotFidOrig
%%
%%  Process and plot original FID of data set 1
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_ProcAndPlotFidOrig';


%--- init success flag ---
f_succ = 0;

%--- data assignment ---
if ~isfield(lcm,'fidOrig')
    fprintf('%s ->\nFID does not exist. Load/assign first.\n\n',FCTNAME);
    return
end

%--- info printout: first FID points ---
if flag.verbose
    fprintf('First data points of original FID 1:\n');
    for iCnt = 1:5
        if imag(lcm.fidOrig(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(lcm.fidOrig(iCnt)),imag(lcm.fidOrig(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(lcm.fidOrig(iCnt)),abs(imag(lcm.fidOrig(iCnt))));
        end
    end

    fprintf('\nLast data points of original FID 1:\n');
    for iCnt = lcm.nspecCOrig-4:lcm.nspecCOrig
        if imag(lcm.fidOrig(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(lcm.fidOrig(iCnt)),imag(lcm.fidOrig(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(lcm.fidOrig(iCnt)),abs(imag(lcm.fidOrig(iCnt))));
        end
    end
    fprintf('\n');
end

%--- figure creation ---
if ~SP2_LCM_PlotLcmFidOrig(1)        % forced new figure
    return
end

%--- update success flag ---
f_succ = 1;

