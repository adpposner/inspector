%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_T1T2_DataReco
%%
%%  Load parameters and data of saturation-recovery experiment from 'Data'
%%  page.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2

FCTNAME = 'SP2_T1T2_DataReco';


%--- init read flag ---
f_succ = 0;

%--- spectra reconstruction ---
t1t2.spec = complex(zeros(t1t2.zf,t1t2.delaysN));
for srCnt = 1:t1t2.delaysN
    if t1t2.nspecC<t1t2.cut        % no apodization
        lbWeight = exp(-t1t2.lb*t1t2.dwell*(0:t1t2.nspecC-1)*pi)';
        t1t2.spec(:,srCnt) = fftshift(fft(t1t2.fid(:,srCnt).*lbWeight,t1t2.zf));
    else                                    % apodization
        lbWeight = exp(-t1t2.lb*t1t2.dwell*(0:t1t2.cut-1)*pi)';
        t1t2.spec(:,srCnt) = fftshift(fft(t1t2.fid(1:t1t2.cut,srCnt).*lbWeight,t1t2.zf));
        if srCnt==1
            fprintf('%s ->\nApodization of FID to %.0f points applied.\n',...
                    FCTNAME,t1t2.cut)
        end
    end
    t1t2.spec(:,srCnt) = t1t2.spec(:,srCnt) .* exp(1i*t1t2.phaseZero*pi/180)';
end
t1t2.nspecC = size(t1t2.spec,1);        % update

%--- info printout ---
fprintf('Spectral analysis completed.\n');


% %--- data export ---
% t1t2.expt     = t1t2;
% if isfield(t1t2.expt,'spec')
%     t1t2.expt = rmfield(t1t2.expt,'spec');
% end
% t1t2.expt.fid = t1t2.fidOrig;

%--- update read flag ---
f_succ = 1;

end
