%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ProcessFid2
%%
%%  Spectral processing of FID 2
%%
%%  05-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

    
FCTNAME = 'SP2_MRSI_DoProcessFid2';

%--- init success flag ---
f_done = 0;

%--- consistency checks ---
if mrsi.selectLR>size(mrsi.spec2.fidimg_orig,2)
    fprintf('Spectrum selection L/R reduced to stay within\navailable matrix size (%.0f -> %.0f)\n',...
            mrsi.selectLR,size(mrsi.spec2.fidimg_orig,2))
    mrsi.selectLR = size(mrsi.spec2.fidimg_orig,2);
    SP2_MRSI_MrsiWinUpdate
end
if mrsi.selectPA>size(mrsi.spec2.fidimg_orig,3)
    fprintf('Spectrum selection P/A reduced to stay within\navailable matrix size (%.0f -> %.0f)\n',...
            mrsi.selectPA,size(mrsi.spec2.fidimg_orig,3))
    mrsi.selectPA = size(mrsi.spec2.fidimg_orig,3);
    SP2_MRSI_MrsiWinUpdate
end

%--- initial data assignment ---
mrsi.spec2.fid    = mrsi.spec2.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA);
mrsi.spec2.nspecC = mrsi.spec2.nspecC_orig;

% %--- automatic eddy current, frequency and amplitude correction ---
% if flag.mrsiECCorr               % frequ. & amplitude correction
%     if ~SP2_MRSI_ECCorr(1)    
%         fprintf('%s ->\neddy current correction failed.\nProgram aborted.\n\n',FCTNAME);
%         return
%     end
% end
% if flag.mrsiFreqCorr             % frequency correction
%     if ~SP2_MRSI_FreqCorr(1)   
%         fprintf('%s ->\nfrequency correction failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end
% if flag.mrsiAmplCorr             % amplitude correction (only)
%     if ~SP2_MRSI_AmplCorr(1) 
%         fprintf('%s ->\namplitude correction failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end


%--- exponential line broadening ---
if flag.mrsiSpec2Lb
    [mrsi.spec2.fid, f_done] = SP2_MRSI_ExpLineBroadening(mrsi.spec2);
    if ~f_done
        fprintf('%s ->\nExponential line broadening of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- Gaussian line broadening ---
if flag.mrsiSpec2Gb
    [mrsi.spec2.fid, f_done] = SP2_MRSI_GaussianLineBroadening(mrsi.spec2);
    if ~f_done
        fprintf('%s ->\nGaussian line broadening of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- frequency shift ---
if flag.mrsiSpec2Shift
    [mrsi.spec2.fid,f_done] = SP2_MRSI_FreqShift(mrsi.spec2);
    if ~f_done
        fprintf('%s ->\nFrequency shift of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- FID data cut-off ---
if flag.mrsiSpec2Cut
    if mrsi.spec2.cut<mrsi.spec2.nspecC
        mrsi.spec2.fid = mrsi.spec2.fid(1:mrsi.spec2.cut,1);
%         fprintf('FID cut-off: %i -> %i\n',mrsi.nspecC,mrsi.fidCut);
        mrsi.spec2.nspecC = mrsi.spec2.cut;
    else
        fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,mrsi.spec2.cut,mrsi.spec2.nspecC)
    end
end

%--- time-domaine zero-filling ---
if flag.mrsiSpec2Zf
    if mrsi.spec2.zf>mrsi.spec2.nspecC
        fid2Zf = complex(zeros(mrsi.spec2.zf,1));
        fid2Zf(1:mrsi.spec2.nspecC,1) = mrsi.spec2.fid;
        mrsi.spec2.fid = fid2Zf;
%          fprintf('FID ZF: %i -> %i\n',mrsi.nspecC,mrsi.fidZf);
        mrsi.spec2.nspecC = mrsi.spec2.zf;
        clear fid2Zf
    else
        fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,mrsi.spec2.zf,mrsi.spec2.nspecC)
    end
end

%--- spectral baseline offset ---
if flag.mrsiSpec2Offset
    mrsi.spec2.fid(1) = mrsi.spec2.fid(1)*mrsi.spec2.offset;
end

%--- update success flag ---
f_done = 1;

