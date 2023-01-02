%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ECCorr
%%
%%  Eddy current correction.
%%
%%  09-2008, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi procpar flag


FCTNAME = 'SP2_MRSI_ECCorr';


%--- init success flag ---
f_done = 0;

%--- extract 1st water spectrum ---
datWater  = mrsi.spec1.fid(1,:) + mrsi.spec2.fid(1,:);
phaseCorr = unwrap(angle(datWater));

%--- phase filtering ---
if 0
    %--- filter generation ---
    nyq   = 1/(2*mrsi.dwell);       % Compute the nyquist frequency
    lpc   = 10;                     % cutoff frequ. [Hz]
    lWn   = lpc/nyq;		   	    % between 0.0 and 1.0
    [b,a] = butter(2,lWn,'low');	% butterworth lowpass
    %--- apply filter ---
    nSpec = size(datFid,1);         % total number of FIDs
    for sCnt = 1:nSpec
        phaseCorr(sCnt,:) = filtfilt(b,a,phaseCorr(sCnt,:));
    end
end

%--- ECC ---
phaseMat = repmat(exp(-1i*phaseCorr),[mrsi.nr 1]);
mrsi.spec1.fid = mrsi.spec1.fid .* phaseMat;
mrsi.spec2.fid = mrsi.spec2.fid .* phaseMat;

%--- update success flag ---
f_done = 1;
