%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec,f_done] = SP2_Data_VnmrReadFidSatRec(dataSpec)
%%
%%  Function to read Varian's JNMR fid data files.
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_VnmrReadFidSatRec';

%--- direct assignment of byte order (for now) ---
BYTORDA = 'big';

%--- success flag init ---
f_done = 0;

%--- data format handling ---
if strcmp(dataSpec.wordSize,'32bit')
   nBytes    = 4;                   % 32 bit 
   precision = 'float32';
else
   nBytes    = 2;                   % 16 bit 
   precision = 'float16';
end
if strcmp(BYTORDA, 'big')
   byteOrder = 'ieee-be';           % 'ieee-be' big endian for PC
elseif strcmp(BYTORDA, 'little')
   byteOrder = 'ieee-le';           % 'ieee-le' little endian for Linux
else
   fprintf('%s -> Unknown type <%s> for BYTORDA\n\n',FCTNAME,BYTEORDA)
   return
end

%--- consistency check: data format ---
if ~strcmp(dataSpec.seqcon,'ccsnn')
    fprintf('%s ->\nUnexpected data format detected: seqcon = ''%s''\n',...
            FCTNAME,dataSpec.seqcon)
    return
end

%--- check file existence ---
if 2==exist(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fSize  = thedir.bytes;
else
    fprintf('%s -> File %s doesn''nt exist\n\n',FCTNAME,dataSpec.fidFile)
    return
end
    
%--- file handling ---
[fid, msg] = fopen(dataSpec.fidFile,'r',byteOrder);
if fid <= 0
    fprintf('%s ->\nOpening %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
end

%--- data blocks ---
dhSize  = 32;         % data header size [byte]
bhSize  = 28;         % bock header size [byte]

% note that the experiment contains dataSpec.nr blocks
% as a combination of serial steps (actual NR) and the number of phase
% cycling steps (ni).

%--- read data from file ---
datFidTmp = complex(zeros(1,dataSpec.nRcvrs*dataSpec.nr*dataSpec.nspecC));  % init tmp data vector
if dataSpec.saveSep
    % FIDs saved separately via dummy phase encoding loop:
    % single block header before every phase encoding step, i.e. a set of
    % traces from all receivers
    traceCnt  = 0;                              % total trace counter
    fseek(fid,dhSize,'bof');                    % jump to last byte of data header
    for nrCnt = 1:dataSpec.nr*dataSpec.nRcvrs
        fseek(fid,bhSize,'cof');                % skip the block header
        [datRead,fCnt] = fread(fid,2*dataSpec.nspecC,precision);    % read single block
        if fCnt ~= 2*dataSpec.nspecC                                % check
            fprintf('%s ->\nReading data from file <fid> failed at trace %.f\n',FCTNAME,traceCnt)
            fprintf('fCnt (%i) ~= 2*nspecC (%i)\n\n',fCnt,2*dataSpec.nspecC)
            return
        end 
        datRaw  = reshape(datRead,2,dataSpec.nspecC);
        datFidTmp(1,(nrCnt-1)*dataSpec.nspecC+1:nrCnt*dataSpec.nspecC) = complex(datRaw(2,:),datRaw(1,:));
    end
    
    %--- data reformating ---
    if dataSpec.nv>1        % metabolite scan
        %--- old, before June 2015 ---
        % dataSpec.fid = permute(reshape(datFidTmp,dataSpec.nspecC,dataSpec.nr,dataSpec.nRcvrs),[1 3 2]);
        % note that NR contains both the phase cycle and the number of sat-rec. delays
        % dataSpec.nSatRec = dataSpec.nr/dataSpec.nv;
        % dataSpec.fid = reshape(dataSpec.fid,dataSpec.nspecC,dataSpec.nv,dataSpec.nRcvrs,dataSpec.nSatRec);
        % dataSpec.fid = permute(dataSpec.fid,[1 3 2 4]);
        % final format: 1) nspecC, 2) rcvrs, 3) nv(ph.cycle), 4) sat-rec

        %--- new, after June 2015 ---
        dataSpec.nSatRec = dataSpec.nr/dataSpec.nv;
        dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nSatRec,dataSpec.nv);
        dataSpec.fid = permute(dataSpec.fid,[1 2 4 3]);
    else                    % water reference
        dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nr,dataSpec.nRcvrs);
        % note that NR contains both the phase cycle and the number of sat-rec. delays
        dataSpec.nSatRec = dataSpec.nr/dataSpec.nv;
        dataSpec.fid = reshape(dataSpec.fid,dataSpec.nspecC,dataSpec.nv,dataSpec.nRcvrs,dataSpec.nSatRec);
        dataSpec.fid = permute(dataSpec.fid,[1 3 2 4]);
        % final format: 1) nspecC, 2) rcvrs, 3) nv(ph.cycle), 4) sat-rec
    end
else
    % straight-forward acquisition of repeats:
    % FIDs are averaged on the machine and saved as single FID
    % block header before every trace of every repetition and receiver
    bSize = 2*dataSpec.nspecC*nBytes;                       % trace size (here = block size)
    for bCnt = 1:dataSpec.nr*dataSpec.nRcvrs
        fseek(fid,dhSize+bCnt*bhSize+(bCnt-1)*bSize,'bof');     % jump to last byte of each block header
        if ftell(fid) ~= dhSize+bCnt*bhSize+(bCnt-1)*bSize      % check
            fprintf('%s ->\nFile pointer handling for data access failed at bCnt=%d\n\n',FCTNAME,bCnt)
            return
        end   
        [datRead,fCnt] = fread(fid,2*dataSpec.nspecC,precision);    % read single block
        if fCnt ~= 2*dataSpec.nspecC                                % check
            fprintf('%s ->\nReading data from file <fid> failed at bCnt=%.f\n\n',FCTNAME,bCnt)
            return
        end 
        datRaw  = reshape(datRead,2,dataSpec.nspecC);
        datFidTmp(1,(bCnt-1)*dataSpec.nspecC+1:bCnt*dataSpec.nspecC) = complex(datRaw(2,:),datRaw(1,:));
    end
    
    %--- data reformating ---
    if dataSpec.nr==1 && dataSpec.nRcvrs==1         % NR=1, nRcvrs=1
        dataSpec.fid = datFidTmp;
    elseif dataSpec.nr>1 && dataSpec.nRcvrs==1      % NR>1, nRcvrs=1
        dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nr);
    elseif dataSpec.nr==1 && dataSpec.nRcvrs>1      % NR=1, nRcvrs>1
        dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nRcvrs);
    else                                            % NR>1, nRcvrs>1
        dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr);
    end
end

%--- close data file ---
fclose(fid);
    
%--- info printout ---
fprintf('%s ->\nfid file successfully read: dim <np/2><nRcvrs><nv><nSatRec>: %d/%d/%d/%d\n',...
        FCTNAME,dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nv,dataSpec.nSatRec);

%--- success flag update ---
f_done = 1;

end
