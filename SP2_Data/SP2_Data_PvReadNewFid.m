%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_done] = SP2_Data_PvReadNewFid(dataSpec)
%%
%%  Function to read all kind of unregular data formats (e.g. reduced data
%%  formats after XWINNMR 'convdta' or for circular k-space sampling) from
%%  file.
%%
%%  02-2004 / 02-2008 / 03-2017, Ch.Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_PvReadNewFid';
global loggingfile

%--- init success flag ---
f_done = 0;

%--- init datFid ---
datFid = 0;

%--- variable assignment ---
nspecC = dataSpec.nspecC;
nx     = dataSpec.nx;
ny     = dataSpec.ny;
ns     = dataSpec.ns;
ni     = dataSpec.ni;
nr     = dataSpec.nr;
nRcvrs = dataSpec.nRcvrs;

%--- data format handling ---
if strcmp(dataSpec.wordSize,'_16_BIT')
   NumBytes  = 2;              % 16 bit 
   PRECISION = 'int16';
elseif strcmp(dataSpec.wordSize,'_32_BIT')
   NumBytes  = 4;              % 32 bit 
   PRECISION = 'int32';
else
   SP2_Logger.log('%s: unknown type <%s> for ACQ_word_size\n',FCTNAME,dataSpec.wordSize);
   return
end
if strcmp(dataSpec.byteOrder,'big')
   BYTEORDER = 'ieee-be';     % 'ieee-be' big endian for PC
elseif strcmp(dataSpec.byteOrder,'little')
   BYTEORDER = 'ieee-le';     % 'ieee-le' little endian for Linux
else
   SP2_Logger.log('%s: unknown type <%s> for BYTORDA',FCTNAME,dataSpec.byteOrder);
end

%--- check file existence ---
if 2==exist(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fsize = thedir.bytes;
else
    SP2_Logger.log('%s -> The file %s doesn''nt exist\n',FCTNAME, dataSpec.fidFile);
    return
end
    
%--- consistency check: expected data size vs. file size ---
% note that the repetitions (nr) have already been collapsed here
if ( fsize/NumBytes == (2*nspecC)*nx*ny*ns*ni*nr*nRcvrs)
    SP2_Logger.log('%s\treading <%s>\n',mfilename, dataSpec.fidFile);
    fprintf(loggingfile,'nspec/nx/ny/ns/ni/nr/nRcvrs: %d/%d/%d/%d/%d/%d/%d filesize %dk\n', ...
            2*nspecC,nx,ny,ns,ni,nr,nRcvrs,fsize/1024);
else
    fprintf(loggingfile,'%s: nint %d ~= nspec*nx*ny*ni*ns*nr*nRcvrs = %d*%d*%d*%d*%d*%d*%d = %d\n', ...
            FCTNAME,fsize/NumBytes,2*nspecC,nx,ny,ns,ni,nr,nRcvrs,2*nspecC*nx*ny*ns*ni*nr*nRcvrs);
    return
end
    
%--- reading the data from file FIDFILE ---
[fid, message] = fopen(dataSpec.fidFile, 'r', BYTEORDER);
if fid <= 0   
    SP2_Logger.log('%s -> Opening %s failed\n%s\n',FCTNAME,dataSpec.fidFile,message);
    return
end

[datFid, fcount] = fread(fid, fsize, [PRECISION '=>' PRECISION]); 
if (fcount*NumBytes < fsize)
    SP2_Logger.log('%s: only %d / %d read', FCTNAME, fcount, fsize);
    return
end

st = fclose(fid);
if st~=0
    SP2_Logger.log('%s -> Closing file %s failed\n',dataSpec.fidFile);
    return
end

datFid  = double(reshape(datFid,2,nspecC*nx*ny*ns*ni*nr*nRcvrs));
datImag = datFid(2,:);
datReal = datFid(1,:);
datFid  = complex(datReal, datImag);
if nx==1 && ny==1 && ns==1 && ni==1
    datFid  = reshape(datFid,nspecC,nRcvrs,nr);      % include singleton nRcvrs dimension for later data handling
else
    SP2_Logger.log('Inconsistent data dimensions detected. Loading aborted.\n');
    SP2_Logger.log('Hint: Check nx, ny, ni and ns\n\n');
    return
end
fprintf(loggingfile,'resorting to complex: dim nspecC/nx/ny/ns/ni/nr/nRcvrs: %d/%d/%d/%d/%d/%d/%d \n',...
        nspecC,nx,ny,ns,ni,nr,nRcvrs);
     
%----- determination of PhaseFac & datShift out of ConvDat -----
[ConvDat, f_succ] = SP2_Data_PvAvanceConvList(dataSpec);
if ~f_succ
    SP2_Logger.log('%s -> Digital-to-analog conversion failed. Program aborted.\n',FCTNAME);
    return
end
PhaseFac = mod(ConvDat,1);
datShift = ConvDat - PhaseFac;
nspecTmp = nspecC - datShift;
     
%--- data conversion ---
dataTmp = datFid(datShift+1:nspecC,:,:);
dataTmp = fftshift(fft(dataTmp)); 
FirstPhase  = 360 * PhaseFac;           % Bruker notation for phasing is used

%------- 1st order phase correction --------
if nRcvrs==1
    if FirstPhase==0
        phaseCorr = zeros(nspecTmp,1);
    else
        phaseCorr = (0:FirstPhase/(nspecTmp-1):FirstPhase)';
    end
    phaseCorr = repmat(phaseCorr,1,1,nr);
    dataTmp   = dataTmp .* exp(1i*phaseCorr*pi/180);
    datFid    = 0*datFid;
    datFid(1:nspecC-datShift,:,:) = ifft(ifftshift(dataTmp));
else
    if FirstPhase==0
        phaseCorr = zeros(nspecTmp,1);
    else
        phaseCorr = (0:FirstPhase/(nspecTmp-1):FirstPhase)';
    end
    phaseCorr = repmat(phaseCorr,1,nRcvrs,nr);
    dataTmp   = dataTmp .* exp(1i*phaseCorr*pi/180);
    datFid    = 0*datFid;
    datFid(1:nspecC-datShift,:) = ifft(ifftshift(dataTmp));
end

%--- info printout ---
SP2_Logger.log('%s finished\n',FCTNAME);

%--- update success flag ---
f_done = 1;

