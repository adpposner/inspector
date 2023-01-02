%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecDataPathUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag


FCTNAME = 'SP2_LCM_SpecDataPathUpdate';

%--- fid file assignment ---
if flag.lcmDataFormat==1            % matlab format
    SP2_LCM_SpecDataMatUpdate;
elseif flag.lcmDataFormat==2        % RAG format 
    SP2_LCM_SpecDataTxtUpdate;
elseif flag.lcmDataFormat==3        % metabolite (.par) format 
    SP2_LCM_SpecDataParUpdate;
elseif flag.lcmDataFormat==4        % LCModel (.raw) format 
    SP2_LCM_SpecDataRawUpdate;
else                                % JMRUI (.mrui) format 
    SP2_LCM_SpecDataJmruiUpdate;
end

%--- update flag display ---
SP2_LCM_LCModelWinUpdate




