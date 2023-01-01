%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_CreateAnalysisProtocol
%% 
%%  Fully automated conversion of SPX protocol and data structure to current data location
%%  e.g. Linux (scanner) to Mac / PC (for analysis)
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_CreateAnalysisProtocol';


%--- init success flag ---
f_succ = 0;

%--- check Mac/PC ---
% if flag.OS~=0 && flag.OS~=2                         % 0: PC, 2: Mac
%     fprintf('Current computer is neither PC nor Mac. Program aborted.\n')
%     return
% end

%--- info printout ---
fprintf('%s started...\n\n',FCTNAME)

%--- retrieve SPX protocol file ---
dataProtDir  = data.protDir;
dataProtPath = data.protPath;

%--- load protocol ---
if ~SP2_Data_ProtocolLoad
    return
end

%--- protocol path handling ---
data.protDir     = dataProtDir;
if flag.OS==0           % PC
    data.protPath = [dataProtPath '_anaPC'];
elseif flag.OS==1       % Linux
    data.protPath = [dataProtPath '_anaLin'];
else                    % Mac
    data.protPath = [dataProtPath '_anaMac'];
end
data.protPathMat = [data.protPath '.mat'];
data.protPathTxt = [data.protPath '.txt'];
% window update is not necessary here as protocol saving involves are
% software restart

%--- save settings as new protocol ---
if ~SP2_Data_ProtocolSave
    return
end

%--- update data paths ---
if ~SP2_Data_AssignProtDir2Data
    return
end

%--- save settings as new protocol ---
if ~SP2_Data_ProtocolSave
    return
end

%--- info printout ---
fprintf('%s completed.\n',FCTNAME)

%--- update success flag ---
f_succ = 1;

