%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcAndPlotFid1( f_new )
%%
%%  Process and plot manipulated FID of data set 1
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag proc

FCTNAME = 'SP2_Proc_ProcAndPlotFid1';


%--- check data existence ---
if ~isfield(proc.spec1,'fidOrig') ||  ~isfield(proc.spec1,'nspecCOrig')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
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
    fprintf('First data points of processed FID 1:\n');
    for iCnt = 1:5
        if imag(proc.spec1.fid(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(proc.spec1.fid(iCnt)),imag(proc.spec1.fid(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(proc.spec1.fid(iCnt)),abs(imag(proc.spec1.fid(iCnt))));
        end
    end

    fprintf('\nLast data points of processed FID 1:\n');
    for iCnt = proc.spec1.nspecC-4:proc.spec1.nspecC
        if imag(proc.spec1.fid(iCnt))>0
            fprintf('%.0f) %.5f + i*%.5f\n',iCnt,real(proc.spec1.fid(iCnt)),imag(proc.spec1.fid(iCnt)));
        else
            fprintf('%.0f) %.5f - i*%.5f\n',iCnt,real(proc.spec1.fid(iCnt)),abs(imag(proc.spec1.fid(iCnt))));
        end
    end
    fprintf('\n');
end

%--- figure creation ---
if ~SP2_Proc_PlotFid1(f_new)        % forced new figure
    return
end
