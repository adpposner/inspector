%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec, f_succ] = SP2_Data_SiemensDatReadFidJdeVDVE(dataSpec)
%%
%%  Function to read MR spectroscopy data in Siemens' VD TWIX raw data 
%%  format (.dat).
%%  VB: old up to VB17a, single measurement
%%  VD: new RAID format, multiple measurements
%% 
%%  10/2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_Data_SiemensDatReadFidJdeVDVE';


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
hdrSize       = fread(fid,1,'uint32');                      % ID / header size
nMeas         = fread(fid,1,'uint32');                      % number of measurement blocks
measID        = zeros(1,nMeas);
fileID        = zeros(1,nMeas);
measOffset    = zeros(1,nMeas);                             % starting position of measurement block (mdh + data)
measTotLength = zeros(1,nMeas);                             % total length of measurement block (mdh + data)
measHdrLength = zeros(1,nMeas);                             % length of measurement header (mdh)
patientName   = {};
protocolName  = {};
for mCnt = 1:nMeas
    measID(mCnt)        = fread(fid,1,'uint32');
    fileID(mCnt)        = fread(fid,1,'uint32');
    measOffset(mCnt)    = fread(fid,1,'uint64');            % measurement offset, ie. header starting position
    measTotLength(mCnt) = fread(fid,1,'uint64');            % measurement-specific data length
    patientName{mCnt}   = fread(fid,64,'*char')';           % patient name
    protocolName{mCnt}  = fread(fid,64,'*char')';           % protocol name
end
for mCnt = 1:nMeas
    status = fseek(fid,measOffset(mCnt),'bof');             % jump to header start position
    if status<0
        fprintf('\n%s ->\nPointer positioning to start of measurement/block #%.0f header failed.\n',FCTNAME,mCnt)
        return
    end
    measHdrLength(mCnt) = fread(fid,1,'uint32');            
end
measDataLength = measTotLength - measHdrLength;             % 
measStart      = measOffset + measHdrLength;                % start of measurement block,
% note that 1 measurement (i.e. scan) and potentially multiple channel headers are
% still to come

%--- consistency check ---
if measDataLength==0
    fprintf('\n%s ->\nZero data length detected. This file seems not to contain any data.\n\n',FCTNAME)
    return
end

%--- read data ---
scanHdrLength = 192;            % scan header length in bytes
chHdrLength   = 32;             % channel header length in bytes
% note that the 32 bytes result in 8 4-byte numbers (zeros) between FIDs
% if the data vector is read straight as uint32

%--- read repetitions and channels from file ---
% note that the actual data size in memory can be much longer than the data
% data length selected in the experiment and this seems all to be 'real'
% noisy data which at first glance could be real. For instance, the PRESS
% MRS data from JW/LK from NYSPI uses nspecC = 1024, but 4288 points are
% in the file corresponding to an alleged nspecC of 2144. Is this all
% measured and simply discared if nspecC < nspecC(measured) is selected by
% the user?

%--- read ushSamplesInScan from 1st scan header ---
% from ICE_....pdf manual
status = fseek(fid,measStart(nMeas),'bof');            % right before first scan header
if status<0
    fprintf('\nPointer positioning to start of scan header (position %.0f) failed.\n',measStart(nMeas))
    return
end
h.ulFlagsAndDMALength = fread(fid,1,'uint32');      % [4] byte
if isempty(h.ulFlagsAndDMALength)
    fprintf('\n%s ->\nUnknown data format. Check with Christoph for solutions (cwj2112@columbia.edu)\n\n',FCTNAME)
    return
end
h.lMeasUID            = fread(fid,1,'int32');       % [4] byte
h.ulScanCounter       = fread(fid,1,'uint32');      % [4] byte
h.ulTimeStamp         = fread(fid,1,'uint32');      % [4] byte
h.ulPMUTimeStamp      = fread(fid,1,'uint32');      % [4] byte
h.ushSystemType       = fread(fid,1,'uint16');      % [2] byte
h.ulPTABPosDelay      = fread(fid,1,'uint16');      % [2] byte
h.lPTABPosX           = fread(fid,1,'int32');       % [4] byte
h.lPTABPosY           = fread(fid,1,'int32');       % [4] byte
h.lPTABPosZ           = fread(fid,1,'int32');       % [4] byte
h.ulReserved          = fread(fid,1,'uint32');      % [4] byte
h.aulEvalInfoMask(1)  = fread(fid,1,'uint32');      % [4] byte
h.aulEvalInfoMask(2)  = fread(fid,1,'uint32');      % [4] byte
h.ushSamplesInScan    = fread(fid,1,'uint16');      % [2] byte
h.ushUsedChannels     = fread(fid,1,'uint16');      % [2] byte = nRcvrs
% ...
if h.ushUsedChannels==0
    fprintf('\n%s ->\nUnknown data format. Check with Christoph for solutions (cwj2112@columbia.edu)\n\n',FCTNAME)
    return
