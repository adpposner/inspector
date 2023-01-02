%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ProcSpecSumAndDiffOnly
%%
%%  Re-calculation of sum/difference spectrum only (e.g. after baseline
%%  correction).
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi

    
FCTNAME = 'SP2_MRSI_ProcSpecSumAndDiffOnly';

%--- init success flag ---
f_done = 0;

%--- check data existence ---
if ~isfield(mrsi,'spec1')
    fprintf('%s ->\nData set 1 does not exist. Load first.\n\n',FCTNAME);
    return
end
if ~isfield(mrsi,'spec2')
    fprintf('%s ->\nData set 2 does not exist. Load first.\n\n',FCTNAME);
    return
end
if ~isfield(mrsi.spec1,'spec')
    fprintf('%s ->\nSpectrum 1 does not exist. Calculate first.\n\n',FCTNAME);
    return
end
if ~isfield(mrsi.spec2,'spec')
    fprintf('%s ->\nSpectrum 2 does not exist. Calculate first.\n\n',FCTNAME);
    return
end

%--- combination of spectra ---
if mrsi.spec1.nspecC==mrsi.spec2.nspecC
    %--- spectrum calculations ---
    mrsi.specSum  = mrsi.spec1.spec + mrsi.spec2.spec;
    mrsi.specDiff = mrsi.spec1.spec - mrsi.spec2.spec;
else
    fprintf('%s -> Spectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
            mrsi.spec1.nspecC,mrsi.spec2.nspecC)
end

%--- update success flag ---
f_done = 1;
