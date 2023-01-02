%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_FreqCorr
%%
%%  Frequency correction (only).
%%
%%  09-2008, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc


FCTNAME = 'SP2_Proc_FreqCorr';


zfFac = 16;          % zero-filling factor


%--- init success flag ---
f_done = 0;

%--- data handling ---
datFid = [proc.spec1.fid; proc.spec2.fid];

%--- spectral FFT ---
datSpec = abs(fftshift(fft(datFid,zfFac*proc.nspecC,2),2));

%--- frequency/amplitude determination ---
nSpec = size(datSpec,1);            % number of spectra
[maxVec,indVec] = max(datSpec');

%--- frequency correction ---
phVec     = [0:proc.nspecC-1];                               % basic phase vector
corrHzVec = (indVec-indVec(1))*proc.sw_h/(zfFac*proc.nspecC); % relative frequency correction
for sCnt = 2:nSpec
    phPerPt        = corrHzVec(sCnt)*proc.dwell*proc.nspecC*(pi/180)/(2*pi);  % corr phase per point
    datFid(sCnt,:) = datFid(sCnt,:) .* exp(-1i*phPerPt*phVec);               % apply phase correction
end

%--- data reformating ---
proc.spec1.fid = datFid(1:nSpec/2,:);
proc.spec2.fid = datFid(nSpec/2+1:end,:);

%--- update success flag ---
f_done = 1;
