%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [fidNew, nspecCNew, f_succ] = SP2_LCM_BasisRspBandwidth(fidOrig, sw_hOrig, sw_hNew)
%% 
%%  Function to resample spectral signals to a different bandwidth
%%  The interpolation is applied in the time domaine. The new number of points
%%  can be assigned as third (optional) function argument. If no third argument
%%  is used, a maximal number of FID points are fitted at the new bandwidth
%%  are used to resemble the original FID.
%%  input arguments:
%%  1) original data structure
%%  2) desired new bandwidth [Hz]
%%
%%  output argument:
%%  1) transformed data structure
%%
%%  12-2018, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_BasisRspBandwidth';


%--- init success flag ---
f_succ    = 0;
fidNew    = 0;
nspecCNew = 0;

%--- check data consistency ---
if ~isnumeric(fidOrig)
    fprintf('%s ->\nFirst input argument is not of type structure. Program aborted.\n',FCTNAME);
    return
end
if ~isnumeric(sw_hOrig)
    fprintf('%s ->\nData structure of input spectrum does not have any field for the spectral bandwidth. Program aborted.\n',FCTNAME);
    return
end
if ~isnumeric(sw_hNew)
    fprintf('%s ->\nData structure of input spectrum does not have any field for number of complex point. Program aborted.\n',FCTNAME);
    return
end

% sw_hOrig = lcm.sw_h;
% sw_hNew  = 2000;
% fidOrig  = lcm.fid;
% nspecCOrig = length(fidOrig);

%--- data transformation ---
dwellOrig  = 1/sw_hOrig;
dwellNew   = 1/sw_hNew;
nspecCOrig = length(lcm.fid);
tVecOrig   = 0:dwellOrig:(nspecCOrig-1)*dwellOrig;
tVecNew    = 0:dwellNew:tVecOrig(end);
nspecCNew  = length(tVecNew);
fidNew     = spline(tVecOrig,fidOrig,tVecNew).';

size(fidNew)
%--- hard coded ---
lcm.sf = 123.26;
lcm.sw_h   = sw_hNew;
lcm.sw     = lcm.sw_h/lcm.sf;
lcm.nspecC = nspecCNew;
lcm.fidOrig = fidNew;
lcm.fid     = fidNew;



%--- info printout ---
if flag.verbose
    fprintf('Basis import from\n<%s>\ncompleted.\n',basisFidDir);
end

%--- update success flag ---
f_succ = 1;

