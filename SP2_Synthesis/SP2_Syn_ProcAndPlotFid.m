%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Syn_ProcAndPlotFid
%%
%%  Process and plot manipulated FID.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag syn

FCTNAME = 'SP2_Syn_ProcAndPlotFid';


%--- init success flag ---
f_succ = 0;

%--- data processing ---
if flag.synUpdateCalc
    if ~SP2_Syn_ProcData
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif isfield(syn,'spec')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- info printout: first FID points ---
if flag.verbose
    fprintf('First data points of processed FID:\n');
    for iCnt = 1:5
        if imag(syn.fid(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(syn.fid(iCnt)),imag(syn.fid(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(syn.fid(iCnt)),abs(imag(syn.fid(iCnt))));
        end
    end

    fprintf('\nLast data points of processed FID:\n');
    for iCnt = syn.nspecC-4:syn.nspecC
        if imag(syn.fid(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(syn.fid(iCnt)),imag(syn.fid(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(syn.fid(iCnt)),abs(imag(syn.fid(iCnt))));
        end
    end
    fprintf('\n');
end

%--- figure creation ---
SP2_Syn_PlotFid(1);        % forced new figure

%--- update success flag ---
f_succ = 1;

