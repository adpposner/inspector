%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec,f_done] = SP2_Proc_JmruiReadFid( dataSpec )
%%
%%  Function to read JMRUI FIDs from file.
%%
%%  12-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Proc_JmruiReadFid';


%--- check file existence ---
if ~SP2_CheckFileExistenceR( dataSpec.dataPathMrui )
    return
end

%--- file handling ---
[fid, msg] = fopen(dataSpec.dataPathMrui,'rb','ieee-be');             % PC
if fid <= 0
    fprintf('%s ->\nOpening %s failed;\n%s\n\n',FCTNAME,dataSpec.dataPathMrui,msg);
    return
end

%--- read header and data from file ---
[raw,nRead] = fread(fid,inf,'double');
% data(1)  = raw(1);          % type of signal, 1: FID, 2: simulated spectrum, 3: simulated FID, 4: peak table
% data(2)  = raw(2);          % number of points
% data(3)  = raw(3);          % sampling interval [ms]
% data(4)  = raw(4);          % begin time
% data(5)  = raw(5);          % zero-order phase
% data(6)  = raw(6);          % transmitter frequency
% data(7)  = raw(7);          % magnetic field
% data(8)  = raw(8);          % type of nucleus
% data(9)  = raw(9);          % reference frequency [Hz]
% data(10) = raw(10);         % reference frequency [ppm]
% data(11) = raw(11);         % 0: FID, 
% data(12) = raw(12);         % apodization
% data(13) = raw(13);         % ZF

%--- data conversion ---
dataSpec.nspecC     = raw(2);
dataSpec.nspecCOrig = dataSpec.nspecC;
dataSpec.sf         = raw(6)/1e6;
dataSpec.sw_h       = 1/(raw(3)/1e3);
dataSpec.sw         = dataSpec.sw_h / dataSpec.sf;
hLen                = 64;               % header length, 512 bytes at 8 bytes/double, 64 header entries total
dataSpec.fid        = -raw(hLen+1:2:hLen+2*dataSpec.nspecC) - 1i*raw(hLen+2:2:hLen+2*dataSpec.nspecC);
dataSpec.fidOrig    = dataSpec.fid;
dataSpec.ppmCalib   = raw(10);


%--- success flag update ---
f_done = 1;
