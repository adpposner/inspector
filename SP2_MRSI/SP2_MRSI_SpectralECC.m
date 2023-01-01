%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpectralECC(datStruct)
%%
%%  Spectral eddy-current correction in time domaine.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi
    
FCTNAME = 'SP2_MRSI_SpectralECC';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(datStruct,'fidimg')
    fprintf('%s ->\nNo FID image of data set 1 found. Program aborted.\',FCTNAME)
    return
end
if ~isfield(mrsi.ref,'fidimg')
    fprintf('%s ->\nNo reference FID image found. Program aborted.\',FCTNAME)
    return
end

%--- Klose correction ---
datStruct.fidimg = exp(-1i*angle(mrsi.ref.fidimg)) .* datStruct.fidimg;

%--- info printout ---
fprintf('Eddy-current correction applied (%s).\n',datStruct.name)

%--- update success flag ---
f_succ = 1;
