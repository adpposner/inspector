%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_SpinSysLibPathUpdate
%% 
%%  Update function for file path of spin system library file.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss flag

FCTNAME = 'SP2_MARSS_SpinSysLibPathUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
spinSysLibPathTmp = get(fm.marss.spinSysLibPath,'String');
spinSysLibPathTmp = spinSysLibPathTmp;
if isempty(spinSysLibPathTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.marss.spinSysLibPath,'String',marss.spinSys.libPath)
    return
end
if ~strcmp(spinSysLibPathTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME);
    set(fm.marss.spinSysLibPath,'String',marss.spinSys.libPath)
    return
end
set(fm.marss.spinSysLibPath,'String',spinSysLibPathTmp)
marss.spinSys.libPath = get(fm.marss.spinSysLibPath,'String');

%--- update paths ---
if flag.OS>0            % 1: linux, 2: mac
    slInd = find(marss.spinSys.libPath=='/');
else                    % 0: PC
    slInd = find(marss.spinSys.libPath=='\');
end
marss.spinSys.libDir  = marss.spinSys.libPath(1:slInd(end));
marss.spinSys.libName = marss.spinSys.libPath(slInd(end)+1:end);

%--- update flag display ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;



