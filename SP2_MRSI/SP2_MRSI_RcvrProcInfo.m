%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_RcvrProcInfo(fctName,rcvrCnt,nRcvrs)
%%
%%  Info printout for multi-receiver processing.
%% 
%%  05-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_RcvrProcInfo';


%--- info printout ---
if rcvrCnt==1
    fprintf('%s, Receiver 1',fctName);
elseif rcvrCnt==nRcvrs
    fprintf('%i\n',nRcvrs);
else
    fprintf('.');
end



