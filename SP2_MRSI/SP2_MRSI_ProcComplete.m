%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ProcComplete
%%
%%  Complete spectral processing function.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag

    
FCTNAME = 'SP2_MRSI_ProcComplete';

%--- init success flag ---
f_done = 0;

%--- SPECTRUM 1 ---
%--- data assignment ---
if ~SP2_MRSI_ProcData1
    fprintf('%s ->\nProcessing of data set 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- SPECTRUM 2 ---
if flag.mrsiNumSpec        % 2 spectra
    %--- data assignment ---
    if ~SP2_MRSI_ProcData2
        fprintf('%s ->\nProcessing of data set 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- combination of spectra ---
    if mrsi.spec1.nspecC==mrsi.spec2.nspecC
        %--- FID calculations ---
        mrsi.fidSum  = mrsi.spec1.fid + mrsi.spec2.fid;
        mrsi.fidDiff = mrsi.spec1.fid - mrsi.spec2.fid;

        %--- spectrum calculations ---
        mrsi.specSum  = mrsi.spec1.spec + mrsi.spec2.spec;
        mrsi.specDiff = mrsi.spec1.spec - mrsi.spec2.spec;
        
        %--- baseline correction ---
        if flag.mrsiBaseCorr>0
            mrsi.diff.spec = mrsi.specDiff;         % quick and dirty!
            [mrsi.diff,f_done] = SP2_MRSI_SpectralBaselineCorrPolySingle(mrsi.diff);     
            if ~f_done
                return
            end
            mrsi.specDiff = mrsi.diff.spec;
        end
    else
        fprintf('%s ->\nSpectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
                mrsi.spec1.nspecC,mrsi.spec2.nspecC)
    end
end

%--- update success flag ---
f_done = 1;
