%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ProtocolSelect
%% 
%%  SPEC protocol selection
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

FCTNAME = 'SP2_Data_ProtocolSelect';

    
%--- check existence of directory init ---
% 1) earlier protocol directory
% 2) study directory 
% 3) C:\
if ~SP2_CheckDirAccessR(data.protDir)
    if ispc
        data.protDir = 'C:\';
    elseif ismac
        data.protDir = '/Users/';
    else
        data.protDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(data.protDir);
    if ~f_succ
        data.protDir = maxPath;
    end
end

%--- file selection ---
[dataProtFile,dataProtDir] = uigetfile('*.mat','Select SPEC protocol:',data.protDir);
if ~ischar(dataProtFile)             % buffer select cancelation
    if ~dataProtFile            
        fprintf('%s aborted.\n',FCTNAME);
        return
    end
end

%--- protocol assignment ---
data.protFile = dataProtFile;
data.protDir  = dataProtDir;
data.protFile = data.protFile(1:end-4);       % remove '.mat'

%--- update file and directory strings --- 
data.protPath    = [data.protDir data.protFile];
data.protPathMat = [data.protPath '.mat'];
data.protPathTxt = [data.protPath '.txt'];

%--- update display ---
set(fm.data.protPath,'String',data.protPath)

end
