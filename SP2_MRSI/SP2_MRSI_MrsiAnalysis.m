%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_MrsiAnalysis
%% 
%%  Conversion of procpar structure to method structure that will be used 
%%  in this software.
%%  Note the nomenclature for nr, nt and nv:
%%  nr refers to the number of acquisitions. For regular, scanner-summed
%%  acquisitions it therefore equals nt. For phase-cycled acquisitions it
%%  equals nv, i.e. the number of sequence repetitions. In fact, nr was
%%  introduced to allow above distinction and provide the corresponding
%%  experiment flexibility.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_MrsiAnalysis';

t0 = clock;         % start time measurement of particular data analysis


%----------------------------------------------------------------------------------------------
%---------     P R O G R A M     S T A R T     ------------------------------------------------
%----------------------------------------------------------------------------------------------
fprintf('\n%s started:\n',FCTNAME);

% %--- (re)load data ---
% if ~SP2_MRSI_DataAndParsAssign1
%     return
% end
% 
% %--- (re)load reference ---
% if flag.mrsiEcc
%     if ~SP2_MRSI_DataAndParsAssignRef
%         return
%     end    
% end

%--- check data existence and (re)init raw data 1 ---
if isfield(mrsi.spec1,'fidkspOrig')
    mrsi.spec1.fidksp = mrsi.spec1.fidkspOrig;
    mrsi.spec1.nspecC = mrsi.spec1.nspecCOrig;
    mrsi.spec1.mat    = mrsi.spec1.matOrig;
    mrsi.spec1.nEncR  = mrsi.spec1.nEncROrig;
    mrsi.spec1.nEncP  = mrsi.spec1.nEncPOrig;
    fprintf('Data set 1 (re)loaded.\n');
else
    fprintf('No raw data set 1 found. Load first.\n');
    return
end

%--- check data existence and (re)init raw data 2 ---
if flag.mrsiNumSpec           % '2' data sets (flag) for JDE
    if isfield(mrsi.spec2,'fidkspOrig')
        mrsi.spec2.fidksp = mrsi.spec2.fidkspOrig;
        mrsi.spec2.nspecC = mrsi.spec2.nspecCOrig;
        mrsi.spec2.mat    = mrsi.spec2.matOrig;
        mrsi.spec2.nEncR  = mrsi.spec2.nEncROrig;
        mrsi.spec2.nEncP  = mrsi.spec2.nEncPOrig;
        fprintf('Data set 2 (re)loaded.\n');
    else
        fprintf('No raw data set 2 found. Load first.\n');
        return
    end
end

%--- check data existence and (re)init raw reference data ---
if isfield(mrsi.ref,'fidkspOrig')
    mrsi.ref.fidksp = mrsi.ref.fidkspOrig;
    mrsi.ref.nspecC = mrsi.ref.nspecCOrig;
    mrsi.ref.mat    = mrsi.ref.matOrig;
    mrsi.ref.nEncR  = mrsi.ref.nEncROrig;
    mrsi.ref.nEncP  = mrsi.ref.nEncPOrig;
    fprintf('Reference data set (re)loaded.\n');
else
    fprintf('No reference raw data set found. Load first.\n');
    return
end


% %--- data preparation ---
% mrsi.spec1.fid = mrsi.spec1.fid(2:end,:,:);
% mrsi.spec1.nspecC = size(mrsi.spec1.fid,1);

%--- k-space filter adaptation ---
% if flag.mrsiEcc
%     [mrsi.spec1,f_done] = SP2_MRSI_SpatialAcqWeightRescale(mrsi.spec1);
%     if ~f_done
%         return
%     end
% end
%--- match spatial filter ---
if ~SP2_MRSI_SpatialFilterMatchRef2Metab
    return
end

%--- (direct application of) 2D spatial filter ---
if flag.mrsiSpatFilt && (flag.mrsiEcc || flag.mrsiBaseCorr)
    [mrsi.spec1,f_done] = SP2_MRSI_SpatialFilter(mrsi.spec1);
    if ~f_done
        return
    end
