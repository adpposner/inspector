%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dHeader,bHeader,f_read] = SP2_Data_VnmrReadHeaders(file)
%%
%%  function [dHeader,bHeader,f_read] = SP2_Data_VnmrRdHeader(file)
%%  function to read the data header (dHeader) and all the group headers
%%  if they exist, i.e. the data has been saved uncompressed
%%
%%  01-2008, Ch.Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global procpar

FCTNAME = 'SP2_Data_VnmrRdHeader';


%--- define global parameters ---
DHSIZE = 32;              % data header size [bytes]
BHSIZE = 28;              % block header size [bytes]

%--- return pars init ---
dHeader = [];
bHeader = [];
f_read  = 0;

%--- direct assignment of byte order (for now) ---
BYTORDA = 'big';

%--- data format handling ---
if strcmp(procpar.dp,'y')
   nBytes = 4;                  % 32 bit 
   PRECISION = 'float32';
else
   nBytes = 2;                  % 16 bit 
   PRECISION = 'float16';
end
if strcmp(BYTORDA, 'big')
   BYTEORDER = 'ieee-be';       % 'ieee-be' big endian for PC
elseif strcmp(BYTORDA, 'little')
   BYTEORDER = 'ieee-le';       % 'ieee-le' little endian for Linux
else
   BYTORDA
   fprintf('%s: unknown type <%s> for BYTORDA',FCTNAME,BYTORDA)
   return
end

%--- check file existence ---
if exist(file)==2
    thedir = dir(file);
    fSize = thedir.bytes;
else
    fprintf('%s -> the file %s doesn''nt exist\n',FCTNAME,file)
    return
end
    
%--- check file size ---
% to be added when compressed/non-compressed and all other dimension
% parameters are clear
% fSize = 32(data header) + n*(0/28(block header) + block size)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
%

%--- file handling ---
% [fid, message] = fopen(file, 'r', BYTEORDER);
[fid, msg] = fopen(file,'r',BYTEORDER);
if fid <= 0   
    fprintf('%s -> opening %s failed; %s',FCTNAME,file,msg)
    return
end

%--- DATA HEADER HANDLING ---
% number of blocks in file
[dHeader.nblocks,fCount] = fread(fid,1,'long');
if ~fCount
    fprintf('%s -> reading nblocks from data header failed\n',FCTNAME)
    return
end
% number of traces per block
[dHeader.ntraces,fCount] = fread(fid,1,'long');
if ~fCount
    fprintf('%s -> reading ntraces from data header failed\n',FCTNAME)
    return
end
% number of elements per trace
[dHeader.np,fCount] = fread(fid,1,'long');
if ~fCount
    fprintf('%s -> reading np from data header failed\n',FCTNAME)
    return
end
% number of bytes per element
[dHeader.ebytes,fCount] = fread(fid,1,'long');
if ~fCount
    fprintf('%s -> reading ebytes from data header failed\n',FCTNAME)
    return
end
% number of bytes per trace
[dHeader.tbytes,fCount] = fread(fid,1,'long');
if ~fCount
    fprintf('%s -> reading tbytes from data header failed\n',FCTNAME)
    return
end
% number of bytes per block
[dHeader.bbytes,fCount] = fread(fid,1,'long');
if ~fCount
    fprintf('%s -> reading bbytes from data header failed\n',FCTNAME)
    return
end
% software version, file_id status bits
[dHeader.vers_id,fCount] = fread(fid,1,'short');
if ~fCount
    fprintf('%s -> reading vers_id from data header failed\n',FCTNAME)
    return
end
% status of whole file
[dHeader.status,fCount] = fread(fid,1,'short');
if ~fCount
    fprintf('%s -> reading status from data header failed\n',FCTNAME)
    return
end
% number of block headers per block
[dHeader.nbheaders,fCount] = fread(fid,1,'long');
if ~fCount
    fprintf('%s -> reading nbheaders from data header failed\n',FCTNAME)
    return
end


