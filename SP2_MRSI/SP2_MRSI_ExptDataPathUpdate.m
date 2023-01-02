%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ExptDataPathUpdate
%% 
%%  Update function for data path of data set to be exported.
%%
%%  03-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag


FCTNAME = 'SP2_MRSI_ExptDataPathUpdate';

%--- fid file assignment ---
if flag.mrsiDatFormat       % matlab format
    SP2_MRSI_ExptDataMatUpdate;
else                        % RAG format 
    SP2_MRSI_ExptDataTxtUpdate;
end

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate




