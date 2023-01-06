%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec,f_done] = SP2_Data_VnmrReadFidArray(dataSpec)
%%
%%  Function to read Varian's JNMR fid data file of arrayed MRS experiment.
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_Data_VnmrReadFidArray';

%--- direct assignment of byte order (for now) ---
BYTORDA = 'big';

%--- success flag init ---
f_done = 0;

%--- data format handling ---
if strcmp(dataSpec.wordSize,'32bit')
   nBytes    = 4;                  % 32 bit 
   precision = 'float32';
else
   nBytes    = 2;                  % 16 bit 
   precision = 'float16';
end
if strcmp(BYTORDA, 'big')
   byteOrder = 'ieee-be';       % 'ieee-be' big endian for PC
elseif strcmp(BYTORDA, 'little')
   byteOrder = 'ieee-le';       % 'ieee-le' little endian for Linux
else
   fprintf('%s ->\nUnknown type <%s> for BYTORDA\n\n',FCTNAME,BYTEORDA)
   return
end

%--- check file existence ---
if 2==exist(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fSize  = thedir.bytes;
else
    fprintf('%s ->\nFile %s doesn''nt exist\n\n',FCTNAME,dataSpec.fidFile)
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

%--- read data from file ---
datFidTmp = complex(zeros(1,dataSpec.nr*dataSpec.nspecC*dataSpec.nRcvrs));  % init tmp data vector
if dataSpec.saveSep
    if strcmp(dataSpec.seqcon(3),'c')
        % FIDs saved separately via dummy phase encoding loop:
        % single block header before every phase encoding step, i.e. a set of
        % traces from all receivers
        % notably, the nr is the inner loop (!), then nRcvrs, then JDE
        traceCnt  = 0;                              % total trace counter
        fseek(fid,dhSize,'bof');                    % jump to last byte of data header
        for rcvCnt = 1:dataSpec.nRcvrs
            for nrCnt = 1:dataSpec.nr
                fseek(fid,bhSize,'cof');            % skip the block header
                traceCnt = traceCnt + 1;
                [datRead,fCnt] = fread(fid,2*dataSpec.nspecC,precision);    % read single block
                if fCnt ~= 2*dataSpec.nspecC                                % check
                    fprintf('%s ->\nReading data from file <fid> failed at trace %.f\n',FCTNAME,traceCnt)
                    fprintf('fCnt (%i) ~= 2*nspecC (%i)\n\n',fCnt,2*dataSpec.nspecC)
                    return
                end 
                datRaw  = reshape(datRead,2,dataSpec.nspecC);
                datFidTmp(1,(traceCnt-1)*dataSpec.nspecC+1:traceCnt*dataSpec.nspecC) = complex(datRaw(2,:),datRaw(1,:));
            end
        end

        %--- data reformating ---
        if dataSpec.nr==1 && dataSpec.nRcvrs==1         % NR=1, nRcvrs=1
            dataSpec.fid = datFidTmp;
        elseif dataSpec.nr>1 && dataSpec.nRcvrs==1      % NR>1, nRcvrs=1
            dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nr);
        elseif dataSpec.nr==1 && dataSpec.nRcvrs>1      % NR=1, nRcvrs>1
            dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nRcvrs);
        else                                            % NR>1, nRcvrs>1
            if dataSpec.njde==2                         % regular (single) JDE experiment
                % orig. data format
%                 dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nr,dataSpec.nRcvrs);
%                 % move phase cycling and JDE to the back, note order: 4 then 2
%                 dataSpec.fid = permute(dataSpec.fid,[1 3 4 2]);
%                 % combine phase cycle and JDE
                dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr);    
            else                                        % combined (multi-metabolite) JDE experiment
                % orig. data format
                dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nr,dataSpec.nRcvrs);
                % data selection
                if flag.dataEditNo==1       % 1st condition + last
                    dataSpec.fid = dataSpec.fid(:,:,:,[1 3]);
                    fprintf('JDE selection: First & last condition.\n')
                else                        % 2nd condition + last
                    dataSpec.fid = dataSpec.fid(:,:,:,[2 3]);
                    fprintf('JDE selection: Second & last condition.\n')
                end
                % move phase cycling and JDE to the back, note order: 4 then 2
                dataSpec.fid = permute(dataSpec.fid,[1 3 4 2]);
                % combine phase cycle and JDE
                % note that .nr still contains the full 
                dataSpec.fid = reshape(dataSpec.fid,dataSpec.nspecC,dataSpec.nRcvrs,2*dataSpec.nr/3);       
            end
        end
    else                % standard mode
        % FIDs saved separately via dummy phase encoding loop:
        % single block header before every phase encoding step, i.e. a set of
        % traces from all receivers
        % notably, the nr is the inner loop (!), then nRcvrs, then JDE
        traceCnt  = 0;                              % total trace counter
        fseek(fid,dhSize,'bof');                    % jump to last byte of data header
        for trCnt = 1:dataSpec.njde*dataSpec.nRcvrs*(dataSpec.nr/dataSpec.njde)
            fseek(fid,bhSize,'cof');                    % skip the block header
            [datRead,fCnt] = fread(fid,2*dataSpec.nspecC,precision);    % read single block
            if fCnt ~= 2*dataSpec.nspecC                                % check
                fprintf('%s ->\nReading data from file <fid> failed at trace %.f\n',FCTNAME,trCnt)
                fprintf('fCnt (%i) ~= 2*nspecC (%i)\n\n',fCnt,2*dataSpec.nspecC)
                return
            end 
            datRaw  = reshape(datRead,2,dataSpec.nspecC);
            datFidTmp(1,(trCnt-1)*dataSpec.nspecC+1:trCnt*dataSpec.nspecC) = complex(datRaw(2,:),datRaw(1,:));
        end

        %--- data reformating ---
        if dataSpec.nr==1 && dataSpec.nRcvrs==1         % NR=1, nRcvrs=1
            fprintf('NR=1, #receivers=1 is currently not supported.\n')
            return
            % dataSpec.fid = datFidTmp;
        elseif dataSpec.nr>1 && dataSpec.nRcvrs==1      % NR>1, nRcvrs=1
            fprintf('NR>1, #receivers=1 is currently not supported.\n')
            return
            % dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nr);
        elseif dataSpec.nr==1 && dataSpec.nRcvrs>1      % NR=1, nRcvrs>1
            fprintf('NR=1, #receivers>1 is currently not supported.\n')
            return
            % dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nRcvrs);          % not tested
        else                                            % NR>1, nRcvrs>1
            % orig. data format
            dataSpec.fid = reshape(datFidTmp,dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.njde,...
                                   dataSpec.nr/dataSpec.njde);
            % move phase cycling and JDE to the back, note order: 4 then 2
%             dataSpec.fid = permute(dataSpec.fid,[1 2 4 3]);
            % combine phase cycle and JDE
            dataSpec.fid = reshape(dataSpec.fid,dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr);    
        end
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
fprintf('%s ->\nfid file successfully read: dim <np/2><nRcvrs><nr>: %d/%d/%d\n',...
        FCTNAME,dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr);

%--- success flag update ---
f_done = 1;

end
