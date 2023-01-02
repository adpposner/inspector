%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpatialReco(datStruct)
%%
%%  Inverse FFT for spatial reconstruction.
%% 
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_SpatialReco';


%--- init success flag ---
f_succ = 0;

%--- spatial reconstruction (for every slice in time) ---
datStruct.fidimg = complex(zeros(datStruct.nspecC,datStruct.nEncR,datStruct.nEncP,datStruct.nRcvrs));
for rcvrCnt = 1:datStruct.nRcvrs
    for fidCnt = 1:datStruct.nspecC
        datStruct.fidimg(fidCnt,:,:,rcvrCnt) = ifftshift(ifft(ifftshift(ifft(squeeze(datStruct.fidksp(fidCnt,:,:,rcvrCnt)),[],1),1),[],2),2);
        
        %--- info printout ---
        if fidCnt==datStruct.nspecC
            SP2_MRSI_RcvrProcInfo(sprintf('Spatial Reconstruction (%s)',datStruct.name),rcvrCnt,datStruct.nRcvrs)
        end
    end
end

%--- info printout ---
% fprintf('Spatial Reconstuction applied (%s).\n',datStruct.name);

%--- update success flag ---
f_succ = 1;



