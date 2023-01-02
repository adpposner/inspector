%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2DataPathUpdate
%% 
%%  Update function for data path of FID data set 2.
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag


FCTNAME = 'SP2_MRSI_Spec2DataPathUpdate';

%--- fid file assignment ---
if flag.mrsiDatFormat       % matlab format
    SP2_MRSI_Spec2DataMatUpdate;
else                        % RAG format 
    SP2_MRSI_Spec2DataTxtUpdate;
end

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate




