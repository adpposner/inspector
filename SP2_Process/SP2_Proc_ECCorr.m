%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_ECCorr
%%
%%  Eddy current correction.
%%
%%  09-2008, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc procpar flag


FCTNAME = 'SP2_Proc_ECCorr';


%--- init success flag ---
f_done = 0;

%--- extract 1st water spectrum ---
datWater  = proc.spec1.fid(1,:) + proc.spec2.fid(1,:);
phaseCorr = unwrap(angle(datWater));

%--- phase filtering ---
if 0
    %--- filter generation ---
    nyq   = 1/(2*proc.dwell);       % Compute the nyquist frequency
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
phaseMat = repmat(exp(-1i*phaseCorr),[proc.nr 1]);
proc.spec1.fid = proc.spec1.fid .* phaseMat;
proc.spec2.fid = proc.spec2.fid .* phaseMat;

%--- update success flag ---
f_done = 1;
