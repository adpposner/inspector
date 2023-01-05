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

%--- iterative frequency and phase alignment ---
for iterCnt = 1:max(mm.phAlignIter,mm.frAlignIter)
    %--- 1) frequency determination and alignment ---
    if flag.mmAlignFrequ && iterCnt<=mm.frAlignIter
        %--- pars init ---
        frequCorr = zeros(1,mm.satRecN);        % optimal correction frequencies

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
            mm.frAlignRefFid = mm.satRecN-srCnt+2;              % go backwards
            refFid = squeeze(mm.fid(:,mm.frAlignRefFid));

            %--- shift determination ---
            [frequCorr(mm.satRecN-srCnt+1),f_succ] = SP2_MM_AutoFrequDet(mm.fid(:,mm.satRecN-srCnt+1),refFid,f_show,mm.satRecN-srCnt+1);
            if ~f_succ
                fprintf('%s ->\nAutomated frequency determination failed for delay #i (%.3fs).\n',...
                        FCTNAME,srCnt,mm.satRecDelays(srCnt))
                return
            end

            %--- figure creation ---
            if srCnt==mm.satRecN
                frequCorr(mm.satRecN-srCnt+1) = frequCorr(mm.satRecN-srCnt+1) + 5;
            end
            
            %--- frequency correction ---
            % 1 frequency for all receivers of the same FID
            phPerPt = frequCorr(mm.satRecN-srCnt+1)*mm.dwell*mm.nspecC*(pi/180)/(2*pi);    % corr phase per point
            mm.fid(:,mm.satRecN-srCnt+1) = exp(-1i*phPerPt*(0:mm.nspecC-1)') .* ...
                                           squeeze(mm.fid(:,mm.satRecN-srCnt+1));    
        end
        %--- info printout ---
        fprintf('Successive frequency correction:\n%sHz\n',SP2_Vec2PrintStr(frequCorr));
    end

    %--- 2) phase determination and alignment ---
    if flag.mmAlignPhase && iterCnt<=mm.phAlignIter
        %--- pars init ---
        phaseCorr = zeros(1,mm.satRecN);        % optimal phasings

        %--- serial analysis ---
        for srCnt = 2:mm.satRecN
            %--- extract reference FID ---
            mm.phAlignRefFid = mm.satRecN-srCnt+2;              % go backwards
            refFid = squeeze(mm.fid(:,mm.phAlignRefFid));

            %--- phase determination ---
            [phaseCorr(mm.satRecN-srCnt+1),f_succ] = SP2_MM_AutoPhaseDet(mm.fid(:,mm.satRecN-srCnt+1),f_show,mm.satRecN-srCnt+1,refFid);
            if ~f_succ
                fprintf('%s ->\nAutomated phase determination failed for delay #i (%.3fs).\n',...
                        FCTNAME,srCnt,mm.satRecDelays(srCnt))
                return
            end

            %--- phase tuning curve ---
%             phaseCorr(mm.satRecN-srCnt+1) = phaseCorr(mm.satRecN-srCnt+1) - (mm.satRecN-srCnt+1)*0.3;
%             if srCnt==mm.satRecN
%                 phaseCorr(mm.satRecN-srCnt+1) = phaseCorr(mm.satRecN-srCnt+1) - 10;
%             end
            % order: short to long SR delays
            phaseVec = [-8 -3 -2 -2 -1.5 -1.2 -1 -0.7 -0.5 -0.5 -2 -1 0 0 0 0];
            phaseCorr(mm.satRecN-srCnt+1) = phaseCorr(mm.satRecN-srCnt+1) + phaseVec(mm.satRecN-srCnt+1);

            %--- apply (relative) phase alignment ---
%             if srCnt==1
%                 phaseCorr(mm.satRecN-srCnt+1) = -60;
%             end
            mm.fid(:,mm.satRecN-srCnt+1) = exp(1i*phaseCorr(mm.satRecN-srCnt+1)*pi/180) * mm.fid(:,mm.satRecN-srCnt+1);
        end
        %--- info printout ---
        fprintf('Successive phase correction:\n%sdeg\n',SP2_Vec2PrintStr(phaseCorr));
    end
end

%--- info printout ---
fprintf('Frequency and phase alignment completed.\n');


%--- AMPLITUDE CORRECTION ---
% maybe




% %--- data export ---
% mm.expt = mm;
% if isfield(mm.expt,'spec')
%     mm.expt = rmfield(mm.expt,'spec');
% end
% mm.expt.fid = mm.fidOrig;

%--- update read flag ---
f_succ = 1;
