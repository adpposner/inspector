%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ExptDataPathUpdate
%% 
%%  Update function for data path of data set to be exported.
%%
%%  03-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_Proc_ExptDataPathUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
if flag.procDataFormat==1 || flag.procDataFormat==3         % matlab or .par format
    if ~SP2_Proc_ExptDataMatUpdate;
        return
    end
elseif flag.procDataFormat==2                               % RAG format
    if ~SP2_Proc_ExptDataTxtUpdate;
        return
    end
else                                                        % LCModel format 
    if ~SP2_Proc_ExptDataRawUpdate;
        return
    end
end

%--- update flag display ---
SP2_Proc_ProcessWinUpdate

%--- update success flag ---
f_succ = 1;




end
