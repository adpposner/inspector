%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpectralLB(datStruct)
%%
%%  Spectral line broadening in time domaine.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_SpectralLB';


%--- init success flag ---
f_succ = 0;

%--- generation of single weighting function ---
lbWeight = exp(-datStruct.lb*datStruct.dwell*(0:datStruct.nspecCimg-1)*pi)';

%--- matrix generation ---
lbWeight = repmat(lbWeight,[1 datStruct.nEncR datStruct.nEncP]);

%--- line broadening --------------------
datStruct.fidimg = datStruct.fidimg .* lbWeight;

%--- info printout ---
fprintf('Spectral line broadening (%.1f Hz) applied (%s).\n',datStruct.lb,datStruct.name);

%--- update success flag ---
f_succ = 1;

end
