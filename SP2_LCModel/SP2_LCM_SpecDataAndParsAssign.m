%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_LCM_SpecDataAndParsAssign(f_import)
%% 
%%  Assignment of data:
%%  1) load experimental data from Data page
%%  2) load data from Processing page
%%  3) load data from MRSI page
%%  4) load data from synthesis page
%%  5) load data from MARSS page
%%  6) load directly from LCM page
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag lcm

FCTNAME = 'SP2_LCM_SpecDataAndParsAssign';


%--- init read flag ---
f_succ = 0;

%--- field map assignment ---
if flag.lcmData==1         % experiment/Data page
    %--- import experimental data ---
    if ~SP2_LCM_SpecDataLoadFromDataPage
        fprintf('%s ->\nData assignment from experiment (Data) page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID imported from experiment (Data) page\n',FCTNAME);
elseif flag.lcmData==2     % Processing page
    %--- import FID from processing sheet ---
    if ~SP2_LCM_SpecDataLoadFromProcPage
        fprintf('%s ->\nData assignment from Processing page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID imported from the Processing page\n',FCTNAME);
elseif flag.lcmData==3     % MRSI page
    %--- import FID from MRSI sheet ---
    if ~SP2_LCM_SpecDataLoadFromMrsiPage
        fprintf('%s ->\nData assignment from MRSI page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID imported from MRSI page\n',FCTNAME);
elseif flag.lcmData==4     % Synthesis page
    %--- import FID from synthesis sheet ---
    if ~SP2_LCM_SpecDataLoadFromSynPage
        fprintf('%s ->\nData assignment from Synthesis page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID imported from the Synthesis page\n',FCTNAME);
elseif flag.lcmData==5     % MARSS page
    %--- import FID from processing sheet ---
    if ~SP2_LCM_SpecDataLoadFromMarssPage
        fprintf('%s ->\nData assignment from MARSS page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID imported from the MARSS page\n',FCTNAME);
elseif flag.lcmData==6     % LCModel page
    %--- import FID from LCModel sheet ---
    if ~SP2_LCM_SpecDataLoadFromLcmPage(f_import)
        fprintf('%s ->\nData assignment from LCModel page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID directly loaded from LCM page\n',FCTNAME);
else
    %--- info printout ---
    fprintf('%s ->\nInvalid data/pars flag value flag.lcmData=%.0f\n',FCTNAME,flag.lcmData);
    return
end

%--- info printout: first FID points ---
if flag.verbose
    fprintf('First data points of original FID 1:\n');
    for iCnt = 1:5
        if imag(lcm.fidOrig(iCnt))>0
            fprintf('%.0f) %.10f + i*%.10f\n',iCnt,real(lcm.fidOrig(iCnt)),imag(lcm.fidOrig(iCnt)));
        else
            fprintf('%.0f) %.10f - i*%.10f\n',iCnt,real(lcm.fidOrig(iCnt)),abs(imag(lcm.fidOrig(iCnt))));
        end
    end
    
    fprintf('\nLast data points of original FID 1:\n');
    for iCnt = lcm.nspecCOrig-4:lcm.nspecCOrig
        if imag(lcm.fidOrig(iCnt))>0
            fprintf('%.0f) %.10f + i*%.10f\n',iCnt,real(lcm.fidOrig(iCnt)),imag(lcm.fidOrig(iCnt)));
        else
            fprintf('%.0f) %.10f - i*%.10f\n',iCnt,real(lcm.fidOrig(iCnt)),abs(imag(lcm.fidOrig(iCnt))));
        end
    end
    fprintf('\n');
end

%--- export handling ---
lcm.expt.fid    = lcm.fid;
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;

%--- update read flag ---
f_succ = 1;