end

%--- update number of receivers ---
dataSpec.nRcvrs = h.ushUsedChannels;

%--- debugging option ---
if flag.debug
% if 0
    h                           % print temporary header structure h
    debugOffset = 0;          % 8 bytes per point
    fprintf('debugOffset      = %.1f bytes (= %.0f pts at 8 bytes / point)\n',...
            debugOffset/8,debugOffset)
    fprintf('ushSamplesInScan = %.0f\n',h.ushSamplesInScan)
else
    debugOffset = 0;
end

%--- consistency check ---
% data size vs. oversampling mode
if dataSpec.overSamplFac~=floor(h.ushSamplesInScan/dataSpec.nspecC)
    fprintf('\nOversampling factor is inconsistent with data size. Program aborted.\n')
    return
end

% data.spec1/2.fid format:    nspecC x nrcvrs x NR/block
% data.spec1/2.fidArr format: nblock x nspecC x nrcvrs x NR/block
% dataSpec.fid = complex(zeros(dataSpec.overSamplFac*dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr)); 
% dataSpec.fid = complex(zeros(h.ushSamplesInScan,dataSpec.nRcvrs,dataSpec.nr)); 
dataSpec.fid = complex(zeros(h.ushSamplesInScan,dataSpec.nRcvrs,dataSpec.nr)); 
for nrCnt = 1+dataSpec.dsOffset:dataSpec.nr+dataSpec.dsOffset                           % dataSpec.nr
    for chCnt = 1:dataSpec.nRcvrs
        % jump to start position of individual FIDs
        % status = fseek(fid,measStart(mCnt)+scanHdrLength+chCnt*chHdrLength+(chCnt-1)*dataSpec.nspecC*8,'bof');    
%         ptrOffset = measStart(nMeas) + ...
%                     nrCnt*scanHdrLength + ...
%                     ((nrCnt-1)*dataSpec.nRcvrs+chCnt)*chHdrLength + ...                 % behind channel header
%                     ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*((2*dataSpec.nspecC+96)*8);   % before FID data
%                     % ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*(2*dataSpec.nspecC*8);       % before FID data
        ptrOffset = measStart(nMeas) + ...
                    nrCnt*scanHdrLength + ...
                    ((nrCnt-1)*dataSpec.nRcvrs+chCnt)*chHdrLength + ...                 % behind channel header
                    ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*(h.ushSamplesInScan*8)+debugOffset;   % before FID data
%                     ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*((2*dataSpec.nspecC+96)*8)+8+debugOffset;   % before FID data

% Stony Brook: offset 96, syngo MR E11, svs_se, HeadNeck_20, nspecC 1024
% C:\Users\juchem\Data\Siemens_Jodi\002_Siemens_22May2017\PRESS_dat\SPX_PRESS_Sx1
% C:\Users\juchem\Data\Siemens_Jodi\002_Siemens_22May2017\PRESS_dat\Sx1\01_meas_MID00146_FID12593_svs_se_20_hippo.dat
%     ptrOffset = measStart(nMeas) + ...
%                 nrCnt*scanHdrLength + ...
%                 ((nrCnt-1)*dataSpec.nRcvrs+chCnt)*chHdrLength + ...                 % behind channel header
%                 ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*((2*dataSpec.nspecC+96)*8)+8;   % before FID data 
        
