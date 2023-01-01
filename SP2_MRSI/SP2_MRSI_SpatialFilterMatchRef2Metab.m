%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MRSI_SpatialFilterMatchRef2Metab
%%
%%  Match reference weighting scheme to metabolite scans.
%% 
%%  05-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_SpatialFilterMatchRef2Metab';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(mrsi.ref,'fidksp')
    fprintf('%s ->\nNo reference data found. Program aborted.\',FCTNAME)
    return
end
if ~isfield(mrsi.spec1,'fidksp')
    fprintf('%s ->\nNo data set 1 found. Program aborted.\',FCTNAME)
    return
end

%--- reference scaling, apply metab zeros to reference ---
weightMat = permute(repmat(mrsi.spec1.encMat./mrsi.ref.encMat,[1 1 mrsi.spec1.nspecC mrsi.spec1.nRcvrs]),[3 1 2 4]);
weightMat(isnan(weightMat)) = 0;
weightMat(isinf(weightMat)) = 0;
mrsi.ref.fidksp    = weightMat .* mrsi.ref.fidksp;
mrsi.ref.encMatEff = squeeze(weightMat(1,:,:,1));

%--- info printout ---
fprintf('Reference filter matched to data set 1.\n')

%--- update success flag ---
f_succ = 1;



