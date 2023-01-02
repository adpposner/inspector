%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_succ] = SP2_Data_PvReadNewRawData(dataSpec)
%%
%%  Function to read ParaVision data.
%%
%%  use:
%%  1) regular MRS
%%  2) JDE (if editing conditions are done as NR / PVM_NRepetitions.
%%
%%  02-2004 / 02-2008 / 03-2017, Ch.Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile

FCTNAME = 'SP2_Data_PvReadNewRawData';


%--- init success flag ---
f_succ = 0;

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
   fprintf(loggingfile,'%s: unknown type <%s> for ACQ_word_size\n',FCTNAME,dataSpec.wordSize);
   return
end
if strcmp(dataSpec.byteOrder, 'big')
   BYTEORDER = 'ieee-be';     % 'ieee-be' big endian for PC
elseif strcmp(dataSpec.byteOrder, 'little')
   BYTEORDER = 'ieee-le';     % 'ieee-le' little endian for Linux
else
   fprintf(loggingfile,'%s: unknown type <%s> for BYTORDA',FCTNAME,dataSpec.byteOrder);
end

%--- check file existence ---
if 2==exist(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fsize = thedir.bytes;
else
    fprintf(loggingfile,'%s -> the file %s doesn''nt exist\n',FCTNAME, dataSpec.fidFile);
    return
end
    
%--- consistency check: expected data size vs. file size ---
if ( fsize/NumBytes == (2*nspecC)*nRcvrs*nx*ny*ns*ni*nr)
    fprintf(loggingfile,'%s\treading <%s>\n',mfilename, dataSpec.fidFile);
    fprintf(loggingfile,'nspec/nRcvrs/nx/ny/ns/ni/nr: %d/%d/%d/%d/%d/%d/%d filesize %dk\n', ...
            2*nspecC,nRcvrs,nx,ny,ns,ni,nr,fsize/1024);
else
    fprintf(loggingfile,'%s: nint %d ~= (2*nspecC)*nRcvrs*nx*ny*ni*ns*nr = %d/%d/%d/%d/%d/%d/%d = %d\n', ...
            FCTNAME,fsize/NumBytes,2*nspecC,nRcvrs,nx,ny,ns,ni,nr,2*nspecC*nRcvrs*nx*ny*ns*ni*nr);
    return
end
    
%--- reading the data from file FIDFILE ---
[fid, message] = fopen(dataSpec.fidFile, 'r', BYTEORDER);
if fid <= 0   
    fprintf(loggingfile,'%s -> Opening %s failed\n%s\n',FCTNAME,dataSpec.fidFile,message);
    return
end

[datFid, fcount] = fread(fid, fsize, [PRECISION '=>' PRECISION]); 
if (fcount*NumBytes < fsize)
    fprintf(loggingfile,'%s: only %d / %d read', FCTNAME, fcount, fsize);
    return
end

st = fclose(fid);
if st~=0
    fprintf(loggingfile,'%s -> Closing file %s failed\n',dataSpec.fidFile);
    return
end

% until 12/2021
datFid  = double(reshape(datFid,2,nspecC*nRcvrs*nx*ny*ns*ni*nr));
datImag = datFid(2,:);
datReal = datFid(1,:);
datFid  = complex(datReal, datImag);
% datFid  = squeeze(reshape(datFid,nspecC,nRcvrs,nx,ny,ns,ni,nr));
if nx==1 && ny==1 && ns==1 && ni==1
    datFid  = reshape(datFid,nspecC,nRcvrs,nr);
else
    fprintf(loggingfile,'Inconsistent data dimensions detected. Loading aborted.\n');
    fprintf(loggingfile,'Hint: Check nx, ny, ni and ns\n\n');
    return
end
fprintf(loggingfile,'resorting to complex: dim nspecC/nRcvrs/nx/ny/ns/ni/nr: %d/%d/%d/%d/%d/%d/%d \n',...
         nspecC,nRcvrs,nx,ny,ns,ni,nr);

%----- determination of PhaseFac & datShift out of ConvDat -----
[ConvDat, f_succ] = SP2_Data_PvAvanceConvList(dataSpec);
if ~f_succ
    fprintf(loggingfile,'%s -> Digital-to-analog conversion failed. Program aborted.\n',FCTNAME);
    return
end
PhaseFac = mod(abs(ConvDat),1);
datShift = abs(ConvDat) - PhaseFac;
nspecTmp = nspecC - datShift;
%datShift
     
%--- data conversion ---
dataTmp = datFid(datShift+1:nspecC,:,:);
dataTmp = fftshift(fft(dataTmp)); 
FirstPhase = 360 * sign(ConvDat)*PhaseFac;           % Bruker notation for phasing is used

%------- 1st order phase correction --------
if FirstPhase==0
    phaseCorr = zeros(nspecTmp,1);
else
    phaseCorr = (0:FirstPhase/(nspecTmp-1):FirstPhase)';
end
phaseCorr = repmat(phaseCorr,1,nRcvrs,nr);
dataTmp   = dataTmp .* exp(1i*phaseCorr*pi/180);
datFid    = 0*datFid;
datFid(1:nspecC-datShift,:,:) = ifft(ifftshift(dataTmp));

%maxAmp = max(max(max(abs(datFid))))

%--- info printout ---
fprintf(loggingfile,'%s finished\n',FCTNAME);

%--- update success flag ---
f_succ = 1;

