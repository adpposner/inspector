%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ProcComplete
%%
%%  Complete spectral processing function.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

    
FCTNAME = 'SP2_Proc_ProcComplete';

%--- init success flag ---
f_succ = 0;

%--- SPECTRUM 1 ---
%--- data assignment ---
if ~SP2_Proc_ProcData1
    fprintf('%s ->\nProcessing of data set 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- SPECTRUM 2 ---
if flag.procNumSpec        % 2 spectra
    %--- data assignment ---
    if ~SP2_Proc_ProcData2
        fprintf('%s ->\nProcessing of data set 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- combination of spectra ---
    if proc.spec1.nspecC==proc.spec2.nspecC
        %--- FID calculations ---
        proc.fidSum  = proc.spec1.fid + proc.spec2.fid;
        proc.fidDiff = proc.spec1.fid - proc.spec2.fid;

        %--- polynomial baseline correction ---
        if flag.procAlignPoly && isfield(proc,'polyFit')                            % 1) poly baseline included in align, 2) alignment has been performed
            if flag.procApplyPoly1 && length(proc.polyFit)==proc.spec1.nspecC       % 1) apply baseline, 2) consistency check: spectral length
                proc.spec1.spec = proc.spec1.spec - proc.polyFit;
            end
            if flag.procApplyPoly2 && length(proc.polyFit)==proc.spec2.nspecC       % 1) apply baseline, 2) consistency check: spectral length
                proc.spec2.spec = proc.spec2.spec - proc.polyFit;
            end
        end

        %--- spectrum calculations ---
        proc.specSum  = proc.spec1.spec + proc.spec2.spec;
        proc.specDiff = proc.spec1.spec - proc.spec2.spec;
    else
        fprintf('%s ->\nSpectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
                proc.spec1.nspecC,proc.spec2.nspecC)
        return
    end
end

%--- update success flag ---
f_succ = 1;
