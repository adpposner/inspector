%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_BasisDirSelect
%% 
%%  Function for directory selection of basis set.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm marss

FCTNAME = 'SP2_MARSS_BasisDirSelect';

    
%--- check directory access ---
[f_succ,maxPath] = SP2_CheckDirAccessR(marss.basis.fileDir);
if ~f_succ
    marss.basis.fileDir = maxPath;
end
   
%--- directory selection ---
basisFileDir = uigetdir(marss.basis.fileDir,'Select basis directory:');
if ~basisFileDir            % buffer select cancelation
    fprintf('%s aborted.\n',FCTNAME);
    return
end
if ~SP2_CheckDirAccessR(basisFileDir)
    fprintf('%s -> assigned directory doesn''t exist or is not accessible, try again...\n',FCTNAME);
    return
end
marss.basis.fileDir = SP2_GuaranteeFinalSlash(basisFileDir);
set(fm.marss.basisDirPath,'String',marss.basis.fileDir)
marss.basis.filePath = [marss.basis.fileDir marss.basis.fileName];

