%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_Spec1DataPathUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_Proc_Spec1DataPathUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
if flag.procDataFormat==1           % matlab format
    SP2_Proc_Spec1DataMatUpdate;
elseif flag.procDataFormat==2       % RAG format 
    SP2_Proc_Spec1DataTxtUpdate;
elseif flag.procDataFormat==3       % metabolite (.par) format 
    SP2_Proc_Spec1DataParUpdate;
elseif flag.procDataFormat==4       % LCModel (.raw) data format 
    SP2_Proc_Spec1DataRawUpdate;
else                                % LCModel (.coord) output/result format 
    SP2_Proc_Spec1DataCoordUpdate;
end

%--- update flag display ---
SP2_Proc_ProcessWinUpdate

%--- update success flag ---
f_succ = 1;





end
