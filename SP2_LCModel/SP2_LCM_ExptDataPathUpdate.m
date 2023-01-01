%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ExptDataPathUpdate
%% 
%%  Update function for data path of data set to be exported.
%%
%%  03-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_LCM_ExptDataPathUpdate';

%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
if flag.lcmDataFormat==1 || flag.lcmDataFormat==3 || flag.lcmDataFormat==5        % matlab format for .mat, .par or .mrui
    if ~SP2_LCM_ExptDataMatUpdate;
        return
    end
elseif flag.lcmDataFormat==2                               % RAG format
    if ~SP2_LCM_ExptDataTxtUpdate;
        return
    end
else                                                        % LCModel format 
    if ~SP2_LCM_ExptDataRawUpdate;
        return
    end
end

%--- update flag display ---
SP2_LCM_LCModelWinUpdate

%--- update success flag ---
f_succ = 1;


