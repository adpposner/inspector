%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_BasisDirPathUpdate
%% 
%%  Update function for basis directory
%%
%%  11-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss

FCTNAME = 'SP2_MARSS_BasisDirPathUpdate';


%--- check for existence of the assigned user name and adopt path name ---
basisDirTmp = get(fm.marss.basisDirPath,'String');
if isempty(basisDirTmp)
    fprintf('%s -> An empty entry is useless.\n',FCTNAME)
    set(fm.marss.basisDirPath,'String',marss.basis.fileDir)
    return
end
basisDirTmp = SP2_SlashWinLin(basisDirTmp);
basisDirTmp = SP2_GuaranteeFinalSlash(basisDirTmp);

%--- check directory accessibility ---
if ~SP2_CheckDirAccessR(basisDirTmp)
    set(fm.marss.basisDirPath,'String',marss.basis.fileDir)
    return
end    
set(fm.marss.basisDirPath,'String',basisDirTmp);
marss.basis.fileDir  = get(fm.marss.basisDirPath,'String');
marss.basis.filePath = [marss.basis.fileDir marss.basis.fileName];

