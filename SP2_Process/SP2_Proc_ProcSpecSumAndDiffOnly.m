%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_ProcSpecSumAndDiffOnly
%%
%%  Re-calculation of sum/difference spectrum only (e.g. after baseline
%%  correction).
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc

    
FCTNAME = 'SP2_Proc_ProcSpecSumAndDiffOnly';

%--- init success flag ---
f_done = 0;

%--- check data existence ---
if ~isfield(proc,'spec1')
    fprintf('%s ->\nData set 1 does not exist. Load first.\n\n',FCTNAME)
    return
end
if ~isfield(proc,'spec2')
    fprintf('%s ->\nData set 2 does not exist. Load first.\n\n',FCTNAME)
    return
end
if ~isfield(proc.spec1,'spec')
    fprintf('%s ->\nSpectrum 1 does not exist. Calculate first.\n\n',FCTNAME)
    return
end
if ~isfield(proc.spec2,'spec')
    fprintf('%s ->\nSpectrum 2 does not exist. Calculate first.\n\n',FCTNAME)
    return
end

%--- combination of spectra ---
if proc.spec1.nspecC==proc.spec2.nspecC
    %--- spectrum calculations ---
    proc.specSum  = proc.spec1.spec + proc.spec2.spec;
    proc.specDiff = proc.spec1.spec - proc.spec2.spec;
else
    fprintf('%s -> Spectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
            proc.spec1.nspecC,proc.spec2.nspecC)
end

%--- update success flag ---
f_done = 1;
