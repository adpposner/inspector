%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DataCorr( f_show )
%%
%%  Phase and frequency correction of saturation-recovery series.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_DataCorr';

%--- init read flag ---
f_succ = 0;

%--- parameter init ---
if flag.mmMetabRef      % metabolites
    %--- frequency correction ---
    flag.mmAlignFrequ   = 1;            % frequency alignment of individual spectra
    mm.frAlignPpmMin    = 0.5;          % frequency alignment: ppm range min
    mm.frAlignPpmMax    = 4.1;          % frequency alignment: ppm range max
    mm.frAlignFrequRg   = 15;           % frequency alignment: potential frequency variation, +/- frequRg
    mm.frAlignFrequRes  = 0.1;          % frequency alignment: frequency resolution
    mm.frAlignExpLb     = 5;            % frequency alignment: exponential line broadening [Hz]
    mm.frAlignFftCut    = 1024;         % frequency alignment: apodization
    mm.frAlignFftZf     = 8*1024;       % frequency alignment: zero-filling
    mm.frAlignRefFid    = 1;            % frequency alignment: reference FID (number)
    mm.frAlignIter      = 2;            % # of iterations, note that >1 iterations use the sum of all spectra

    %--- phase correction ---
    flag.mmAlignPhase   = 1;            % phase alignment of individual spectra
    flag.mmAlignPhMode  = 1;            % phase alignment mode, 0: maximization of spectrum integral, 1: max. of congruency with reference
    flag.mmAlignPhSpecRg = 1;           % number of spectral windows considered for phase optimization/alignment, 0: 1, 1: 2
    mm.phAlignPpmDnMin  = 7.65;         % phase alignment: down-field ppm range min      
    mm.phAlignPpmDnMax  = 8;            % phase alignment: down-field ppm range max
    mm.phAlignPpmUpMin  = 0.5;          % phase alignment: up-field ppm range min
    mm.phAlignPpmUpMax  = 4.1;          % phase alignment: up-field ppm range max
    mm.phAlignExpLb     = 10;            % phase alignment: exponential line broadening [Hz]
    mm.phAlignPhStep    = 2;            % phase alignment: phase step size, i.e. resolution of the optimization
    mm.phAlignRefFid    = 1;            % phase alignment: reference FID (number)
    mm.phAlignIter      = 2;            % phase alignment: iterations, >1 via sum of all spectra
else                % water
    %--- frequency correction ---
    flag.mmAlignFrequ   = 1;            % frequency alignment of individual spectra
    mm.frAlignPpmMax    = 5.5;          % frequency alignment: ppm range max
    mm.frAlignPpmMin    = 4;            % frequency alignment: ppm range min
    mm.frAlignFrequRg   = 15;           % frequency alignment: potential frequency variation, +/- frequRg
    mm.frAlignFrequRes  = 0.1;          % frequency alignment: frequency resolution
    mm.frAlignExpLb     = 2;            % frequency alignment: exponential line broadening [Hz]
    mm.frAlignFftCut    = 1024;         % frequency alignment: apodization
    mm.frAlignFftZf     = 8*1024;       % frequency alignment: zero-filling
    mm.frAlignRefFid    = 1;            % frequency alignment: reference FID (number)
    mm.frAlignIter      = 1;            % # of iterations, note that >1 iterations use the sum of all spectra

    %--- phase correction ---
    flag.mmAlignPhase   = 0;            % phase alignment of individual spectra
    flag.mmAlignPhMode  = 1;            % phase alignment mode, 0: maximization of spectrum integral, 1: max. of congruency with reference
    flag.mmAlignPhSpecRg = 0;           % number of spectral windows considered for phase optimization/alignment, 0: 1, 1: 2
    mm.phAlignPpmDnMin  = 7.65;         % phase alignment: down-field ppm range min      
    mm.phAlignPpmDnMax  = 7.95;         % phase alignment: down-field ppm range max
    mm.phAlignPpmUpMin  = 4;            % phase alignment: up-field ppm range min
    mm.phAlignPpmUpMax  = 5.5;            % phase alignment: up-field ppm range max
    mm.phAlignExpLb     = 2;            % phase alignment: exponential line broadening [Hz]
    mm.phAlignPhStep    = 2;            % phase alignment: phase step size, i.e. resolution of the optimization
    mm.phAlignRefFid    = 1;            % phase alignment: reference FID (number)
    mm.phAlignIter      = 1;            % phase alignment: iterations, >1 via sum of all spectra
end

