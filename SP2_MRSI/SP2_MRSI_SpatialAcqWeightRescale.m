%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpatialAcqWeightRescale(datStruct)
%%
%%  Consideration of potentially varying k-space acqusition schemes:
%%  Data set 1/2 vs. the reference.
%% 
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_SpatialAcqWeightRescale';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(mrsi.ref,'fidksp')
    fprintf('%s ->\nNo reference data found. Program aborted.\',FCTNAME);
    return
end
if ~isfield(datStruct,'fidksp')
    fprintf('%s ->\n%s not found. Program aborted.\',FCTNAME,datStruct.name);
    return
end

%--- reference scaling ---
weightMat = permute(repmat(mrsi.spec1.encMat./mrsi.ref.encMat,[1 1 mrsi.spec1.nspecC]),[3 1 2]);
weightMat(isnan(weightMat)) = 0;
mrsi.ref.fidksp = weightMat .* mrsi.ref.fidksp;

%--- info printout ---
fprintf('Reference k-space weighted by acquisition weighting of data set 1.\n');

%--- update success flag ---
f_succ = 1;



