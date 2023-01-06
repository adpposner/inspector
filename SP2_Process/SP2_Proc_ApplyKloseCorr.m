%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ApplyKloseCorr
%% 
%%  Apply Klose phase correction.
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc

FCTNAME = 'SP2_Data_ApplyKloseCorr';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(proc.spec1,'fidOrig') ||  ~isfield(proc.spec1,'nspecCOrig')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end
if ~isfield(proc.spec2,'fidOrig') ||  ~isfield(proc.spec2,'nspecCOrig')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME);
    return
end

%--- consistency checks ---
if ndims(proc.spec1.fidOrig)<ndims(proc.spec2.fidOrig)
    fprintf('%s ->\nThe data dimensions are not compatible. Program aborted.\n',FCTNAME);
    return
end

%--- Klose correction ---
phaseCorr = unwrap(angle(proc.spec2.fidOrig));
proc.spec1.fidOrig = proc.spec1.fidOrig .* exp(-1i*phaseCorr);

%--- export handling ---
proc.expt.fid    = proc.spec1.fidOrig;
proc.expt.sf     = proc.spec1.sf;
proc.expt.sw_h   = proc.spec1.sw_h;
proc.expt.nspecC = proc.spec1.nspecC;

%--- info printout ---
fprintf('%s done.\n',FCTNAME);
    
%--- update success flag ---
f_succ = 1;

end
