%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_read = SP2_MRSI_DataAndParsAssignRef
%% 
%%  Assignment of data:
%%  1) experimental
%%  2) load from MRSI page
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_MRSI_DataAndParsAssignRef';


%--- init read flag ---
f_read = 0;

%--- field map assignment ---
if flag.mrsiData==0         % experiment
    %--- import experimental data ---
    if ~SP2_MRSI_DataAssignRef
        fprintf('%s ->\nData assignment of reference data from experiment page failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nExperimental data/parameters assigned as reference data\n',FCTNAME)
elseif flag.mrsiData==1     % processing sheet
    %--- import FID from processing sheet ---
    if ~SP2_MRSI_RefDataLoadFromProc
        fprintf('%s ->\nData assignment of reference data from processing page failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nReference data directly imported from the processing sheet\n',FCTNAME)
else
    %--- info printout ---
    fprintf('%s ->\nInvalid data/pars flag value flag.mrsiData=%.0f\n',FCTNAME,flag.mrsiData)
    return
end

%--- update read flag ---
f_read = 1;
