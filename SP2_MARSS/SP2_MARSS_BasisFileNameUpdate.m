%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_BasisFileNameUpdate
%% 
%%  Update function for file name of simulation basis set.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss

FCTNAME = 'SP2_MARSS_BasisFileNameUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
basisFileNameTmp = get(fm.marss.basisFileName,'String');
if isempty(basisFileNameTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME)
    set(fm.marss.basisFileName,'String',marss.basis.FileName)
    return
end
if ~strcmp(basisFileNameTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME)
    set(fm.marss.basisFileName,'String',marss.basis.FileName)
    return
end
set(fm.marss.basisFileName,'String',basisFileNameTmp)
marss.basis.fileName = get(fm.marss.basisFileName,'String');

%--- update path ---
marss.basis.filePath = [marss.basis.fileDir marss.basis.fileName];          % update .mat path

%--- update flag display ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;



