%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Syn_ProcAndPlotFidOrig
%%
%%  Process and plot original FID of data set 1
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_ProcAndPlotFidOrig';


%--- init success flag ---
f_succ = 0;

%--- data assignment ---
if ~isfield(syn,'fidOrig')
    fprintf('%s ->\nFID does not exist. Load/assign first.\n\n',FCTNAME)
    return
end

%--- info printout: first FID points ---
if flag.verbose && syn.nspecCOrig>4
    fprintf('First data points of original FID 1:\n')
    for iCnt = 1:5
        if imag(syn.fidOrig(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(syn.fidOrig(iCnt)),imag(syn.fidOrig(iCnt)))
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(syn.fidOrig(iCnt)),abs(imag(syn.fidOrig(iCnt))))
        end
    end

    fprintf('\nLast data points of original FID 1:\n')
    for iCnt = syn.nspecCOrig-4:syn.nspecCOrig
        if imag(syn.fidOrig(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(syn.fidOrig(iCnt)),imag(syn.fidOrig(iCnt)))
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(syn.fidOrig(iCnt)),abs(imag(syn.fidOrig(iCnt))))
        end
    end
    fprintf('\n')
end

%--- figure creation ---
SP2_Syn_PlotFidOrig(1);        % forced new figure

%--- update success flag ---
f_succ = 1;