% ZMBBI: offset 0, syngo MR E11, HeadNeck_64, nspecC 2048
% C:\Users\juchem\Data\Siemens_ZMBBI\SPX_SVS_setup
% C:\Users\juchem\Data\Siemens_ZMBBI\01_meas_MID00094_FID01736_qa_svs_st_20.dat
% 
%         ptrOffset = measStart(nMeas) + ...
%                     nrCnt*scanHdrLength + ...
%                     ((nrCnt-1)*dataSpec.nRcvrs+chCnt)*chHdrLength + ...                 % behind channel header
%                     ((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*((2*dataSpec.nspecC)*8)+8;    % before FID data

                
        status = fseek(fid,ptrOffset,'bof');             
        if status<0
            fprintf('\nPointer positioning to start of FID (nMeas %.0f, NR #%.0f, receiver %.0f) failed.\n',nMeas,nrCnt,chCnt)
            fprintf('(for nRcvrs %.0f, nspecC %.0f, nr %.0f)\n\n',dataSpec.nRcvrs,dataSpec.nspecC,dataSpec.nr)
            return
        end
        % data = fread(fid,dataSpec.overSamplFac*2*dataSpec.nspecC,'float=>single');
        data = fread(fid,2*h.ushSamplesInScan,'float=>single');
        if flag.debug
            fprintf('nr %.0f, ch %.0f\n',nrCnt,chCnt)
        end
        % check for index being too high or incomplete data reading
        if nrCnt-dataSpec.dsOffset>dataSpec.nr || size(data,1)~=2*h.ushSamplesInScan
            fprintf('\n%s ->\nWARNING: Indexing exceeds data dimension:\n',FCTNAME);
            fprintf('nrCnt = %.0f, chCnt = %.0f, dsOffset = %.0f\n',nrCnt,chCnt,dataSpec.dsOffset);
        else
            dataSpec.fid(:,chCnt,nrCnt-dataSpec.dsOffset) = complex(data(1:2:end),data(2:2:end));
        end
    end
end

%--- file handling ---
fid = fclose(fid);
if fid < 0
    fprintf('%s ->\nClosing %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
end

%--- remove oversampling ---
% if 0
if dataSpec.overSamplFac==2
%     dataSpecFid = complex(zeros(dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr)); 
%     for nrCnt = 1:dataSpec.nr                           % dataSpec.nr
%         for chCnt = 1:dataSpec.nRcvrs
%             dataSpecFid(:,chCnt,nrCnt) = decimate(dataSpec.fid(:,chCnt,nrCnt),dataSpec.overSamplFac);
%         end
%     end

    %--- remove digitizer offset / sequence misadjustment ---
    % this might need to be refined and made specific to:
    % 1) MRS sequence
    % 2) digitazation filter (i.e. hardware)
    % 3) potentially MR system
    
    % do on oversampled data for [deg/ppm] resolution
    ptExtra = h.ushSamplesInScan - 2*dataSpec.nspecC;       % number of trailining (non-data) points
    
    % sequence selection
    if strcmp(dataSpec.sequence,'svs_se')               % Siemens stock sequence: PRESS
        ptShift = 12;
        ptShift = min(ptShift,ptExtra);                     % max shift while staying within vector size 
    elseif strcmp(dataSpec.sequence,'svs_st')           % Siemens stock sequence: STEAM
        ptShift = 14;
        ptShift = min(ptShift,ptExtra);                     % max shift while staying within vector size 
    elseif strcmp(dataSpec.sequence,'hx_svs_edit_de2')      % Stony Brook, Xiang He
        ptShift = 12;                                   % 12
    else                                                % any other sequence, incl. eja_ (UMN)
        ptShift = 0;
        ptShift = min(ptShift,ptExtra);                     % max shift while staying within vector size 
    end
    
    if strcmp(dataSpec.sequence,'hx_svs_edit_de2')
        dataSpecTmp  = ifft(dataSpec.fid(1+ptShift:2*dataSpec.nspecC,:,:),[],1);            % odd a problem for quadrant below?
        dataSpec.fid = complex(zeros(dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr)); 
        dataSpec.fid(1:size(dataSpecTmp,1)/2,:,:) = fft(dataSpecTmp([1:size(dataSpecTmp,1)/4 3*size(dataSpecTmp,1)/4+1:end],:,:),[],1);
    else
        dataSpecTmp  = ifft(dataSpec.fid(1+ptShift:2*dataSpec.nspecC+ptShift,:,:),[],1);    % odd a problem for quadrant below?
        dataSpec.fid = fft(dataSpecTmp([1:size(dataSpecTmp,1)/4 3*size(dataSpecTmp,1)/4+1:end],:,:),[],1);
    end
%     dataSpecTmp  = ifft(dataSpec.fid,[],1);
%      dataSpecTmp  = ifft(dataSpec.fid(1:dataSpec.overSamplFac*dataSpec.nspecC,:,:),[],1);

    % dataSpec.fid = dataSpec.fid(1:dataSpec.nspecC,:,:);
    % PRESS
    % ptShift = 6;
    % STEAM
    % ptShift = 7;
%     dataSpec.fid = dataSpec.fid(1+ptShift:dataSpec.nspecC+ptShift,:,:);
elseif dataSpec.overSamplFac==3
    fprintf('%s ->\nOversampling other than a factor of 2 is not supported. Program aborted.\n',FCTNAME)
    return
else
    dataSpec.fid = dataSpec.fid(1:dataSpec.nspecC,:,:);
end
% dataSpec.nspecC = dataSpec.nspecC * 2;
    
%--- info printout ---
fprintf('%s ->\nData file successfully read\n',FCTNAME);
fprintf('nr/nspecC/nRcvrs: %d+%d/%d/%d\n',dataSpec.trOffset,...
        dataSpec.nr-dataSpec.trOffset,dataSpec.nspecC,dataSpec.nRcvrs);

%--- update success flag ---
f_succ = 1;


