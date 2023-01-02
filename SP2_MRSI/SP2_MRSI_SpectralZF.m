%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpectralZF(datStruct)
%%
%%  Spectral ZF in time domaine.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_SpectralZF';


%--- init success flag ---
f_succ = 0;

%--- time-domaine zero-filling ---
if datStruct.zf>datStruct.nspecCimg
    %--- info printout ---
    fprintf('Spectral zero-filling applied: %.0f -> %.0f (%s)\n',datStruct.nspecCimg,datStruct.zf,datStruct.name);
    
    %--- apply ZF ---
    fid1Zf = complex(zeros(datStruct.zf,datStruct.nEncR,datStruct.nEncP));
    fid1Zf(1:datStruct.nspecCimg,:,:) = datStruct.fidimg;
    datStruct.fidimg = fid1Zf;
    datStruct.nspecCimg = datStruct.zf;
else
    fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
            FCTNAME,datStruct.zf,datStruct.nspecCimg)
end


%--- update success flag ---
f_succ = 1;
