%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_LCM_SpecDataLoadFromMarssPage
%% 
%%  Assignment of FID from MARSS page.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm marss

FCTNAME = 'SP2_LCM_SpecDataLoadFromMarssPage';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if isfield(marss,'expt')
    if isfield(marss.expt,'fid')
        %--- format handling ---
        lcm.fidOrig = marss.expt.fid;
        lcm.fid     = marss.expt.fid;
        
        %--- consistency check ---
        if ndims(lcm.fidOrig)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(lcm.fidOrig),0))
        end
    else
        fprintf('%s ->\nNo raw data found. Program aborted.\n\n',FCTNAME)
        return
    end
else
    fprintf('%s ->\nNo data structure found. Program aborted.\n',FCTNAME)
    return
end

%--- assignment of further parameters ---
if isfield(marss.expt,'nspecC')
    lcm.nspecCOrig = marss.expt.nspecC;       % number of complex data points (to be modified: cut, ZF)
    lcm.nspecC     = marss.expt.nspecC;
else
    fprintf('%s ->\nData set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(marss.expt,'sf')
    lcm.sf = marss.expt.sf;
else
    fprintf('%s ->\nSynthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(marss.expt,'sw_h')
    lcm.sw_h  = marss.expt.sw_h;                 % sweep width in Hz
    lcm.dwell = 1/lcm.sw_h;               % dwell time
    lcm.sw    = lcm.sw_h/lcm.sf;   % sweep width in ppm
else
    fprintf('%s ->\nSweep width (sw_h) not found. Program aborted.\n\n',FCTNAME)
    return
end

%--- info string ---
fprintf('\nSpectral data set loaded from MARSS page:\n')
fprintf('Larmor frequency: %.1f MHz\n',lcm.sf)
fprintf('Sweep width:      %.1f Hz\n',lcm.sw_h)
fprintf('Complex points:   %.0f\n\n',lcm.nspecC)

%--- data export ---
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;
if isfield(lcm.expt,'spec')
    lcm.expt = rmfield(lcm.expt,'spec');
end
lcm.expt.fid = lcm.fidOrig;

%--- update read flag ---
f_succ = 1;
