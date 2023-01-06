%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_read = SP2_MRSI_DataAndParsAssign1
%% 
%%  Assignment of data:
%%  1) experimental
%%  2) load from MRSI page
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_MRSI_DataAndParsAssign1';


%--- init read flag ---
f_read = 0;

%--- field map assignment ---
if flag.mrsiData==0         % experiment
    %--- import experimental data ---
    if ~SP2_MRSI_DataAssignExp1
        fprintf('%s ->\nData assignment of FID 1 from experiment page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nExperimental data/parameters assigned as FID 1\n',FCTNAME);
elseif flag.mrsiData==1     % processing sheet
    %--- import FID from processing sheet ---
    if ~SP2_MRSI_Spec1DataLoadFromProc
        fprintf('%s ->\nData assignment of FID 1 from processing page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nFID 1 directly imported from the processing sheet\n',FCTNAME);
else
    %--- info printout ---
    fprintf('%s ->\nInvalid data/pars flag value flag.mrsiData=%.0f\n',FCTNAME,flag.mrsiData);
    return
end

%--- update read flag ---
f_read = 1;

end
