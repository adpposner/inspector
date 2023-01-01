%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpectralCut(datStruct)
%%
%%  FID apodization.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_SpectralCut';


%--- init success flag ---
f_succ = 0;

%--- apply spectral apodization ---
if datStruct.cut<datStruct.nspecCimg
    datStruct.fidimg    = datStruct.fidimg(1:datStruct.cut,:,:);
    fprintf('FID apodization %.0f -> %.0f points applied (%s).\n',datStruct.nspecCimg,datStruct.cut,datStruct.name)
    datStruct.nspecCimg = datStruct.cut;
else
    fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
            FCTNAME,datStruct.cut,datStruct.nspecCimg)
end

%--- update success flag ---
f_succ = 1;
