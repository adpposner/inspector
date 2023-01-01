%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_Proc_DataAndParsAssign1
%% 
%%  Assignment of data:
%%  1) experimental
%%  2) load from proc page
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag proc

FCTNAME = 'SP2_Proc_DataAndParsAssign1';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if flag.procData==1         % experiment
    %--- import experimental data ---
    if ~SP2_Proc_Spec1DataLoadFromData
        fprintf('%s ->\nData assignment of FID 1 from experiment page failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nExperimental data/parameters assigned as FID 1\n',FCTNAME)
elseif flag.procData==2     % processing sheet
    %--- import FID from processing sheet ---
    if ~SP2_Proc_Spec1DataLoadFromProc
        fprintf('%s ->\nData assignment of FID 1 from processing page failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID 1 directly imported from the processing sheet\n',FCTNAME)
elseif flag.procData==3     % MRSI sheet
    %--- import FID from MRSI sheet ---
    if ~SP2_Proc_Spec1DataLoadFromMrsi
        fprintf('%s ->\nData assignment of FID 1 from MRSI page failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID 1 imported from MRSI sheet\n',FCTNAME)
elseif flag.procData==4     % synthesis sheet
    %--- import FID from synthesis sheet ---
    if ~SP2_Proc_Spec1DataLoadFromSyn
        fprintf('%s ->\nData assignment of FID 1 from synthesis page failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID 1 imported from synthesis sheet\n',FCTNAME)
elseif flag.procData==5     % MARSS sheet
    %--- import FID from MARSS sheet ---
    if ~SP2_Proc_Spec1DataLoadFromMarss
        fprintf('%s ->\nData assignment of FID 1 from MARSS page failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID 1 imported from MARSS sheet\n',FCTNAME)
elseif flag.procData==6     % LCM sheet
    %--- import FID from LCM sheet ---
    if ~SP2_Proc_Spec1DataLoadFromLcm
        fprintf('%s ->\nData assignment of FID 1 from LCM page failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID 1 imported from LCM sheet\n',FCTNAME)
else
    %--- info printout ---
    fprintf('%s ->\nInvalid data/pars flag value flag.procData=%.0f\n',FCTNAME,flag.procData)
    return
end

%--- info printout: first FID points ---
if flag.verbose
    fprintf('First data points of original FID 1:\n')
    for iCnt = 1:5
        if imag(proc.spec1.fidOrig(iCnt))>0
            fprintf('%.0f) %.10f + i*%.10f\n',iCnt,real(proc.spec1.fidOrig(iCnt)),imag(proc.spec1.fidOrig(iCnt)))
        else
            fprintf('%.0f) %.10f - i*%.10f\n',iCnt,real(proc.spec1.fidOrig(iCnt)),abs(imag(proc.spec1.fidOrig(iCnt))))
        end
    end
    
    fprintf('\nLast data points of original FID 1:\n')
    for iCnt = proc.spec1.nspecCOrig-4:proc.spec1.nspecCOrig
        if imag(proc.spec1.fidOrig(iCnt))>0
            fprintf('%.0f) %.10f + i*%.10f\n',iCnt,real(proc.spec1.fidOrig(iCnt)),imag(proc.spec1.fidOrig(iCnt)))
        else
            fprintf('%.0f) %.10f - i*%.10f\n',iCnt,real(proc.spec1.fidOrig(iCnt)),abs(imag(proc.spec1.fidOrig(iCnt))))
        end
    end
    fprintf('\n')
end

%--- update read flag ---
f_succ = 1;
