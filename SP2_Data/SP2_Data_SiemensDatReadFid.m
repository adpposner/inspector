%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec, f_succ] = SP2_Data_SiemensDatReadFid(dataSpec)
%%
%%  Function to read MR spectroscopy data in Siemens' TWIX raw data 
%%  format (.dat).
%%  VB: old up to VB17a, single scan in 'measurement', i.e. file
%%  VD: new multi-RAID format, multiple scans in one 'measurements', i.e. file
%%   
%%  10/2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_Data_SiemensDatReadFid';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if SP2_CheckFileExistenceR(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fSize  = thedir.bytes;
else
    fprintf('%s -> File %s doesn''nt exist\n\n',FCTNAME,dataSpec.fidFile)
    return
end

%--- file handling ---
[fid, msg] = fopen(dataSpec.fidFile,'rb');
if fid <= 0
    fprintf('%s ->\nOpening %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
end

%--- read first header entry ---
headerSize = fread(fid,1,'uint32');             % header size (for VB) 
nMeas      = fread(fid,1,'uint32');             % number of measurement blocks

%--- info printout ---
if flag.debug
    if strcmp(dataSpec.softGeneration,'VB')
        fprintf('header size: %.0f\n',headerSize);
    end
    if strcmp(dataSpec.softGeneration,'VD')
        fprintf('# scans:  %.0f\n',nMeas);
    end
end
if flag.debug || flag.verbose
    if isfield(dataSpec,'software')
        if ~isempty(dataSpec.software)
            fprintf('Software:   %s\n',dataSpec.software)
        end
    end
end

%--- file handling ---
fid = fclose(fid);
if fid < 0
    fprintf('%s ->\nClosing %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
end

%--- info printout ---
fprintf('%s -> Reading:\n<%s>\n',FCTNAME,dataSpec.fidFile)

%--- version VB vs. VD ---
if strcmp(dataSpec.softGeneration,'VB')
    %--- data format flag ---
    % flag.dataSiemensVbVd = 1;       % VB
    fprintf('TWIX data format: VB\n')
    
    %--- read VB data from file ---
    [dataSpec, f_done] = SP2_Data_SiemensDatReadFidVB(dataSpec);
elseif strcmp(dataSpec.softGeneration,'VD') || strcmp(dataSpec.softGeneration,'VE')
    %--- data format flag ---
    % flag.dataSiemensVbVd = 0;       % VD
    fprintf('TWIX data format: %s\n',dataSpec.softGeneration)

    %--- read VD data from file ---
    [dataSpec, f_done] = SP2_Data_SiemensDatReadFidVDVE(dataSpec);
end

%--- consistency check ---
if ~f_done
    fprintf('%s -> Reading %s failed\n\n',FCTNAME,dataSpec.fidFile)
    return
end
    

%--- data formats ---
% Stony Brook / 3T: syngo MR E11
% Mount Sinai / 7T: syngo MR B17
% Ralp / Charite: syngo MR B17
% ZMBBI / June: syngo MR E11 (VE)
% Harshal Patel, RWTH Aachen: syngo MR D13D
% NYU / Martin Gajdosik / 7T: syngo MR B17


% 2144-2048 = 96;
% 4288-4096 = 192; 
% nRcvrs = 32
% NR = 64

%--- update success flag ---
f_succ = 1;



end
