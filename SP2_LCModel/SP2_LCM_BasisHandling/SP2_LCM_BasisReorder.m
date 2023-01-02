%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_LCM_BasisReorder
%% 
%%  Function to reassign the order of metabolite basis spectra.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm fm

FCTNAME = 'SP2_LCM_BasisReorder';


%--- init success flag ---
f_done = 0;

%--- consistency check ---
if any((1:lcm.basis.n)~=sort(lcm.basis.reorder))
    fprintf('%s ->\nAt least one dublicate found. Resorting of metabolite basis spectra aborted.\n',FCTNAME);
    return
end

%--- create temporary basis ---
lcmBasisData  = lcm.basis.data;
for mCnt = 1:lcm.basis.n                % metabolites
    for fCnt = 1:4                      % array fields
        lcmBasisData{mCnt}{fCnt} = lcm.basis.data{lcm.basis.reorder(mCnt)}{fCnt};
    end
end
lcm.basis.data = lcmBasisData;

%--- update fit selection ---
lcm.fit.select(1:lcm.basis.n) = lcm.fit.select(lcm.basis.reorder(1:lcm.basis.n));
lcm.fit.applied = find(lcm.fit.select);
% note that appliedN remains unchanged

%--- update fit parameters ---
lcm.fit.lbMin(1:lcm.basis.n) = lcm.fit.lbMin(lcm.basis.reorder(1:lcm.basis.n));
lcm.anaLb(1:lcm.basis.n) = lcm.anaLb(lcm.basis.reorder(1:lcm.basis.n));
lcm.fit.lbMax(1:lcm.basis.n) = lcm.fit.lbMax(lcm.basis.reorder(1:lcm.basis.n));
lcm.fit.gbMin(1:lcm.basis.n) = lcm.fit.gbMin(lcm.basis.reorder(1:lcm.basis.n));
lcm.anaGb(1:lcm.basis.n) = lcm.anaGb(lcm.basis.reorder(1:lcm.basis.n));
lcm.fit.gbMax(1:lcm.basis.n) = lcm.fit.gbMax(lcm.basis.reorder(1:lcm.basis.n));
lcm.fit.shiftMin(1:lcm.basis.n) = lcm.fit.shiftMin(lcm.basis.reorder(1:lcm.basis.n));
lcm.anaShift(1:lcm.basis.n) = lcm.anaShift(lcm.basis.reorder(1:lcm.basis.n));
lcm.fit.shiftMax(1:lcm.basis.n) = lcm.fit.shiftMax(lcm.basis.reorder(1:lcm.basis.n));
lcm.anaScale(1:lcm.basis.n) = lcm.anaScale(lcm.basis.reorder(1:lcm.basis.n));

%--- update analysis detail window ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end

%--- reset reordering vector ---
lcm.basis.reorder = 1:lcm.basis.n;

%--- window update ---
SP2_LCM_BasisWinUpdate

%--- update success flag ---
f_done = 1;

