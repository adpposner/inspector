%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_AmplCorr
%%
%%  Amplitude correction (only).
%%
%%  09-2008, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi procpar flag


FCTNAME = 'SP2_MRSI_AmplCorr';


zfFac = 8;

%--- init success flag ---
f_done = 0;

%--- data handling ---
datFid = [mrsi.spec1.fid; mrsi.spec2.fid];

%--- spectral FFT ---
datSpec = abs(fftshift(fft(datFid,zfFac*mrsi.nspecC,2),2));

%--- frequency/amplitude determination ---
nSpec = size(datSpec,1);            % number of spectra
[maxVec,indVec] = max(datSpec,[],2);

%--- amplitude correction ---
for sCnt = 1:nSpec
    datFid(sCnt,:) = datFid(sCnt,:) * maxVec(1)/maxVec(sCnt); 
end

%--- data reformating ---
mrsi.spec1.fid = datFid(1:nSpec/2,:);
mrsi.spec2.fid = datFid(nSpec/2+1:end,:);

%--- info printout ---
fprintf('Amplitude ratio: %s%%\n',SP2_Vec2PrintStr(100*maxVec'/maxVec(1)));
fprintf('Appl. scaling: %s\n',SP2_Vec2PrintStr(maxVec(1)./maxVec',3));

%--- update success flag ---
f_done = 1;

end
