%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpectralPhaseCorr(datStruct)
%%
%%  Spectral zero/first order phase correction.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_SpectralPhaseCorr';


%--- init success flag ---
f_succ = 0;

%--- phase correction ---
if datStruct.phc1~=0
    phaseVec = (0:datStruct.phc1/(datStruct.nspecCimg-1):datStruct.phc1) + datStruct.phc0; 
else
    phaseVec = ones(1,datStruct.nspecCimg)*datStruct.phc0;
end
phaseMat = permute(repmat(phaseVec,[datStruct.nEncR 1 datStruct.nEncP]),[2 1 3]);
datStruct.specimg = datStruct.specimg .* exp(1i*phaseMat*pi/180);

%--- info printout ---
fprintf('Spectral phasing applied (%s).\n',datStruct.name)

%--- update success flag ---
f_succ = 1;

