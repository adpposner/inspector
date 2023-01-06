%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MRSI_SvdPeakRemoval( specNumber )
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

global mrsi

FCTNAME = 'SP2_MRSI_SvdPeakRemoval';


%--- init success flag ---
f_succ = 0;

%--- check data exsistence ---
if ~isfield(mrsi.svd,'fid') && ~isfield(mrsi.svd,'spec')
    if ~SP2_MRSI_SvdPeakAnalysis(specNumber)
        fprintf('%s ->\nSVD peak analysis failed. Program aborted.\n',FCTNAME);
        return
    end
end

%--- apply correction ---
if specNumber==1            % spectrum 1   
    mrsi.spec1.fid  = mrsi.svd.fidDiff;
    mrsi.spec1.spec = mrsi.svd.specDiff;
elseif specNumber==2        % spectrum 2
    mrsi.spec2.fid  = mrsi.svd.fidDiff;
    mrsi.spec2.spec = mrsi.svd.specDiff;
else                        % export spectrum
    mrsi.expt.fid  = mrsi.svd.fidDiff;
    mrsi.expt.spec = mrsi.svd.specDiff;
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
    mrsi.expt.fid    = mrsi.spec1.fid;
    mrsi.expt.sf     = mrsi.spec1.sf;
    mrsi.expt.sw_h   = mrsi.spec1.sw_h;
    mrsi.expt.nspecC = mrsi.spec1.nspecC;
elseif specNumber==2        % spectrum 2
    mrsi.expt.fid    = mrsi.spec2.fid;
    mrsi.expt.sf     = mrsi.spec2.sf;
    mrsi.expt.sw_h   = mrsi.spec2.sw_h;
    mrsi.expt.nspecC = mrsi.spec2.nspecC;
end

%--- update success flag ---
f_succ = 1;



end
