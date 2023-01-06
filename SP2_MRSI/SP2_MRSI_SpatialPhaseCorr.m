%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpatialPhaseCorr(datStruct)
%%
%%  Spatial (ECC-style) phase correction based-on reference (water) map.
%%
%%  05-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi
    
FCTNAME = 'SP2_MRSI_SpatialPhaseCorr';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(datStruct,'fidimg')
    fprintf('%s ->\nNo FID image of data set 1 found. Program aborted.\',FCTNAME);
    return
end
if ~isfield(mrsi.ref,'fidimg')
    fprintf('%s ->\nNo reference FID image found. Program aborted.\',FCTNAME);
    return
end

%--- spatial phase correction ---
% datStruct.fidimg = exp(-1i*angle(mrsi.ref.fidimg)) .* datStruct.fidimg;
datStruct.fidimg = exp(-1i*angle(mrsi.ref.fidimg)) .* datStruct.fidimg;

%--- checker board phase map ---
checkerPhase = zeros(datStruct.nEncR,datStruct.nEncP);
for colCnt = 1:datStruct.nEncR
    if mod(colCnt,2)
        checkerPhase(colCnt,:) = pi*mod(1:datStruct.nEncP,2);
    else
        checkerPhase(colCnt,:) = pi*mod(0:datStruct.nEncP-1,2);
    end
end
checkerMat = permute(repmat(checkerPhase,[1 1 datStruct.nspecC]),[3 1 2]);
datStruct.fidimg = exp(-1i*checkerMat) .* datStruct.fidimg;

%--- info printout ---
fprintf('Spatial phase correction applied (%s).\n',datStruct.name);

%--- update success flag ---
f_succ = 1;

end
