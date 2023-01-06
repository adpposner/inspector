%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_SvdPeakRemoval( specNumber )
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

global lcm

FCTNAME = 'SP2_LCM_SvdPeakRemoval';


%--- init success flag ---
f_succ = 0;

%--- check data exsistence ---
if ~isfield(lcm.svd,'fid') && ~isfield(lcm.svd,'spec')
    if ~SP2_LCM_SvdPeakAnalysis(specNumber)
        fprintf('%s ->\nSVD peak analysis failed. Program aborted.\n',FCTNAME);
        return
    end
end

%--- apply correction ---
if specNumber==1            % spectrum 1   
    lcm.spec1.fid  = lcm.svd.fidDiff;
    lcm.spec1.spec = lcm.svd.specDiff;
elseif specNumber==2        % spectrum 2
    lcm.spec2.fid  = lcm.svd.fidDiff;
    lcm.spec2.spec = lcm.svd.specDiff;
else                        % export spectrum
    lcm.expt.fid  = lcm.svd.fidDiff;
    lcm.expt.spec = lcm.svd.specDiff;
end

%--- info printout ---
if specNumber==1            % spectrum 1   
    fprintf('Result of OVS-based peak removal assigned as spectral data set 1.\n');
elseif specNumber==2        % spectrum 2
    fprintf('Result of OVS-based peak removal assigned as spectral data set 2.\n');
else                        % export spectrum
    fprintf('Result of OVS-based peak removal assigned as export spectrum.\n');
end

%--- export handling ---
% note that nothing needs to be done if specNumber==3 (expt)
if specNumber==1            % spectrum 1
    lcm.expt.fid    = lcm.spec1.fid;
    lcm.expt.sf     = lcm.spec1.sf;
    lcm.expt.sw_h   = lcm.spec1.sw_h;
    lcm.expt.nspecC = lcm.spec1.nspecC;
elseif specNumber==2        % spectrum 2
    lcm.expt.fid    = lcm.spec2.fid;
    lcm.expt.sf     = lcm.spec2.sf;
    lcm.expt.sw_h   = lcm.spec2.sw_h;
    lcm.expt.nspecC = lcm.spec2.nspecC;
end

%--- update success flag ---
f_succ = 1;



end
