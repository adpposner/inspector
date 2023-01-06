%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_done] = SP2_Data_PvReadOldFidJDE(dataSpec)
%%
%%  Function to read all kind of unregular data formats (e.g. reduced data
%%  formats after XWINNMR 'convdta' or for circular k-space sampling) from
%%  file.
%%
%%  02-2004 / 02-2008, Ch.Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_PvReadOldFidJDE';


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
njde   = dataSpec.njde;

%--- data format handling ---
if strcmp(dataSpec.wordSize,'_16_BIT')
   NumBytes  = 2;              % 16 bit 
   PRECISION = 'int16';
elseif strcmp(dataSpec.wordSize,'_32_BIT')
   NumBytes  = 4;              % 32 bit 
   PRECISION = 'int32';
else
   fprintf('%s: unknown type <%s> for ACQ_word_size\n',FCTNAME,dataSpec.wordSize);
   return
end
if strcmp(dataSpec.byteOrder,'big')
   BYTEORDER = 'ieee-be';     % 'ieee-be' big endian for PC
elseif strcmp(dataSpec.byteOrder,'little')
   BYTEORDER = 'ieee-le';     % 'ieee-le' little endian for Linux
else
   fprintf('%s: unknown type <%s> for BYTORDA',FCTNAME,dataSpec.byteOrder);
end

%--- check file existence ---
if 2==exist(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fsize = thedir.bytes;
else
    fprintf('%s -> the file %s doesn''nt exist\n',FCTNAME, dataSpec.fidFile);
    return
end
    
%--- consistency check: expected data size vs. file size ---
if ( fsize/NumBytes == (2*nspecC)*nx*ny*ns*ni*nr*jde)
    fprintf('reading <%s>\n', dataSpec.fidFile);
    fprintf('nspec/nx/ny/ns/ni/nr/njde: %d/%d/%d/%d/%d/%d/%d filesize %dk\n', ...
            2*nspecC,nx,ny,ns,ni,nr,njde,fsize/1024);
else
    fprintf('%s: nint %d ~= nspec*nx*ny*ni*ns*nr*njde = %d*%d*%d*%d*%d*%d*%d = %d\n', ...
            FCTNAME,fsize/NumBytes,2*nspecC,nx,ny,ns,ni,nr,njde,2*nspecC*nx*ny*ns*ni*nr*njde);
    return
end
    
%--- reading the data from file FIDFILE ---
[fid, message] = fopen(dataSpec.fidFile, 'r', BYTEORDER);
if fid <= 0   
    fprintf('%s -> Opening %s failed\n%s\n',FCTNAME,dataSpec.fidFile,message);
    return
end

[datFid, fcount] = fread(fid, fsize, [PRECISION '=>' PRECISION]); 
if (fcount*NumBytes < fsize)
    fprintf('%s: only %d / %d read', FCTNAME, fcount, fsize);
    return
end

st = fclose(fid);
if st~=0
    fprintf('%s -> Closing file %s failed\n',dataSpec.fidFile);
    return
end

datFid  = double(reshape(datFid,2,nspecC*nx*ny*ns*ni*nr*jde));
datImag = datFid(2,:);
datReal = datFid(1,:);
datFid  = complex(datReal, datImag);
if nx==1 && ny==1 && ns==1 && ni==1
    datFid  = reshape(datFid,nspecC,nr,jde);
else
    fprintf('Inconsistent data dimensions detected. Loading aborted.\n');
    fprintf('Hint: Check nx, ny, ni and ns\n\n');
    return
end
fprintf('resorting to complex: dim nspecC/nx/ny/ns/ni/nr/njde: %d/%d/%d/%d/%d/%d/%d \n',...
         nspecC,nx,ny,ns,ni,nr,njde);
     
%----- determination of PhaseFac & datShift out of ConvDat -----
[ConvDat, f_succ] = SP2_Data_PvAvanceConvList(dataSpec);
if ~f_succ
    fprintf('%s -> Digital-to-analog conversion failed. Program aborted.\n',FCTNAME);
    return
end
PhaseFac = mod(ConvDat,1);
datShift = ConvDat - PhaseFac;
nspecTmp = nspecC - datShift;
     
%--- data conversion ---
dataTmp = datFid(datShift+1:nspecC,1);
dataTmp = fftshift(fft(dataTmp)); 
FirstPhase  = 360 * PhaseFac;           % Bruker notation for phasing is used

%------- 1st order phase correction --------
if FirstPhase==0
    phaseCorr = zeros(1,nspecTmp);
else
    phaseCorr = (0:FirstPhase/(nspecTmp-1):FirstPhase);
end
datConvdta = dataTmp .* exp(1i*phaseCorr*pi/180).';
datFid     = 0*datFid;
datFid(1:nspecC-datShift,1) = ifft(ifftshift(datConvdta));
     
%--- info printout ---
fprintf('%s finished\n',FCTNAME);

%--- update success flag ---
f_done = 1;


end
