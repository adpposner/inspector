%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_Proc_Spec1DataLoadFromMrsi
%% 
%%  Assignment of specral data set 1
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi proc


FCTNAME = 'SP2_Proc_Spec1DataLoadFromMrsi';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if isfield(mrsi,'expt')
    if isfield(mrsi.expt,'fid')
        %--- format handling ---
        proc.spec1.fidOrig = mrsi.expt.fid;
        
        %--- consistency check ---
        if ndims(proc.spec1.fidOrig)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec1.fidOrig),0));
        end
    else
        fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME);
        return
    end
else
    fprintf('%s ->\nNo data structure for FID 1 found (''mrsi.expt''). Program aborted.\n',FCTNAME);
    return
end

%--- assignment of further parameters ---
if isfield(mrsi.expt,'nspecC')
    proc.spec1.nspecCOrig = mrsi.expt.nspecC;       % number of complex data points (to be modified: cut, ZF)
    proc.spec1.nspecC     = mrsi.expt.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(mrsi.expt,'sf')
    proc.spec1.sf = mrsi.expt.sf;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(mrsi.expt,'sw_h')
    proc.spec1.sw_h  = mrsi.expt.sw_h;                 % sweep width in Hz
    proc.spec1.dwell = 1/proc.spec1.sw_h;               % dwell time
    proc.spec1.sw    = proc.spec1.sw_h/proc.spec1.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw_h) not found. Program aborted.\n\n',FCTNAME);
    return
end

%--- info string ---
fprintf('\nSpectral data set 1 loaded from MRSI sheet:\n');
fprintf('larmor frequency: %.1f MHz\n',proc.spec1.sf);
fprintf('sweep width:      %.1f Hz\n',proc.spec1.sw_h);
fprintf('Complex points:   %.0f\n\n',proc.spec1.nspecC);

%--- data export ---
proc.expt.sf     = proc.spec1.sf;
proc.expt.sw_h   = proc.spec1.sw_h;
proc.expt.nspecC = proc.spec1.nspecC;
if isfield(proc.expt,'spec')
    proc.expt = rmfield(proc.expt,'spec');
end
proc.expt.fid = proc.spec1.fidOrig;

%--- update read flag ---
f_succ = 1;

end
