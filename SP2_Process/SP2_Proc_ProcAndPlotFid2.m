%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcAndPlotFid2( f_new )
%%
%%  Process and plot manipulated FID of data set 2
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag proc

FCTNAME = 'SP2_Proc_ProcAndPlotFid2';


%--- check data existence ---
if ~isfield(proc.spec2,'fidOrig') ||  ~isfield(proc.spec2,'nspecCOrig')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME);
    return
end

%--- data processing ---
if flag.procUpdateCalc
    if ~SP2_Proc_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- info printout: first FID points ---
if flag.verbose
    fprintf('First data points of processed FID 2:\n');
    for iCnt = 1:5
        if imag(proc.spec2.fid(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(proc.spec2.fid(iCnt)),imag(proc.spec2.fid(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(proc.spec2.fid(iCnt)),abs(imag(proc.spec2.fid(iCnt))));
        end
    end
    
    fprintf('\nLast data points of processed FID 2:\n');
    for iCnt = proc.spec2.nspecC-4:proc.spec2.nspecC
        if imag(proc.spec2.fid(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(proc.spec2.fid(iCnt)),imag(proc.spec2.fid(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(proc.spec2.fid(iCnt)),abs(imag(proc.spec2.fid(iCnt))));
        end
    end
    fprintf('\n');
end

%--- figure creation ---
if ~SP2_Proc_PlotFid2(f_new)        % forced new figure
    return
end

end
