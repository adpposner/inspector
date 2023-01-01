%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_LCM_BasisDelete(nMetab)
%% 
%%  Function to delete individual metabolite from LCM basis set.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm

FCTNAME = 'SP2_LCM_BasisDelete';


%--- init success flag ---
f_done = 0;

%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.n
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab)
    return
end

%--- consistency check ---
if nMetab>lcm.basis.n || nMetab>lcm.basis.nLim
    fprintf('Assigned basis position is outside the allowable range (0..%.0f)\n',lcm.basis.n)
    fprintf('Program aborted.\n')
    return
end

%--- remove individual metabolite ---
lcmBasisData = {};
nFields      = length(lcm.basis.data{1});     % number of fields
for mCnt = 1:lcm.basis.n                % metabolites
    if mCnt<nMetab
        for fCnt = 1:nFields            % array fields
            lcmBasisData{mCnt}{fCnt} = lcm.basis.data{mCnt}{fCnt};
        end
    elseif mCnt>nMetab
        for fCnt = 1:nFields            % array fields
            lcmBasisData{mCnt-1}{fCnt} = lcm.basis.data{mCnt}{fCnt};
        end
    end
end
lcm.basis.data = lcmBasisData;
clear lcmBasisData

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
fprintf('\nBasis set characteristics:\n')
fprintf('1) # of metabolites:  %.0f\n',lcm.basis.n)
fprintf('2) sweep width:       %.1f Hz\n',lcm.basis.sw_h)
fprintf('3) Larmor frequency:  %.3f MHz\n',lcm.basis.sf)
fprintf('4) reference frequ.:  %.3f ppm\n',lcm.basis.ppmCalib)
fprintf('5) Shortest FID:      %.0f pts\n',lcm.basis.ptsMin)
fprintf('6) Longest FID:       %.0f pts\n\n',lcm.basis.ptsMax)

%--- window update ---
SP2_LCM_BasisWinUpdate

%--- unset corresponding analysis flag ---
reorderVec       = (1:lcm.fit.nLim)~=nMetab;        % excluding the one metabolite to be deleted
lcm.fit.select(1:(lcm.fit.nLim-1)) = lcm.fit.select(reorderVec);
lcm.fit.applied  = find(lcm.fit.select);
lcm.fit.appliedN = length(lcm.fit.applied);

%--- update fit parameters ---
lcm.fit.lbMin(1:(lcm.fit.nLim-1))    = lcm.fit.lbMin(reorderVec);
lcm.anaLb(1:(lcm.fit.nLim-1))        = lcm.anaLb(reorderVec);
lcm.fit.lbMax(1:(lcm.fit.nLim-1))    = lcm.fit.lbMax(reorderVec);
lcm.fit.gbMin(1:(lcm.fit.nLim-1))    = lcm.fit.gbMin(reorderVec);
lcm.anaGb(1:(lcm.fit.nLim-1))        = lcm.anaGb(reorderVec);
lcm.fit.gbMax(1:(lcm.fit.nLim-1))    = lcm.fit.gbMax(reorderVec);
lcm.fit.shiftMin(1:(lcm.fit.nLim-1)) = lcm.fit.shiftMin(reorderVec);
lcm.anaShift(1:(lcm.fit.nLim-1))     = lcm.anaShift(reorderVec);
lcm.fit.shiftMax(1:(lcm.fit.nLim-1)) = lcm.fit.shiftMax(reorderVec);

%--- update analysis detail window ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end

%--- update success flag ---
f_done = 1;






