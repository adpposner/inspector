%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ProcAndPlotFid
%%
%%  Process and plot manipulated FID.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag lcm

FCTNAME = 'SP2_LCM_ProcAndPlotFid';


%--- init success flag ---
f_succ = 0;

%--- data processing ---
if flag.lcmUpdateCalc
    if ~SP2_LCM_ProcLcmData
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif isfield(lcm,'spec')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- info printout: first FID points ---
if flag.verbose
    fprintf('First data points of processed FID:\n');
    for iCnt = 1:5
        if imag(lcm.fid(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(lcm.fid(iCnt)),imag(lcm.fid(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(lcm.fid(iCnt)),abs(imag(lcm.fid(iCnt))));
        end
    end

    fprintf('\nLast data points of processed FID:\n');
    for iCnt = lcm.nspecC-4:lcm.nspecC
        if imag(lcm.fid(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(lcm.fid(iCnt)),imag(lcm.fid(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(lcm.fid(iCnt)),abs(imag(lcm.fid(iCnt))));
        end
    end
    fprintf('\n');
end

%--- figure creation ---
if ~SP2_LCM_PlotLcmFid(1)        % forced new figure
    return
end

%--- update success flag ---
f_succ = 1;




end
