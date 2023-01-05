%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_PhaseCorrKloseRxCombSatRec
%% 
%%  Preprocessing of water reference for Klose correction:
%%  1) Rx-specific frequency alignment with respect to first acquisition
%%  2) Rx-specific phase alignment with respect to first acquisition
%%  Note that no relative phase alignment between Rx channels is applied 
%%  here nor are the Rx channels summed together, since the relative phases
%%  between Rx channels are required to correct the corresponding phases
%%  of the metabolite scans.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_PhaseCorrKloseRxCombSatRec';


%--- init success flag ---
f_done = 0;

%--- info printout ---
fprintf('%s started ...\n',FCTNAME);

%--- NR range selection ---
nrRg = [1 8];           % default NR range to be used for Klose correction
fprintf('Default phase cycle assumed for Klose correction: %i..%i\n',nrRg(1),nrRg(2));

%--- consistency check ---
if data.spec2.nr<nrRg(2)
    fprintf('%s ->\nNR=%i < default phase cycle %i..%i. Program aborted.\nChose ''Separate'' option instead.\n',...
            FCTNAME,data.spec2.nr,nrRg(1),nrRg(2))
    return
end

%--- determination of strongest FID ---
% note that the scan-to-scan frequency shifts are determined from this
% single-Rx signal only 
if length(size(data.spec2.fid))==3
    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
else
    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
end
[maxVal,maxInd] = max(weightVec);                       % maximum index (out of the selected ones)
refRx           = data.rcvrInd(maxInd);                 % reference Rx number (choose as stringest of the selected ones)

%--- frequency alignment: parameter init ---
frequVec = zeros(1,nrRg(2)-nrRg(1)+1);  % number of NR (i.e. phase cycle steps) to be combined for each Rx channel
anaPars.frAlignPpmMax   = 5.7;          % frequency alignment: ppm range max
anaPars.frAlignPpmMin   = 3.7;          % frequency alignment: ppm range min
anaPars.frAlignFrequRg  = 10;           % frequency alignment: potential frequency variation, +/- frequRg
anaPars.frAlignFrequRes = 0.2;          % frequency alignment: frequency resolution
anaPars.frAlignExpLb    = 2;            % frequency alignment: exponential line broadening [Hz]
anaPars.frAlignFftCut   = 2048;         % frequency alignment: apodization
anaPars.frAlignFftZf    = 8*1024;       % frequency alignment: zero-filling

%--- frequency alignment ---
for nrCnt = nrRg(1):nrRg(2)
    %--- frequency shift determination with respect to first acquisition of each Rx channel ---
    if nrCnt<nrRg(1)+5         % verbose only for the first 4 FIDs
        [frequVec(nrCnt),f_succ] = SP2_Data_AutoFrequDetIndiv(data.spec2.fid(:,refRx,nrCnt),data.spec2.fid(:,refRx,nrRg(1)),data.spec2,flag.dataAlignVerbose,anaPars);
    else
        [frequVec(nrCnt),f_succ] = SP2_Data_AutoFrequDetIndiv(data.spec2.fid(:,refRx,nrCnt),data.spec2.fid(:,refRx,nrRg(1)),data.spec2,0,anaPars);
    end
    if ~f_succ
        fprintf('%s ->\nAutomated frequency determination failed for FID #i of water reference.\n',...
                FCTNAME,nrCnt)
        return
    end

    %--- frequency correction ---
    % 1 global frequency for all receivers of the same FID
    phPerPt = frequVec(nrCnt)*data.spec2.dwell*data.spec2.nspecC*(pi/180)/(2*pi);            % corr phase per point
    for rxCnt = 1:data.rcvrN
        data.spec2.fid(:,data.rcvrInd(rxCnt),nrCnt) = exp(-1i*phPerPt*(0:data.spec2.nspecC-1)') .* ...
                                                      squeeze(data.spec2.fid(:,data.rcvrInd(rxCnt),nrCnt));
    end
end
%--- info printout ---
fprintf('Frequency alignment of water reference:\n');
fprintf('%sHz\n',SP2_Vec2PrintStr(frequVec));

%--- phase alignment: parameter init ---
flagDataAlignPhMode     = flag.dataAlignPhMode;       % keep original setting
flagDataAlignPhSpecRg   = flag.dataAlignPhSpecRg;     % keep original setting
flag.dataAlignPhMode    = 1;            % phase alignment mode, 0: maximization of spectrum integral, 1: max. of congruency with reference
flag.dataAlignPhSpecRg  = 0;            % number of spectral windows considered for phase optimization/alignment, 0: 1, 1: 2
anaPars.phAlignPpmUpMin = 3.9;          % phase alignment: up-field ppm range min
anaPars.phAlignPpmUpMax = 5.5;          % phase alignment: up-field ppm range max
anaPars.phAlignExpLb    = 10;           % phase alignment: exponential line broadening [Hz]
anaPars.phAlignPhStep   = 2;            % phase alignment: phase step size, i.e. resolution of the optimization

%--- phase alignment ---
for nrCnt = nrRg(1):nrRg(2)
    %--- frequency shift determination with respect to first acquisition of each Rx channel ---
    if nrCnt<nrRg(1)+5            % verbose only for the first 4 FIDs
        [phaseVec(nrCnt),f_succ] = SP2_Data_AutoPhaseDet(data.spec2.fid(:,refRx,nrCnt),data.spec2,flag.dataAlignVerbose,data.spec2.fid(:,refRx,nrRg(1)),anaPars);
    else
        [phaseVec(nrCnt),f_succ] = SP2_Data_AutoPhaseDet(data.spec2.fid(:,refRx,nrCnt),data.spec2,0,data.spec2.fid(:,refRx,nrRg(1)),anaPars);
    end
    if ~f_succ
        fprintf('%s ->\nAutomated phase determination failed for FID #i of water reference.\n',...
                FCTNAME,nrCnt)
        return
    end

    %--- frequency correction ---
    % 1 (global) phase for all receivers of the same FID (keeping the relative phase
    % between Rx channels unaffected)
    for rxCnt = 1:data.rcvrN
        data.spec2.fid(:,data.rcvrInd(rxCnt),nrCnt) = exp(1i*phaseVec(nrCnt)*pi/180) * ...
                                                      data.spec2.fid(:,data.rcvrInd(rxCnt),nrCnt);                                          
    end
end
%--- info printout ---
fprintf('Phase alignment of water reference:\n');
fprintf('%sdeg\n',SP2_Vec2PrintStr(phaseVec));

%--- reset original values ---
flag.dataAlignPhMode   = flagDataAlignPhMode;       % reset original setting
flag.dataAlignPhSpecRg = flagDataAlignPhSpecRg;     % reset original setting

%--- NR summation (of selected Rx channels) ---
data.spec2.kloseFid = sum(data.spec2.fid(:,data.rcvrInd,nrRg(1):nrRg(2)),3);

%--- phase determination ---
data.spec2.klosePhase = unwrap(angle(data.spec2.kloseFid));

%--- info printout ---
fprintf('%s done\n',FCTNAME);

%--- update success flag ---
f_done = 1;