%--- 1) frequency determination and alignment ---
if flag.mmAlignFrequ
    %--- pars init ---
    frequCorr = zeros(1,mm.satRecN);        % optimal phasings

    %--- parameter preparation ---
    mm.opt.frequVec = -mm.frAlignFrequRg:mm.frAlignFrequRes:mm.frAlignFrequRg;       % test frequency shift
    mm.opt.nFrequ   = length(mm.opt.frequVec);                      % number of test frequency shifts
    % intDiff         = zeros(1,mm.opt.nFrequ);                     % integral difference measures
    phPerPtVec      = mm.opt.frequVec*mm.dwell*mm.nspecC*(pi/180)/(2*pi);       % correction phase per point: vector
    phPerPtMat      = repmat(phPerPtVec,[mm.nspecC 1]);             % correction phase per point: matrix
    pointMat        = repmat((0:(mm.nspecC-1))',[1 mm.opt.nFrequ]);
    mm.opt.frequShiftMat = exp(-1i*phPerPtMat .* pointMat);         % time domain frequency shift matrix

    %--- serial analysis ---
    for srCnt = 2:mm.satRecN
        %--- extract reference FID ---
        mm.frAlignRefFid = mm.satRecN-srCnt+2;          % go backwards
        refFid = squeeze(mm.fid(:,mm.frAlignRefFid));
        
        %--- shift determination ---
        [frequCorr(mm.satRecN-srCnt+1),f_succ] = SP2_MM_AutoFrequDet(mm.fid(:,mm.satRecN-srCnt+1),refFid,f_show,mm.satRecN-srCnt+1);
        if ~f_succ
            fprintf('%s ->\nAutomated frequency determination failed for delay #i (%.3fs).\n',...
                    FCTNAME,srCnt,mm.satRecDelays(srCnt))
            return
        end

        %--- frequency correction ---
        % 1 frequency for all receivers of the same FID
        phPerPt = frequCorr(mm.satRecN-srCnt+1)*mm.dwell*mm.nspecC*(pi/180)/(2*pi);    % corr phase per point
        mm.fid(:,mm.satRecN-srCnt+1) = exp(-1i*phPerPt*(0:mm.nspecC-1)') .* ...
                                       squeeze(mm.fid(:,mm.satRecN-srCnt+1));    
    end
    %--- info printout ---
    fprintf('Successive frequency correction:\n%sHz\n',SP2_Vec2PrintStr(frequCorr))
end

%--- 2) phase determination and alignment ---
if flag.mmAlignPhase
    %--- pars init ---
    phaseCorr = zeros(1,mm.satRecN);        % optimal phasings

    %--- serial analysis ---
    for srCnt = 1:mm.satRecN
        %--- extract reference FID ---
        if flag.mmMetabRef           % metabolites
            if srCnt==1
                mm.phAlignRefFid     = mm.satRecN;      % start at last
                flag.mmAlignPhMode   = 0;               % integral
                flag.mmAlignPhSpecRg = 1;               % 2 windows
                mm.phAlignPpmUpMin   = 1.97;            % phase alignment: up-field ppm range min
                mm.phAlignPpmUpMax   = 2.1;             % phase alignment: up-field ppm range max
            else
                mm.phAlignRefFid     = mm.satRecN-srCnt+2;   % go backwards
                flag.mmAlignPhMode   = 1;               % congruenc
                flag.mmAlignPhSpecRg = 1;               % 2 windows
                mm.phAlignPpmUpMin   = 0.5;             % phase alignment: up-field ppm range min
                mm.phAlignPpmUpMax   = 4.1;             % phase alignment: up-field ppm range max
            end
        else                        % water
            if srCnt==1
                mm.phAlignRefFid     = mm.satRecN;      % start at last
                flag.mmAlignPhMode   = 0;               % integral
                flag.mmAlignPhSpecRg = 0;               % 1 window
                mm.phAlignPpmUpMin   = 4;               % phase alignment: up-field ppm range min
                mm.phAlignPpmUpMax   = 5.5;             % phase alignment: up-field ppm range max
            else
                mm.phAlignRefFid     = mm.satRecN-srCnt+2;   % go backwards
                flag.mmAlignPhMode   = 1;               % congruenc
                flag.mmAlignPhSpecRg = 0;               % 1 window
                mm.phAlignPpmUpMin   = 4;               % phase alignment: up-field ppm range min
                mm.phAlignPpmUpMax   = 5.5;             % phase alignment: up-field ppm range max
            end
        end
        refFid = squeeze(mm.fid(:,mm.phAlignRefFid));

        %--- phase determination ---
        if flag.mmAlignPhMode               % congruency
            [phaseCorr(mm.satRecN-srCnt+1),f_succ] = SP2_MM_AutoPhaseDet(mm.fid(:,mm.satRecN-srCnt+1),f_show,mm.satRecN-srCnt+1,refFid);
        else                                % integral
            [phaseCorr(mm.satRecN-srCnt+1),f_succ] = SP2_MM_AutoPhaseDet(mm.fid(:,mm.satRecN-srCnt+1),f_show,mm.satRecN-srCnt+1);
        end
        if ~f_succ
            fprintf('%s ->\nAutomated phase determination failed for delay #i (%.3fs).\n',...
                    FCTNAME,srCnt,mm.satRecDelays(srCnt))
            return
        end

        %--- apply (relative) phase alignment ---
        if srCnt==1
            phaseCorr(mm.satRecN-srCnt+1) = -60;
        end
        mm.fid(:,mm.satRecN-srCnt+1) = exp(1i*phaseCorr(mm.satRecN-srCnt+1)*pi/180) * mm.fid(:,mm.satRecN-srCnt+1);
    end
    %--- info printout ---
    fprintf('Successive phase correction:\n%sdeg\n',SP2_Vec2PrintStr(phaseCorr))
end

%--- info printout ---
fprintf('Frequency and phase alignment completed.\n')

% %--- data export ---
% mm.expt = mm;
% if isfield(mm.expt,'spec')
%     mm.expt = rmfield(mm.expt,'spec');
% end
% mm.expt.fid = mm.fidOrig;

%--- update read flag ---
f_succ = 1;
