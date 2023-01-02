%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ExptDataMatUpdate
%% 
%%  Update function for data path to export FID data.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


FCTNAME = 'SP2_MRSI_ExptDataMatUpdate';

%--- fid file assignment ---
exptFidFileTmp = get(fm.mrsi.exptDataPath,'String');
exptFidFileTmp = SP2_SlashWinLin(exptFidFileTmp);      % substitute / by \
if isempty(exptFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.mrsi.exptDataPath,'String',mrsi.expt.dataPathMat)
    return
end
if ~strcmp(exptFidFileTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME);
    set(fm.mrsi.exptDataPath,'String',mrsi.expt.dataPathMat)
    return
end
set(fm.mrsi.exptDataPath,'String',exptFidFileTmp)
mrsi.expt.dataPathMat = get(fm.mrsi.exptDataPath,'String');
mrsi.expt.dataPathTxt = [mrsi.expt.dataPathMat(1:end-4) '.txt'];

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: mac
    slInd = find(mrsi.expt.dataPathMat=='/');
else                            % 0: PC
    slInd = find(mrsi.expt.dataPathMat=='\');
end
mrsi.expt.dataDir     = mrsi.expt.dataPathMat(1:slInd(end));
mrsi.expt.dataFileMat = mrsi.expt.dataPathMat(slInd(end)+1:end);
mrsi.expt.dataFileTxt = mrsi.expt.dataPathTxt(slInd(end)+1:end);

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate




