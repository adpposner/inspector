%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_FreqCorr
%%
%%  Frequency correction (only).
%%
%%  09-2008, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi


FCTNAME = 'SP2_MRSI_FreqCorr';


zfFac = 16;          % zero-filling factor


%--- init success flag ---
f_done = 0;

%--- data handling ---
datFid = [mrsi.spec1.fid; mrsi.spec2.fid];

%--- spectral FFT ---
datSpec = abs(fftshift(fft(datFid,zfFac*mrsi.nspecC,2),2));

%--- frequency/amplitude determination ---
nSpec = size(datSpec,1);            % number of spectra
[maxVec,indVec] = max(datSpec');

%--- frequency correction ---
phVec     = [0:mrsi.nspecC-1];                               % basic phase vector
corrHzVec = (indVec-indVec(1))*mrsi.sw_h/(zfFac*mrsi.nspecC); % relative frequency correction
for sCnt = 2:nSpec
    phPerPt        = corrHzVec(sCnt)*mrsi.dwell*mrsi.nspecC*(pi/180)/(2*pi);  % corr phase per point
    datFid(sCnt,:) = datFid(sCnt,:) .* exp(-1i*phPerPt*phVec);               % apply phase correction
end

%--- data reformating ---
mrsi.spec1.fid = datFid(1:nSpec/2,:);
mrsi.spec2.fid = datFid(nSpec/2+1:end,:);

%--- update success flag ---
f_done = 1;
