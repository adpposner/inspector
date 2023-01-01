%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_done] = SP2_Data_PvReadRawData(dataSpec)
%%
%%  Function to read all kind of unregular data formats (e.g. reduced data
%%  formats after XWINNMR 'convdta' or for circular k-space sampling) from
%%  file.
%%
%%  02-2004 / 02-2008, Ch.Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_PvReadRawData';


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
   fprintf('%s: unknown type <%s> for ACQ_word_size\n',FCTNAME,dataSpec.wordSize)
   return
end
if strcmp(dataSpec.byteOrder, 'big')
   BYTEORDER = 'ieee-be';     % 'ieee-be' big endian for PC
elseif strcmp(dataSpec.byteOrder, 'little')
   BYTEORDER = 'ieee-le';     % 'ieee-le' little endian for Linux
else
   fprintf('%s: unknown type <%s> for BYTORDA',FCTNAME,dataSpec.byteOrder)
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
if ( fsize/NumBytes == (2*nspecC)*nRcvrs*nx*ny*ns*ni*nr)
    fprintf('reading <%s>\n', dataSpec.fidFile);
    fprintf('nspec/nRcvrs/nx/ny/ns/ni/nr: %d/%d/%d/%d/%d/%d/%d filesize %dk\n', ...
            2*nspecC,nRcvrs,nx,ny,ns,ni,nr,fsize/1024);
else
    fprintf('%s: nint %d ~= nspecC*nRcvrs*nx*ny*ni*ns*nr = %d*%d*%d*%d*%d*%d*%d = %d\n', ...
            FCTNAME,fsize/NumBytes,2*nspecC,nRcvrs,nx,ny,ns,ni,nr,2*nspecC*nRcvrs*nx*ny*ns*ni*nr);
    return
end
    
%--- reading the data from file FIDFILE ---
[fid, message] = fopen(dataSpec.fidFile, 'r', BYTEORDER);
if fid <= 0   
    fprintf('%s -> Opening %s failed\n%s',FCTNAME,dataSpec.fidFile,message)
    return
end

[datFid, fcount] = fread(fid, fsize, [PRECISION '=>' PRECISION]); 
if (fcount*NumBytes < fsize)
    fprintf('%s: only %d / %d read', FCTNAME, fcount, fsize)
    return
end

st = fclose(fid);
if st~=0
    fprintf('%s ->\nClosing file %s failed\n',dataSpec.fidFile)
    return
end

datFid  = double(reshape(datFid,2,nspecC*nRcvrs*nx*ny*ns*ni*nr));
datImag = datFid(2,:);
datReal = datFid(1,:);
datFid  = complex(datReal, datImag);
datFid  = squeeze(reshape(datFid,nspecC,nRcvrs,nx,ny,ns,ni,nr));
fprintf('resorting to complex: dim nspecC/nRcvrs/nx/ny/ns/ni/nr: %d/%d/%d/%d/%d/%d/%d \n',...
         nspecC,nRcvrs,nx,ny,ns,ni,nr);

%----- determination of PhaseFac & datShift out of ConvDat -----
ConvDat  = SP2_Loc_AvanceConvList(dataSpec);
PhaseFac = mod(ConvDat,1);
datShift = ConvDat - PhaseFac;
nspecTmp = nspecC - datShift;
     
%--- data conversion ---
dataTmp = datFid(datShift+1:nspecC,:,:);
dataTmp = fftshift(fft(dataTmp)); 
FirstPhase  = 360 * PhaseFac;           % Bruker notation for phasing is used

%------- 1st order phase correction --------
if FirstPhase==0
    phaseCorr = zeros(nspecTmp,1);
else
    phaseCorr = (0:FirstPhase/(nspecTmp-1):FirstPhase)';
end
phaseCorr = repmat(phaseCorr,1,nRcvrs,nr);
dataTmp = dataTmp .* exp(1i*phaseCorr*pi/180);
datFid  = 0*datFid;
datFid(1:nspecC-datShift,:,:) = ifft(ifftshift(dataTmp));
     
%--- info printout ---
fprintf('%s finished\n',FCTNAME);

%--- update success flag ---
f_done = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    L O C A L    F U N C T I O N S                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ConvDat = SP2_Loc_AvanceConvList(dataSpec)

%% function that uses DECIM and DSPFVS (acqus file, part of global acqp parameter)
%% to give back the corresponding value for data rotation and 1st order phasing
%% -> technical report of Westler & Abildgaard, 1996
%% http://garbanzo.scripps.edu/nmrgrp/wisdom/dig.nmrfam.txt
%% http://www.acdlabs.com/publish/offlproc.html
%% http://sbtools.uchc.edu/help/nmr/nmr_toolkit/bruker_dsp_table.asp        (partial list, 01/2017)
%%
%% 10-2002, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Dspfvs10Vec = [44.75 33.5 66.625 59.0833 68.5625 60.375 69.5313 61.0208 70.0156 61.3438 70.2578 61.5052 70.3789...
               61.5859 70.4395 61.6263 70.4697 61.6465 70.4849 61.6566 70.4924 0];
Dspfvs11Vec = [46 36.5 48 50.1667 53.25 69.5 72.25 70.1667 72.75 70.5 73 70.6667 72.5 71.3333 72.25 71.6667 72.125 71.8333 72.0625 71.9167 72.0313 0];
Dspfvs12Vec = [46.311 36.53 47.87 50.229 53.289 69.551 71.6 70.184 72.138 70.528 72.348 70.7 72.524 0 0 0 0 0 0 0 0 0];
Dspfvs20Vec = [zeros(1,21) 69.01];            % GFM data: DECIM=4000, DSPFVS=20

% DatMat = [Dspfvs10Vec(1,:)',Dspfvs12Vec(1,:)',Dspfvs12Vec(1,:)'];
DatMat = [Dspfvs10Vec(1,:)',Dspfvs11Vec(1,:)',Dspfvs12Vec(1,:)',Dspfvs20Vec(1,:)'];

%--- decimal factor of the digital filter ---
switch dataSpec.decim
    case 2, DecimInd=1;
    case 3, DecimInd=2;
    case 4, DecimInd=3;
    case 6, DecimInd=4;
    case 8, DecimInd=5;
    case 12, DecimInd=6;
    case 16, DecimInd=7;
    case 24, DecimInd=8;
    case 32, DecimInd=9;
    case 48, DecimInd=10;
    case 64, DecimInd=11;
    case 96, DecimInd=12;
    case 128, DecimInd=13;
    case 192, DecimInd=14;
    case 256, DecimInd=15;
    case 384, DecimInd=16;
    case 512, DecimInd=17;
    case 768, DecimInd=18;
    case 1024, DecimInd=19;
    case 1536, DecimInd=20;
    case 2048, DecimInd=21;
    case 4000, DecimInd=22;             % GFM data
    otherwise, fprintf('DECIM does not have a legal value\n'); return
end

%--- DSP firmware version ---
switch dataSpec.dspfvs
    case 10, DspfvsInd=1;
    case 11, DspfvsInd=2;
    case 12, DspfvsInd=3;
    case 20, DspfvsInd=4;               % GFM data
    otherwise, fprintf('Dspfvs does not have a legal value\n'); return
end

% if DspfvsInd==3 && DecimInd>13
%     fprintf('combination of DECIM and DSPFVS is not possible\n');
%     return
% end

ConvDat = DatMat(DecimInd,DspfvsInd);







