%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ProcessFid1
%%
%%  Spectral processing of FID 1
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

    
FCTNAME = 'SP2_MRSI_DoProcessFid1';

%--- init success flag ---
f_done = 0;

%--- consistency checks ---
if mrsi.selectLR>size(mrsi.spec1.fidimg_orig,2)
    fprintf('Spectrum selection L/R reduced to stay within\navailable matrix size (%.0f -> %.0f)\n',...
            mrsi.selectLR,size(mrsi.spec1.fidimg_orig,2))
    mrsi.selectLR = size(mrsi.spec1.fidimg_orig,2);
    SP2_MRSI_MrsiWinUpdate
end
if mrsi.selectPA>size(mrsi.spec1.fidimg_orig,3)
    fprintf('Spectrum selection P/A reduced to stay within\navailable matrix size (%.0f -> %.0f)\n',...
            mrsi.selectPA,size(mrsi.spec1.fidimg_orig,3))
    mrsi.selectPA = size(mrsi.spec1.fidimg_orig,3);
    SP2_MRSI_MrsiWinUpdate
end

%--- initial data assignment ---
mrsi.spec1.fid    = mrsi.spec1.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA);
mrsi.spec1.nspecC = mrsi.spec1.nspecC_orig;

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
if flag.mrsiSpec1Lb
    [mrsi.spec1.fid, f_done] = SP2_MRSI_ExpLineBroadening(mrsi.spec1);
    if ~f_done
        fprintf('%s ->\nExponential line broadening of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- Gaussian line broadening ---
if flag.mrsiSpec1Gb
    [mrsi.spec1.fid, f_done] = SP2_MRSI_GaussianLineBroadening(mrsi.spec1);
    if ~f_done
        fprintf('%s ->\nGaussian line broadening of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- frequency shift ---
if flag.mrsiSpec1Shift
    [mrsi.spec1.fid,f_done] = SP2_MRSI_FreqShift(mrsi.spec1);
    if ~f_done
        fprintf('%s ->\nFrequency shift of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- FID data cut-off ---
if flag.mrsiSpec1Cut
    if mrsi.spec1.cut<mrsi.spec1.nspecC
        mrsi.spec1.fid = mrsi.spec1.fid(1:mrsi.spec1.cut,1);
%         fprintf('FID cut-off: %i -> %i\n',mrsi.nspecC,mrsi.fidCut);
        mrsi.spec1.nspecC = mrsi.spec1.cut;
    else
        fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,mrsi.spec1.cut,mrsi.spec1.nspecC)
    end
end

%--- time-domaine zero-filling ---
if flag.mrsiSpec1Zf
    if mrsi.spec1.zf>mrsi.spec1.nspecC
        fid1Zf = complex(zeros(mrsi.spec1.zf,1));
        fid1Zf(1:mrsi.spec1.nspecC,1) = mrsi.spec1.fid;
        mrsi.spec1.fid = fid1Zf;
%          fprintf('FID ZF: %i -> %i\n',mrsi.nspecC,mrsi.fidZf);
        mrsi.spec1.nspecC = mrsi.spec1.zf;
        clear fid1Zf
    else
        fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,mrsi.spec1.zf,mrsi.spec1.nspecC)
    end
end

%--- spectral baseline offset ---
if flag.mrsiSpec1Offset
    mrsi.spec1.fid(1) = mrsi.spec1.fid(1)*mrsi.spec1.offset;
end

%--- update success flag ---
f_done = 1;


end
