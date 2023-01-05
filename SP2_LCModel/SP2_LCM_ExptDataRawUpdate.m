%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ExptDataRawUpdate
%% 
%%  Update function for data path to export FID data.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm flag

FCTNAME = 'SP2_LCM_ExptDataRawUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
exptFidFileTmp = get(fm.lcm.exptDataPath,'String');
exptFidFileTmp = exptFidFileTmp;      % substitute / by \
if isempty(exptFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathRaw)
    return
end
if ~strcmp(exptFidFileTmp(end-3:end),'.raw')  && ~strcmp(exptFidFileTmp(end-3:end),'.RAW')
    fprintf('%s ->\nAssigned file is not a <.raw> file. Please try again...\n',FCTNAME);
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathRaw)
    return
end
set(fm.lcm.exptDataPath,'String',exptFidFileTmp)
lcm.expt.dataPathRaw = get(fm.lcm.exptDataPath,'String');
lcm.expt.dataPathTxt = [lcm.expt.dataPathRaw(1:end-4) '.txt'];
lcm.expt.dataPathMat = [lcm.expt.dataPathRaw(1:end-4) '.mat'];

%--- update paths ---
if flag.OS>0            % 1: linux, 2: mac
    slInd = find(lcm.expt.dataPathRaw=='/');
else                    % 0: PC
    slInd = find(lcm.expt.dataPathRaw=='\');
end
lcm.expt.dataDir     = lcm.expt.dataPathRaw(1:slInd(end));
lcm.expt.dataFileRaw = lcm.expt.dataPathRaw(slInd(end)+1:end);
lcm.expt.dataFileTxt = lcm.expt.dataPathTxt(slInd(end)+1:end);
lcm.expt.dataFileMat = lcm.expt.dataPathMat(slInd(end)+1:end);

%--- update flag display ---
SP2_LCM_LCModelWinUpdate

%--- update success flag ---
f_succ = 1;


