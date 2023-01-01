%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DataReco
%%
%%  Load parameters and data of saturation-recovery experiment from 'Data'
%%  page.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm

FCTNAME = 'SP2_MM_DataReco';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if ~isfield(mm,'fid')
    if ~SP2_MM_DataLoad
        return
    end
    if ~SP2_MM_DataResort
        return
    end
    if ~SP2_MM_DataCorr
        return
    end
end

% %--- reset sat-recovery data points (real or copies) ---
% mm.satRecN = size(mm.fid,2);

%--- spectra reconstruction ---
mm.spec = complex(zeros(mm.zf,mm.satRecN));
for srCnt = 1:mm.satRecN
    if mm.nspecC<mm.cut        % no apodization
        lbWeight = exp(-mm.lb*mm.dwell*(0:mm.nspecC-1)*pi)';
        mm.spec(:,srCnt) = fftshift(fft(mm.fid(:,srCnt).*lbWeight,mm.zf));
    else                                    % apodization
        lbWeight = exp(-mm.lb*mm.dwell*(0:mm.cut-1)*pi)';
        mm.spec(:,srCnt) = fftshift(fft(mm.fid(1:mm.cut,srCnt).*lbWeight,mm.zf));
        if srCnt==1
            fprintf('%s ->\nApodization of FID to %.0f points applied.\n',...
                    FCTNAME,mm.cut)
        end
    end
    mm.spec(:,srCnt) = mm.spec(:,srCnt) .* exp(1i*mm.phaseZero*pi/180)';
    
%     %--- box car smoothing ---
%     if mm.boxCar>1
%         %--- info printout ---
%         if srCnt==1
%             fprintf('Box car windowing applied.\n')
%         end
%         
%         %--- apply box car averaging ---
%         mmSpecTmp = mm.spec(:,srCnt);
%         for iCnt = 1:size(mm.spec,1)
%             mmSpecTmp(iCnt) = mean(mm.spec(max(iCnt-round(mm.boxCar/2),1): ...
%                                            min(iCnt+round(mm.boxCar/2),size(mm.spec,1)),srCnt));
%         end
%         mm.spec(:,srCnt) = mmSpecTmp;
%     end
end
mm.nspecC = size(mm.spec,1);        % update

%--- delay extension ---
mm.satRecDelaysZero = [mm.satRecDelays 0];
mm.satRecZeroN      = length(mm.satRecDelaysZero);

%--- info printout ---
fprintf('Spectral analysis completed.\n')

%--- data extension ---
if mm.dataExtFac>1
    mm.satRecN      = mm.dataExtFac * mm.satRecN;
    mm.satRecDelays = repmat(mm.satRecDelays,[1 mm.dataExtFac]);
    mm.spec         = repmat(mm.spec,[1 mm.dataExtFac]);
    fprintf('%s -> %i-times data extension applied.\n',FCTNAME,mm.dataExtFac)
end

% %--- data export ---
% mm.expt     = mm;
% if isfield(mm.expt,'spec')
%     mm.expt = rmfield(mm.expt,'spec');
% end
% mm.expt.fid = mm.fidOrig;

%--- update read flag ---
f_succ = 1;
