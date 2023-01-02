%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_succ] = SP2_Data_PhilipsRawReadFidJDE(dataSpec)
%%
%%  Function to read MR spectroscopy data in Siemens' raw data format (rda).
%%
%%  10/2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_Data_PhilipsRawReadFidJDE';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if 2==exist(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fSize  = thedir.bytes;
else
    fprintf('%s -> File %s doesn''nt exist\n\n',FCTNAME,dataSpec.fidFile)
    return
end

%--- file handling ---
[fid, msg] = fopen(dataSpec.fidFile,'r','ieee-le');         % little endian for linux
if fid <= 0
    fprintf('%s ->\nOpening %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
else
    %--- info printout --
    fprintf('Reading <%s>\n',dataSpec.fidFile);
    fprintf('nr/nspecC/nRcvrs: %d+%d/%d/%d\n',dataSpec.trOffset,...
            dataSpec.nr-dataSpec.trOffset,dataSpec.nspecC,dataSpec.nRcvrs);
end

%--- read data from file ---
baseOffset = 1000;
% baseOffset = 500;
if fseek(fid,baseOffset,'bof')<0
    fprintf('\nPointer positioning to start of numeric data failed\n')
    return
end
[fileData,nBytes] = fread(fid,inf,'int16');
if flag.debug
    fprintf('%.0f bytes read from file.\n',nBytes+baseOffset)
end
fileData = double(fileData);
% datStart = find(abs(fileData)>10,1);            % first data point, works for regular MRS (Jannie), does not work for JDE (Jannie)
datStart = find(abs(fileData)>10,1);               % first data point, works for both, 
% data starting position: 1048469

%--- debugging option ---
if flag.verbose
    fprintf('file pointer position at end of file:  %.0f bytes\n',ftell(fid))
    fprintf('data starting position: %.0f\n',datStart)
end

datRaw  = fileData(datStart:end);                                   % extract data
datComp = complex(datRaw(1:2:end-1),datRaw(2:2:end));       % convert to complex

flag.debug = 0;

%--- read repetitions and channels from file ---
datFid = complex(zeros(dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr)); 
for nrCnt = 1:dataSpec.nr                           % dataSpec.nr
    for chCnt = 1:dataSpec.nRcvrs
        %--- degubbing option ---
        if flag.debug
            fprintf('nrCnt %.0f, chCnt %.0f\n',nrCnt,chCnt)
        end
        
        %--- data assignment ---
%         datFid(:,chCnt,nrCnt) = ...
%             downsample(datComp(((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*dataSpec.nspecCOver+1:((nrCnt-1)*dataSpec.nRcvrs+chCnt)*dataSpec.nspecCOver,1),8);
        datFidTmp = downsample(datComp(((nrCnt-1)*dataSpec.nRcvrs+(chCnt-1))*dataSpec.nspecCOver+1:((nrCnt-1)*dataSpec.nRcvrs+chCnt)*dataSpec.nspecCOver,1),8);
        datFid(:,chCnt,nrCnt) = datFidTmp(1:dataSpec.nspecC);
    end
end

%--- consistency check here ---
fprintf('%s ->\n%s read.\n',FCTNAME,dataSpec.fidFile)

% %--- data formating ---
% datFid       = reshape(datFid,2,procpar.VectorSize,procpar.CSIMatrixSize(1),procpar.CSIMatrixSize(2),procpar.CSIMatrixSize(3));
% dataSpec.fid = complex(datFid(2,:,:,:,:),datFid(1,:,:,:,:));
% if size(dataSpec.fid,1)==1
%     dataSpec.fid = dataSpec.fid.';
% end

%--- update success flag ---
f_succ = 1;


