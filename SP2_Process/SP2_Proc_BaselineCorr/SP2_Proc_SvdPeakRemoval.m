%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_SvdPeakRemoval( specNumber )
%%
%%  Hankel SVD-based water removal. Note that the Lanczos algorithm
%%  exploiting the symmetry of the Hankel form to focus on the strongest
%%  signals only (thereby reducing the computational load) has not been
%%  implemented yet, i.e. it's not used here.
%%  Literature: PijnappelWWF92a, DeBeerR92b
%%
%%  07-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc

FCTNAME = 'SP2_Proc_SvdPeakRemoval';


%--- init success flag ---
f_succ = 0;

%--- check data exsistence ---
if ~isfield(proc.svd,'fid') && ~isfield(proc.svd,'spec')
    if ~SP2_Proc_SvdPeakAnalysis(specNumber)
        fprintf('%s ->\nSVD peak analysis failed. Program aborted.\n',FCTNAME)
        return
    end
end

%--- apply correction ---
if specNumber==1            % spectrum 1   
    proc.spec1.fid  = proc.svd.fidDiff;
    proc.spec1.spec = proc.svd.specDiff;
elseif specNumber==2        % spectrum 2
    proc.spec2.fid  = proc.svd.fidDiff;
    proc.spec2.spec = proc.svd.specDiff;
else                        % export spectrum
    proc.expt.fid  = proc.svd.fidDiff;
    proc.expt.spec = proc.svd.specDiff;
end

%--- info printout ---
if specNumber==1            % spectrum 1   
    fprintf('Result of SVD-based peak removal assigned as spectral data set 1.\n')
elseif specNumber==2        % spectrum 2
    fprintf('Result of SVD-based peak removal assigned as spectral data set 2.\n')
else                        % export spectrum
    fprintf('Result of SVD-based peak removal assigned as export spectrum.\n')
end

%--- export handling ---
% note that nothing needs to be done if specNumber==3 (expt)
if specNumber==1            % spectrum 1
    proc.expt.fid    = proc.spec1.fid;
    proc.expt.sf     = proc.spec1.sf;
    proc.expt.sw_h   = proc.spec1.sw_h;
    proc.expt.nspecC = proc.spec1.nspecC;
elseif specNumber==2        % spectrum 2
    proc.expt.fid    = proc.spec2.fid;
    proc.expt.sf     = proc.spec2.sf;
    proc.expt.sw_h   = proc.spec2.sw_h;
    proc.expt.nspecC = proc.spec2.nspecC;
end

%--- update success flag ---
f_succ = 1;


