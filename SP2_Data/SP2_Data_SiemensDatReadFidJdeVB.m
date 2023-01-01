%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec, f_succ] = SP2_Data_SiemensDatReadFidJdeVB(dataSpec)
%%
%%  Function to read MR spectroscopy data in Siemens' VB TWIX raw data 
%%  format (.dat).
%%  VB: old up to VB17a, single measurement
%%  VD: new RAID format, multiple measurements
%% 
%%  10/2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_Data_SiemensDatReadFidVB';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(dataSpec.fidFile)
    fprintf('%s ->\nFile %s doesn''nt exist\n\n',FCTNAME,dataSpec.fidFile)
    return
end
    
%--- file handling ---
[fid, msg] = fopen(dataSpec.fidFile,'rb');
if fid <= 0
    fprintf('%s ->\nOpening %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
end

%--- retrieve header information ---
hdrSize     = fread(fid,1,'uint32');          % header size
nHdrBuffers = fread(fid,1,'uint32');          % number of header buffers
chHdrLength = 128;                            % channel header length in bytes (fixed)

%--- read ushSamplesInScan from 1st MDH data header ---
% from Raid_file_structure_VB15-VB17.padf
status = fseek(fid,hdrSize,'bof');
if status<0
    fprintf('\nPointer positioning to start of MDH header (position %.0f) failed.\n',hdrSize)
    return
end
h.ulFlagsAndDMALength = fread(fid,1,'uint32');        % [4] byte
if isempty(h.ulFlagsAndDMALength)
    fprintf('\n%s ->\nUnknown data format. Check with Christoph for solutions (cwj2112@columbia.edu)\n\n',FCTNAME)
    return
end
h.lMeasUID            = fread(fid,1,'int32');         % [4] byte
h.ulScanCounter       = fread(fid,1,'uint32');        % [4] byte
h.ulTimeStamp         = fread(fid,1,'uint32');        % [4] byte
h.ulPMUTimeStamp      = fread(fid,1,'uint32');        % [4] byte
h.aulEvalInfoMask(1)  = fread(fid,1,'uint32');        % [4] byte
h.aulEvalInfoMask(2)  = fread(fid,1,'uint32');        % [4] byte
h.ushSamplesInScan    = fread(fid,1,'uint16');        % [2] byte
h.ushUsedChannels     = fread(fid,1,'uint16');        % [2] byte
% sLC(sLoopCounter)   = fread(fid,1,'uint32');        % [28] byte
% sCutOff             = fread(fid,1,'uint32');        % [4] byte
% ushKSpaceCentreColumn = fread(fid,1,'uint32');      % [2] byte
% ushCoilSelect       = fread(fid,1,'uint32');        % [2] byte
% fReadOutOffcentre [4] byte
% ulTimeSinceLastRF [4] byte
% ushKSpaceCentreLineNo [2] byte
% ushKSpaceCentrePartitionNo [2] byte
% aushIceProgramPara[4] [8] byte
% sSD(sSliceData) [28] byte
% ushChannelId [2] byte
% ushPTABPosNeg [2] byte

%--- update number of receivers ---
dataSpec.nRcvrs = h.ushUsedChannels;

%--- debugging option ---
% if flag.debug
if 0
    debugOffset = 0;          % 8 bytes per point
    fprintf('debugOffset      = %.1f bytes (= %.0f pts at 8 bytes / point)\n',...
            debugOffset/8,debugOffset)
    fprintf('ushSamplesInScan = %.0f\n',h.ushSamplesInScan)
else
    debugOffset = 0;
end

% 
% data = fread(fid,inf,'float=>single');
% 

%--- read repetitions and channels from file ---
% data.spec1/2.fid format:    nspecC x nrcvrs x NR/block
% data.spec1/2.fidArr format: nblock x nspecC x nrcvrs x NR/block
dataSpec.fid = complex(zeros(dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr)); 
for nrCnt = 1:dataSpec.nr                           % dataSpec.nr
    for chCnt = 1:dataSpec.nRcvrs
        %--- degubbing option ---
        if 0
            fprintf('nrCnt %.0f, chCnt %.0f\n',nrCnt,chCnt)
        end
        
        % jump to start position of individual FIDs
        ptrOffset = hdrSize + ...
                    ((nrCnt-1)*dataSpec.nRcvrs+chCnt)*chHdrLength + ...                 % behind channel (='scan') header
                    ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*(h.ushSamplesInScan*8) + debugOffset;   % before FID data
                    %((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*((2*dataSpec.nspecC+0)*8) + debugOffset;   % before FID data
        
        % Ralph/Charite: offset 0, rm_special, coil ?, syngo MR B17, nspecC 2048
        % C:\Users\juchem\Data\Ralf_Siemens_Data\SPX_dat
        % C:\Users\juchem\Data\Ralf_Siemens_Data\01_meas_MID33_rm_special_fMRS_RL_FID33654_7T_RL_FlorianS_130619.dat
        %         ptrOffset = hdrSize + ...
        %                     ((nrCnt-1)*dataSpec.nRcvrs+chCnt)*chHdrLength + ...                 % behind channel header
        %                     ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*((2*dataSpec.nspecC+0)*8) + debugOffset;   % before FID data

        % Mount Sinai: offset 176, syngo MR B17, PRESS+AF8-7T, coil ?, nspecC 2048
        %         ptrOffset = hdrSize + ...
        %                     ((nrCnt-1)*dataSpec.nRcvrs+chCnt)*chHdrLength + ...                 % behind channel header
        %                     ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*((2*dataSpec.nspecC+176)*8) + debugOffset;   % before FID data
        % C:\Users\juchem\Data\SiemensExamples\JudyAlpern\01_meas_MID181_007_svs_st_vapor_643_FID9721.dat
        % 3x water + 61x metabolites

        % Mount Sinai: offset 64, syngo MR B17, Rebecca Feldman, PRESS+AF8-7T, coil ?, nspecC 1024
        % C:\Users\juchem\Data\SiemensExamples\RebeccaFeldman\twix data\SPX_PRESS_dat_setup
        % C:\Users\juchem\Data\SiemensExamples\RebeccaFeldman\twix data\01_meas_MID724_PRESS_7T_FID7165.dat
        %         ptrOffset = hdrSize + ...
        %                     ((nrCnt-1)*dataSpec.nRcvrs+chCnt)*chHdrLength + ...                 % behind channel header
        %                     ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*((2*dataSpec.nspecC+64)*8) + debugOffset;   % before FID data

        status = fseek(fid,ptrOffset,'bof');             
        if status<0
            fprintf('\nPointer positioning to start of FID (NR #%.0f, receiver %0.f) failed.\n',nrCnt,chCnt)
            return
        end
        [data,cnt] = fread(fid,2*dataSpec.nspecC,'float=>single');
        if cnt~=2*dataSpec.nspecC
            fprintf('%s ->\nReading data from file failed at nrCnt %.0f / chCnt %.0f.\n%.0f of %.0f data points read.\n',...
                    FCTNAME,nrCnt,chCnt,cnt,2*dataSpec.nspecC)
            return
        end
        if flag.debug
            fprintf('nrCnt %.0f, chCnt %.0f\n',nrCnt,chCnt)
        end
        dataSpec.fid(:,chCnt,nrCnt) = complex(data(1:2:end),data(2:2:end));
    end
end

%--- file handling ---
fid = fclose(fid);
if fid < 0
    fprintf('%s ->\nClosing %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
end
    
%--- info printout ---
fprintf('%s ->\nData file successfully read\n',FCTNAME);
fprintf('nr/nspecC/nRcvrs: %d+%d/%d/%d\n',dataSpec.trOffset,...
        dataSpec.nr-dataSpec.trOffset,dataSpec.nspecC,dataSpec.nRcvrs);

%--- update success flag ---
f_succ = 1;