%--- BLOCK HEADER HANDLING ---
% Even in compressed mode (i.e. strcmp(procpar.seqcon(3),'n')) there is at least one block header
datBlockSize = dHeader.bbytes-BHSIZE;     % data block size
% note that the header block size includes the block header size)
    
%--- read block header(s) ---
for bCnt = 1:dHeader.nblocks
    %--- file pointer handling ---
    fseek(fid,DHSIZE+(bCnt-1)*(BHSIZE+datBlockSize),'bof');     % jump to last byte of each block header
    % fprintf('before: %i\n',ftell(fid));
    if ftell(fid) ~= DHSIZE+(bCnt-1)*(BHSIZE+datBlockSize)      % check
        fprintf('%s -> file pointer handling for data access failed at icnt=%d\n',FCTNAME,bCnt)
        return
    end

    %--- retrieve header values ---
    for hCnt = 1:9
        switch hCnt
            case 1
                % scaling factor
                [bHeader.scale(bCnt),fCount] = fread(fid,1,'short');
                if ~fCount
                    fprintf('%s -> reading scale from block header %i failed',FCTNAME,hCnt)
                    return
                end
            case 2
                % status of data in block
                [bHeader.status(bCnt),fCount] = fread(fid,1,'short');
                if ~fCount
                    fprintf('%s -> reading status from block header %i failed',FCTNAME,hCnt)
                    return
                end
            case 3
                % block index
                [bHeader.index(bCnt),fCount] = fread(fid,1,'short');
                if ~fCount
                    fprintf('%s -> reading index from block header %i failed',FCTNAME,hCnt)
                    return
                end
            case 4
                % mode of data in block
                [bHeader.mode(bCnt),fCount] = fread(fid,1,'short');
                if ~fCount
                    fprintf('%s -> reading mode from block header %i failed',FCTNAME,hCnt)
                    return
                end
            case 5
                % ct value for FID
                [bHeader.ctcount(bCnt),fCount] = fread(fid,1,'long');
                if ~fCount
                    fprintf('%s -> reading ctcount from block header %i failed',FCTNAME,hCnt)
                    return
                end
            case 6
                % f2 (2D-f1) left phase in phasefile
                [bHeader.lpval(bCnt),fCount] = fread(fid,1,'float');
                if ~fCount
                    fprintf('%s -> reading lpval from block header %i failed',FCTNAME,hCnt)
                    return
                end
            case 7
                % f2 (2D-f1) right phase in phasefile
                [bHeader.rpval(bCnt),fCount] = fread(fid,1,'float');
                if ~fCount
                    fprintf('%s -> reading rpval from block header %i failed',FCTNAME,hCnt)
                    return
                end
            case 8
                % level drift correction
                [bHeader.lvl(bCnt),fCount] = fread(fid,1,'float');
                if ~fCount
                    fprintf('%s -> reading lvl from block header %i failed',FCTNAME,hCnt)
                    return
                end
            case 9
                % tilt drift correction
                [bHeader.tlt(bCnt),fCount] = fread(fid,1,'float');
                if ~fCount
                    fprintf('%s -> reading tlt from block header %i failed',FCTNAME,hCnt)
                    return
                end
        end
    end

    %--- file pointer check ---
    if ftell(fid) ~= DHSIZE+(bCnt-1)*(BHSIZE+datBlockSize)+BHSIZE
        fprintf('%s -> Inconsistent file pointer position (%i)\n',FCTNAME,ftell(fid))
        fprintf('Reading group header failed at bCnt=%.f\n',bCnt)
        return
    end
end
%--- consistency check ---
if ftell(fid)~=fSize-datBlockSize
    fprintf('\n\nCAUTION:')
    fprintf('%s -> header reading not successful:\n',FCTNAME)
    fprintf('EOF - (1 data block) not reached ftell (%i) < file size (%i) - 1 block (%i) = %i\n\n',...
            FCTNAME,ftell(fid),fSize,datBlockSize,fSize-datBlockSize)
end

%--- success flag assignment ---
f_read = 1;

%--- info printout ---
fprintf('header(s) successfully read\n')
