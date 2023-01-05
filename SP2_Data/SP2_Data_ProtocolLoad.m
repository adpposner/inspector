%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_ProtocolLoad
%% 
%%  Load FMAP protocol from file
%%
%%  10-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_Data_ProtocolLoad';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(data.protPathMat)
    fprintf('%s ->\nProtocol not found. Program aborted.\n',FCTNAME);
    return
end

%--- info printout ---
fprintf('Protocol loaded from <%s>\n',data.protPathMat);

%--- load protocol ---
if ~SP2_ReadDefaults(data.protPathMat)
    return
end

%--- window update ---
SP2_Data_DataMain

%--- update success flag ---
f_succ = 1;