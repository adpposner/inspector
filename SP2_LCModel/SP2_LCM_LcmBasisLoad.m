%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_LcmBasisLoad
%% 
%%  Function to load LCM basis set.
%%  File format:
%%  1) metabolite name
%%  2) T1
%%  3) T2
%%  4) FID
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm

FCTNAME = 'SP2_LCM_LcmBasisLoad';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(lcm.basisPath)
    return
end

%--- load data & parameters from file ---
load(lcm.basisPath)

%--- consistency checks ---
if ~exist('lcmBasis','var')
    fprintf('\n%s ->\nThe file does not contain basis information. Program aborted.\n\n',FCTNAME);
    return
end
if ~isstruct(lcmBasis)
    fprintf('\n%s ->\nThe variable ''lcmBasis'' is not of type ''cell''.\nIt therefore does not contain valid basis information. Program aborted.\n\n',FCTNAME);
    return
end
if ~isfield(lcmBasis,'data')
    fprintf('\n%s ->\nThe basis does not contain the expected ''data'' field.\nIt therefore does not contain valid basis information. Program aborted.\n\n',FCTNAME);
    return
end
if ~isfield(lcmBasis,'sw_h')
    fprintf('\n%s ->\nThe basis does not contain the expected ''sw_h'' field.\nIt therefore does not contain valid basis information. Program aborted.\n\n',FCTNAME);
    return
end
if ~isfield(lcmBasis,'sf')
    fprintf('\n%s ->\nThe basis does not contain the expected ''sf'' field.\nIt therefore does not contain valid basis information. Program aborted.\n\n',FCTNAME);
    return
end
if ~isfield(lcmBasis,'ppmCalib')
    fprintf('\n%s ->\nThe basis does not contain the expected ''ppmCalib'' field.\nIt therefore does not contain valid basis information. Program aborted.\n\n',FCTNAME);
    return
end
if ~iscell(lcmBasis.data)
    fprintf('\n%s ->\nThe basis field ''data'' is not of type cell.\nIt therefore does not contain valid basis information. Program aborted.\n\n',FCTNAME);
    return
end
% not test of lcmBasis.data cell entries yet

%--- transfer fields to basis struct ---
fNames = fieldnames(lcmBasis);
for mCnt = 1:length(fNames)
    eval(['lcm.basis.' fNames{mCnt} ' = lcmBasis.' fNames{mCnt} ';'])
end
lcm.basis.dwell = 1/lcm.basis.sw_h;
lcm.basis.sw    = lcm.basis.sw_h/lcm.basis.sf;
clear lcmBasis

%--- basic assessment ---
lcm.basis.n         = length(lcm.basis.data);       % number of metabolites
lcm.basis.ptsMin    = 1e6;                          % length of shortest FID
lcm.basis.ptsMax    = 0;                            % length of longest FID
lcm.basis.fidLength = zeros(1,lcm.basis.n);         % metabolite-specific FID length
lcm.basis.reorder   = 1:lcm.basis.n;                % init reordering vector
for bCnt = 1:lcm.basis.n
    % FID length
    lcm.basis.fidLength(bCnt) = length(lcm.basis.data{bCnt}{4});
    
    % update shortest
    if lcm.basis.fidLength(bCnt)<lcm.basis.ptsMin
        lcm.basis.ptsMin = lcm.basis.fidLength(bCnt);
    end
    
    % update longest
    if lcm.basis.fidLength(bCnt)>lcm.basis.ptsMax
        lcm.basis.ptsMax = lcm.basis.fidLength(bCnt);
    end
end

%--- info printout ---
fprintf('\nBasis set loaded from <%s>:\n%s\n',lcm.basisFile,lcm.basisPath);
fprintf('1) # of metabolites:  %.0f\n',lcm.basis.n);
fprintf('2) sweep width:       %.1f Hz\n',lcm.basis.sw_h);
fprintf('3) Larmor frequency:  %.3f MHz\n',lcm.basis.sf);
fprintf('4) reference frequ.:  %.3f ppm\n',lcm.basis.ppmCalib);
fprintf('5) Shortest FID:      %.0f pts\n',lcm.basis.ptsMin);
fprintf('6) Longest FID:       %.0f pts\n\n',lcm.basis.ptsMax);

%--- update basis window ---
if isfield(fm.lcm,'basis')
    if ishandle(fm.lcm.basis.fig)
        SP2_LCM_BasisWinUpdate
    end
end

%--- update basis selection ---
% disable components that exceed the basis dimension
lcm.fit.select(find((1:lcm.basis.nLim)>lcm.basis.n)) = 0;
lcm.fit.applied  = find(lcm.fit.select);             % vector of basis functions to be applied
lcm.fit.appliedN = length(lcm.fit.applied);          % number of applied basis functions


%--- update analysis detail window ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end

%--- update success flag ---
f_succ = 1;


end