end
if flag.mrsiSpatFilt && (flag.mrsiEcc || flag.mrsiBaseCorr) && flag.mrsiNumSpec
    [mrsi.spec2,f_done] = SP2_MRSI_SpatialFilter(mrsi.spec2);
    if ~f_done
        return
    end
end
if flag.mrsiSpatFilt && (flag.mrsiEcc || flag.mrsiBaseCorr)
    [mrsi.ref,f_done] = SP2_MRSI_SpatialFilter(mrsi.ref);
    if ~f_done
        return
    end
end

%--- spatial zero-filling ---
if flag.mrsiSpatZF
    [mrsi.spec1,f_done] = SP2_MRSI_SpatialZF(mrsi.spec1);
    if ~f_done
        return
    end
end
if flag.mrsiSpatZF && flag.mrsiNumSpec
    [mrsi.spec2,f_done] = SP2_MRSI_SpatialZF(mrsi.spec2);
    if ~f_done
        return
    end
end
if flag.mrsiSpatZF
    [mrsi.ref,f_done] = SP2_MRSI_SpatialZF(mrsi.ref);
    if ~f_done
        return
    end
end

%--- 2D spatial reconstruction ---
[mrsi.spec1,f_done] = SP2_MRSI_SpatialReco(mrsi.spec1);
if ~f_done
    return
end
if flag.mrsiNumSpec
    [mrsi.spec2,f_done] = SP2_MRSI_SpatialReco(mrsi.spec2);
    if ~f_done
        return
    end
end
[mrsi.ref,f_done] = SP2_MRSI_SpatialReco(mrsi.ref);
if ~f_done
    return
end

%--- ECC apodization ---
if flag.mrsiEcc
    [mrsi.spec1,f_done] = SP2_MRSI_SpectralECC(mrsi.spec1);
    if ~f_done
        return
    end
end
if flag.mrsiEcc && flag.mrsiNumSpec
    [mrsi.spec2,f_done] = SP2_MRSI_SpectralECC(mrsi.spec2);
    if ~f_done
        return
    end
end

%--- Combine receivers ---
[mrsi.spec1,f_done] = SP2_MRSI_RcvrCombination(mrsi.spec1);
if ~f_done
    return
end
if flag.mrsiNumSpec
    [mrsi.spec2,f_done] = SP2_MRSI_RcvrCombination(mrsi.spec2);
    if ~f_done
        return
    end
end
[mrsi.ref,f_done] = SP2_MRSI_RcvrCombination(mrsi.ref);
if ~f_done
    return
end

%--- cuf starting FID points ---
nStart = 2;
mrsi.spec1.fidimg = mrsi.spec1.fidimg(nStart:end,:,:);
mrsi.spec1.nspecC = mrsi.spec1.nspecC-nStart+1;
if flag.mrsiNumSpec
    mrsi.spec2.fidimg = mrsi.spec2.fidimg(nStart:end,:,:);
    mrsi.spec2.nspecC = mrsi.spec2.nspecC-nStart+1;
end
mrsi.ref.fidimg   = mrsi.ref.fidimg(nStart:end,:,:);
mrsi.ref.nspecC   = mrsi.ref.nspecC-nStart+1;

% %--- spatial phase correction ---
% [mrsi.spec1,f_done] = SP2_MRSI_SpatialPhaseCorr(mrsi.spec1);
% if ~f_done
%     return
% end
% if flag.mrsiNumSpec
%     [mrsi.spec2,f_done] = SP2_MRSI_SpatialPhaseCorr(mrsi.spec2);
%     if ~f_done
%         return
%     end
% end

%--- keep original FID matrix for individual processing ---
mrsi.spec1.fidimg_orig = mrsi.spec1.fidimg;     % original FID image
mrsi.spec1.nspecC_orig = mrsi.spec1.nspecC;     % original FID length
mrsi.spec1.nspecCimg   = mrsi.spec1.nspecC;     % image-specific data length (split from here)
if flag.mrsiNumSpec
    mrsi.spec2.fidimg_orig = mrsi.spec2.fidimg;     % original FID image
    mrsi.spec2.nspecC_orig = mrsi.spec2.nspecC;     % original FID length
    mrsi.spec2.nspecCimg   = mrsi.spec2.nspecC;     % image-specific data length (split from here)
