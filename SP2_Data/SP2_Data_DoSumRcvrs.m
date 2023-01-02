%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_DoSumRcvrs
%% 
%%  Summation of FIDs from multiple receivers.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_Data_DoSumRcvrs';


%--- init success flag ---
f_succ = 0;

if flag.dataExpType==1          % single
    if ~SP2_Data_DoSumRcvrsSingle
        return
    end
elseif flag.dataExpType==2      % saturation-recovery
    if ~SP2_Data_DoSumRcvrsSatRec
        return
    end
elseif flag.dataExpType==3      % JDE
    if ~SP2_Data_DoSumRcvrsJDE
        return
    end
elseif flag.dataExpType==4      % stability
    if ~SP2_Data_DoSumRcvrsStability
        return
    end
elseif flag.dataExpType==5      % T1/T2
    if ~SP2_Data_DoSumRcvrsT1T2
        return
    end
elseif flag.dataExpType==6      % MRSI
    if ~SP2_Data_DoSumRcvrsMRSI
        return
    end
else
    fprintf('%s ->\nUnknown experiment format. Program aborted.\n',FCTNAME);
    return
end
    
%--- update success flag ---
f_succ = 1;

