%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_LcmBasisPathUpdate
%% 
%%  Update function for LCM basis path.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm flag

FCTNAME = 'SP2_LCM_LcmBasisPathUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
basisPathTmp = get(fm.lcm.basisPath,'String');
basisPathTmp = basisPathTmp;
if isempty(basisPathTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.lcm.basisPath,'String',lcm.basisPath)
    return
end
if ~strcmp(basisPathTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME);
    set(fm.lcm.basisPath,'String',lcm.basisPath)
    return
end
set(fm.lcm.basisPath,'String',basisPathTmp)
lcm.basisPath = get(fm.lcm.basisPath,'String');

%--- update paths ---
if flag.OS>0            % 1: linux, 2: mac
    slInd = find(lcm.basisPath=='/');
else                    % 0: PC
    slInd = find(lcm.basisPath=='\');
end
lcm.basisDir  = lcm.basisPath(1:slInd(end));
lcm.basisFile = lcm.basisPath(slInd(end)+1:end);

%--- update flag display ---
SP2_LCM_LCModelWinUpdate

%--- update success flag ---
f_succ = 1;