end
mrsi.ref.fidimg_orig   = mrsi.ref.fidimg;       % original reference FID image
mrsi.ref.nspecC_orig   = mrsi.ref.nspecC;       % original reference FID length
mrsi.ref.nspecCimg     = mrsi.ref.nspecC;       % image-specific reference data length (split from here)


%-----------------------------------------
%--- note that proc updates start here ---
%-----------------------------------------

%--- FID apodization ---
if flag.mrsiSpec1Cut
    [mrsi.spec1,f_done] = SP2_MRSI_SpectralCut(mrsi.spec1);
    if ~f_done
        return
    end
end
if flag.mrsiNumSpec
    if flag.mrsiSpec1Cut            % note that spec1 flag is used here as common setting
        [mrsi.spec2,f_done] = SP2_MRSI_SpectralCut(mrsi.spec2);
        if ~f_done
            return
        end
    end
end

%--- spectral line broadening ---
if flag.mrsiSpec1Lb
    [mrsi.spec1,f_done] = SP2_MRSI_SpectralLB(mrsi.spec1);
    if ~f_done
        return
    end
end
if flag.mrsiNumSpec
    if flag.mrsiSpec2Lb             
        [mrsi.spec2,f_done] = SP2_MRSI_SpectralLB(mrsi.spec2);
        if ~f_done
            return
        end
    end
end

%--- spectral zero-filling ---
if flag.mrsiSpec1Zf
    [mrsi.spec1,f_done] = SP2_MRSI_SpectralZF(mrsi.spec1);
    if ~f_done
        return
    end
end
if flag.mrsiNumSpec
    if flag.mrsiSpec1Zf             % note that spec1 flag is used here as common setting
        [mrsi.spec2,f_done] = SP2_MRSI_SpectralZF(mrsi.spec2);
        if ~f_done
            return
        end
    end
end

%--- 1D spectral FFT ---
[mrsi.spec1,f_done] = SP2_MRSI_SpectralFftMrsi(mrsi.spec1);
if ~f_done
    return
end
if flag.mrsiNumSpec
    [mrsi.spec2,f_done] = SP2_MRSI_SpectralFftMrsi(mrsi.spec2);
    if ~f_done
        return
    end
end

%--- spectral line broadening ---
if flag.mrsiSpec1Phc0 || flag.mrsiSpec1Phc1
    [mrsi.spec1,f_done] = SP2_MRSI_SpectralPhaseCorr(mrsi.spec1);     
    if ~f_done
        return
    end
end
if flag.mrsiNumSpec
    if flag.mrsiSpec2Phc0 || flag.mrsiSpec2Phc1
        [mrsi.spec2,f_done] = SP2_MRSI_SpectralPhaseCorr(mrsi.spec2);
        if ~f_done
            return
        end
    end
end

%--- baseline correction ---
if flag.mrsiNumSpec==0              % if single map, i.e. no JDE
    if flag.mrsiBaseCorr>0
        [mrsi.spec1,f_done] = SP2_MRSI_SpectralBaselineCorrPoly(mrsi.spec1);     
        if ~f_done
            return
        end
    end
%     if flag.mrsiBaseCorr>0
%         [mrsi.spec2,f_done] = SP2_MRSI_SpectralBaselineCorrPoly(mrsi.spec2);
%         if ~f_done
%             return
%         end
%     end
end

%--- difference calculation ---
if flag.mrsiNumSpec
    mrsi.diff = mrsi.spec1;
    mrsi.diff.specimg = mrsi.spec1.specimg - mrsi.spec2.specimg;
    mrsi.diff.name    = 'Difference';
end

%--- baseline correction ---
if flag.mrsiNumSpec             % apply baseline correction to final difference (only)
    if flag.mrsiBaseCorr>0
        [mrsi.diff,f_done] = SP2_MRSI_SpectralBaselineCorrPoly(mrsi.diff);     
        if ~f_done
            return
        end
    end
end

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

%--- info printout ---
fprintf('%s completed (elapsed time %.1f minutes)\n\n',FCTNAME,etime(clock,t0)/60);

