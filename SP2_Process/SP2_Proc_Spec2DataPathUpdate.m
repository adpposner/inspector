%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_Spec2DataPathUpdate
%% 
%%  Update function for data path of FID data set 2.
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_Proc_Spec2DataPathUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
if flag.procDataFormat==1           % matlab format
    SP2_Proc_Spec2DataMatUpdate;
elseif flag.procDataFormat==2       % RAG format 
    SP2_Proc_Spec2DataTxtUpdate;
elseif flag.procDataFormat==3       % metabolite (.par) format 
    SP2_Proc_Spec2DataParUpdate;
elseif flag.procDataFormat==4       % LCModel (.raw) data format 
    SP2_Proc_Spec2DataRawUpdate;
else                                % LCModel (.coord) output/result format 
    SP2_Proc_Spec2DataCoordUpdate;
end

%--- update flag display ---
SP2_Proc_ProcessWinUpdate

%--- update success flag ---
f_succ = 1;



