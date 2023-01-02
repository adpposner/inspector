%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_ProtocolSave
%% 
%%  Save current SPEC paraemeter set as protocol
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data

FCTNAME = 'SP2_Data_ProtocolSave';


%--- init success flag ---
f_succ = 0;

%--- check directory access ---
if ~SP2_CheckDirAccessR(data.protDir)
    fprintf('%s ->\nDesignated protocol directory is not accessible.\nProgram aborted.\n',FCTNAME);
    return
end

%--- check write permissions ---
if ~SP2_CheckDirWritePermR(data.protDir)
    fprintf('%s ->\nDesignated protocol directory does not have write permissions.\nPlease choose a different one.\n',FCTNAME);
    return
end

%--- keep path ---
dataProtPathMat = data.protPathMat;

%--- info printout ---
fprintf('Protocol saved as <%s>\n',data.protPathMat);

%--- exit SPX ---
SP2_Exit_ExitFct(data.protPathMat)

%--- restart SPX ---
INSPECTOR(dataProtPathMat)

%--- update success flag ---
f_succ = 1;
