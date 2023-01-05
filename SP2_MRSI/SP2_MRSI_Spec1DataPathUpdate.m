%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1DataPathUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag


FCTNAME = 'SP2_MRSI_Spec1DataPathUpdate';

%--- fid file assignment ---
if flag.mrsiDatFormat       % matlab format
    SP2_MRSI_Spec1DataMatUpdate;
else                        % RAG format 
    SP2_MRSI_Spec1DataTxtUpdate;
end

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate




