%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ExptDataTxtUpdate
%% 
%%  Update function for data path to export FID data.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


FCTNAME = 'SP2_MRSI_ExptDataTxtUpdate';

%--- fid file assignment ---
exptFidFileTmp = get(fm.mrsi.exptDataPath,'String');
exptFidFileTmp = SP2_SlashWinLin(exptFidFileTmp);      % substitute / by \
if isempty(exptFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.mrsi.exptDataPath,'String',mrsi.expt.dataPathTxt)
    return
end
if ~strcmp(exptFidFileTmp(end-3:end),'.txt') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin1') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin2') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin3') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin4') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin5') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin6') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin7') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin8') && ...
   isempty(exptFidFileTmp=='.')
    fprintf('%s ->\nAssigned file is not a <.txt/.spinN/no ext.> file. Please try again...\n',FCTNAME);
    set(fm.mrsi.exptDataPath,'String',mrsi.expt.dataPathTxt)
    return
end
set(fm.mrsi.exptDataPath,'String',exptFidFileTmp)
mrsi.expt.dataPathTxt = get(fm.mrsi.exptDataPath,'String');
dotInd = find(mrsi.expt.dataPathTxt=='.');
if isempty(dotInd)
    mrsi.expt.dataPathMat = [mrsi.expt.dataPathTxt '.mat'];
else
    mrsi.expt.dataPathMat = [mrsi.expt.dataPathTxt(1:(dotInd(end)-1)) '.mat'];
end

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(mrsi.expt.dataPathTxt=='/');
else                        % 0: PC
    slInd = find(mrsi.expt.dataPathTxt=='\');
end
mrsi.expt.dataDir     = mrsi.expt.dataPathTxt(1:slInd(end));
mrsi.expt.dataFileTxt = mrsi.expt.dataPathTxt(slInd(end)+1:end);
mrsi.expt.dataFileMat = mrsi.expt.dataPathMat(slInd(end)+1:end);

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate




