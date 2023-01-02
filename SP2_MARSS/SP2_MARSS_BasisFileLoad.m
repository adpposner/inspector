%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_BasisFileLoad
%% 
%%  Function to load LCM basis set from file.
%%  File format:
%%  1) metabolite name
%%  2) T1
%%  3) T2
%%  4) FID
%%  5) comment
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile marss

FCTNAME = 'SP2_MARSS_BasisFileLoad';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(marss.basis.filePath)
    return
end

%--- load data & parameters from file ---
load(marss.basis.filePath)

%--- check data format ---
if ~exist('lcmBasis','var')
    fprintf('%s ->\nNo basis data structure found. Check file format.\n',FCTNAME);
    return
end
if ~isfield(lcmBasis,'data')
    fprintf('%s ->\nNo data in basis structure found. Check data format.\n',FCTNAME);
    return
end
if ~isfield(lcmBasis,'sf')
    fprintf('%s ->\nLarmor frequency of basis not found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(lcmBasis,'sw_h')
    fprintf('%s ->\nSweep width of basis not found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(lcmBasis,'ppmCalib')
    fprintf('%s ->\nFrequency calibration found. Program aborted.\n',FCTNAME);
    return
end

%--- transfer fields to basis struct ---
marss.basis.n = length(lcmBasis.data);
exampleFid    = lcmBasis.data{1}{4};
marss.basis.nspecCOrig = length(exampleFid);
marss.basis.nspecC     = marss.basis.nspecCOrig;
marss.basis.fidOrig    = complex(zeros(marss.basis.nspecCOrig,marss.basis.n));       % not supporting metabolite-specific FID lengths
for bCnt = 1:marss.basis.n
    % signal dims: nspecC, nMoeity
    marss.basis.metabNames{bCnt} = lcmBasis.data{bCnt}{1};
    marss.basis.fidOrig(:,bCnt)  = lcmBasis.data{bCnt}{4};
end
marss.basis.sw_h       = lcmBasis.sw_h;
marss.basis.sf         = lcmBasis.sf;
marss.basis.sw         = marss.basis.sw_h/marss.basis.sf;
marss.basis.dwell      = 1/marss.basis.sw_h;
marss.basis.ppmCalib   = lcmBasis.ppmCalib;

%--- basic assessment ---
marss.basis.ptsMin    = 1e6;                            % length of shortest FID
marss.basis.ptsMax    = 0;                              % length of longest FID
marss.basis.fidLength = zeros(1,marss.basis.n);         % metabolite-specific FID length
for bCnt = 1:marss.basis.n
    % FID length
    marss.basis.fidLength(bCnt) = length(lcmBasis.data{bCnt}{4});
    
    % update shortest
    if marss.basis.fidLength(bCnt)<marss.basis.ptsMin
        marss.basis.ptsMin = marss.basis.fidLength(bCnt);
    end
    
    % update longest
    if marss.basis.fidLength(bCnt)>marss.basis.ptsMax
        marss.basis.ptsMax = marss.basis.fidLength(bCnt);
    end
end
clear lcmBasis

%--- info printout ---
fprintf('\nBasis set loaded from <%s>:\n%s\n',marss.basis.fileName,marss.basis.filePath);
fprintf('1) # of metabolites:  %.0f\n',marss.basis.n);
fprintf('2) sweep width:       %.1f Hz\n',marss.basis.sw_h);
fprintf('3) Larmor frequency:  %.3f MHz\n',marss.basis.sf);
fprintf('4) reference frequ.:  %.3f ppm\n',marss.basis.ppmCalib);
fprintf('5) Shortest FID:      %.0f pts\n',marss.basis.ptsMin);
fprintf('6) Longest FID:       %.0f pts\n\n',marss.basis.ptsMax);

%--- update basis selection ---
% to be added here... if desired

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;

