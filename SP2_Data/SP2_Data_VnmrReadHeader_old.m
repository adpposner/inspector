%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dHeader,bHeader] = SP2_Data_VnmrReadHeaders(file)
%%
%%  function [dHeader,bHeader] = SP2_Data_VnmrRdHeader(file)
%%  function to read the data header (dHeader) and all the group headers
%%  if they exist, i.e. the data has been saved uncompressed
%%
%%  01-2008, Ch.Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global method

FCTNAME = 'SP2_Data_VnmrRdHeader';


%--- direct assignment of byte order (for now) ---
BYTORDA = 'big';

%--- data format handling ---
if strcmp(method.dp,'y')
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
   error(sprintf('%s: unknown type <%s> for BYTORDA',FCTNAME,BYTORDA))
end

%--- check file existence ---
if 2==exist(file)
    thedir = dir(file);
    fSize = thedir.bytes;
else
    error(sprintf('%s -> the file %s doesn''nt exist\n',FCTNAME,file));
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
    error(sprintf('%s -> opening %s failed; %s',FCTNAME,file,msg))   
end

%--- read (relevant) data blocks ---
dhSize  = 32;                   % data header size [byte]
if strcmp(method.seqcon(3),'c') % block header size [byte]
    bhSize = 0;                 % compressed, i.e. no header        
else                            % standard, i.e. with block headers
    bhSize = 28;                % not compressed, i.e. header before each block
end
bSize   = method.np*method.nf*nBytes;       % readout * (slices * echo number)
%--- read data header ---
% number of blocks in file
[dHeader.nblocks,fCount] = fread(fid,1,'long');
if ~fCount
    error('%s -> reading nblocks from data header failed',FCTNAME)
end
% number of traces per block
[dHeader.ntraces,fCount] = fread(fid,1,'long');
if ~fCount
    error('%s -> reading ntraces from data header failed',FCTNAME)
end
% number of elements per trace
[dHeader.np,fCount] = fread(fid,1,'long');
if ~fCount
    error('%s -> reading np from data header failed',FCTNAME)
end
% number of bytes per element
[dHeader.ebytes,fCount] = fread(fid,1,'long');
if ~fCount
    error('%s -> reading ebytes from data header failed',FCTNAME)
end
% number of bytes per trace
[dHeader.tbytes,fCount] = fread(fid,1,'long');
if ~fCount
    error('%s -> reading tbytes from data header failed',FCTNAME)
end
% number of bytes per block
[dHeader.bbytes,fCount] = fread(fid,1,'long');
if ~fCount
    error('%s -> reading bbytes from data header failed',FCTNAME)
end
% software version, file_id status bits
[dHeader.vers_id,fCount] = fread(fid,1,'short');
if ~fCount
    error('%s -> reading vers_id from data header failed',FCTNAME)
end
% status of whole file
[dHeader.status,fCount] = fread(fid,1,'short');
if ~fCount
    error('%s -> reading status from data header failed',FCTNAME)
end
% number of block headers per block
[dHeader.nbheaders,fCount] = fread(fid,1,'long');
if ~fCount
    error('%s -> reading nbheaders from data header failed',FCTNAME)
end

if dhSize>0
    %--- read block header(s) ---
    for bCnt = 1:method.ni
        %--- file pointer handling ---
        fseek(fid,dhSize+(bCnt-1)*(bhSize+bSize),'bof');     % jump to last byte of each block header
        % fprintf('before: %i\n',ftell(fid));
        if ftell(fid) ~= dhSize+(bCnt-1)*(bhSize+bSize)      % check
            error(sprintf('%s -> file pointer handling for data access failed at icnt=%d\n',FCTNAME,bCnt));
        end

        %--- retrieve header values ---
        for hCnt = 1:9
            switch hCnt
                case 1
                    % scaling factor
                    [bHeader.scale(bCnt),fCount] = fread(fid,1,'short');
                    if ~fCount
                        error('%s -> reading scale from block header %i failed',FCTNAME,hCnt)
                    end
                case 2
                    % status of data in block
                    [bHeader.status(bCnt),fCount] = fread(fid,1,'short');
                    if ~fCount
                        error('%s -> reading status from block header %i failed',FCTNAME,hCnt)
                    end
                case 3
                    % block index
                    [bHeader.index(bCnt),fCount] = fread(fid,1,'short');
                    if ~fCount
                        error('%s -> reading index from block header %i failed',FCTNAME,hCnt)
                    end
                case 4
                    % mode of data in block
                    [bHeader.mode(bCnt),fCount] = fread(fid,1,'short');
                    if ~fCount
                        error('%s -> reading mode from block header %i failed',FCTNAME,hCnt)
                    end
                case 5
                    % ct value for FID
                    [bHeader.ctcount(bCnt),fCount] = fread(fid,1,'long');
                    if ~fCount
                        error('%s -> reading ctcount from block header %i failed',FCTNAME,hCnt)
                    end
                case 6
                    % f2 (2D-f1) left phase in phasefile
                    [bHeader.lpval(bCnt),fCount] = fread(fid,1,'float');
                    if ~fCount
                        error('%s -> reading lpval from block header %i failed',FCTNAME,hCnt)
                    end
                case 7
                    % f2 (2D-f1) right phase in phasefile
                    [bHeader.rpval(bCnt),fCount] = fread(fid,1,'float');
                    if ~fCount
                        error('%s -> reading rpval from block header %i failed',FCTNAME,hCnt)
                    end
                case 8
                    % level drift correction
                    [bHeader.lvl(bCnt),fCount] = fread(fid,1,'float');
                    if ~fCount
                        error('%s -> reading lvl from block header %i failed',FCTNAME,hCnt)
                    end
                case 9
                    % tilt drift correction
                    [bHeader.tlt(bCnt),fCount] = fread(fid,1,'float');
                    if ~fCount
                        error('%s -> reading tlt from block header %i failed',FCTNAME,hCnt)
                    end
            end
        end

        %--- file pointer check ---
        if ftell(fid) ~= dhSize+(bCnt-1)*(bhSize+bSize)+bhSize
            fprintf('%s -> Inconsistent file pointer position (%i)\n',FCTNAME,ftell(fid))
            fprintf('Reading group header failed at bCnt=%.f\n',bCnt)
            return
        end
    end
    %--- consistency check ---
    if ftell(fid)~=fSize-bSize
        fprintf('\n\nCAUTION:')
        fprintf('%s -> header reading not successful:\n')
        fprintf('EOF - (1 data block) not reached ftell (%i) < file size (%i) - 1 block (%i) = %i\n\n',...
                FCTNAME,ftell(fid),fSize,bSize,fSize-bSize)
    end
else
   bHeader = {};
end
   
%--- info printout ---
fprintf('header(s) successfully read\n')
