%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MARSS_SimParsLoadFromSim
%% 
%%  Assignment of specral parameters from Simulation page.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global sim marss pars


FCTNAME = 'SP2_Proc_SP2_MARSS_SimParsLoadFromSim';


%--- init success flag ---
f_succ = 0;

%--- data assignment ---
if isfield(sim,'expt')
    if isfield(sim.expt,'fid')
        %--- format handling ---
        % proc.spec1.fidOrig = sim.expt.fid;
        
        %--- consistency check ---
        if ndims(proc.spec1.fidOrig)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec1.fidOrig),0))
        end
    else
        fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME)
        return
    end
else
    fprintf('%s ->\nNo data structure for FID 1 found (''sim.expt''). Program aborted.\n',FCTNAME)
    return
end

%--- assignment of further parameters ---
if isfield(sim.expt,'nspecC')
    marss.nspecCBasic = sim.expt.nspecC;       % number of complex data points (to be modified: cut, ZF)
    marss.nspecC      = sim.expt.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(sim.expt,'sf')
    marss.sf = sim.expt.sf;
    marss.b0 = marss.sf / pars.gyroRatio;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(sim.expt,'sw_h')
    marss.sw_h  = sim.expt.sw_h;                 % sweep width in Hz
    marss.dwell = 1/marss.sw_h;               % dwell time
    marss.sw    = marss.sw_h/marss.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw_h) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(sim,'ppmCalib')
    marss.ppmCalib = sim.ppmCalib;              % frequency calibration
else
    fprintf('%s -> frequency calibration not found. Program aborted.\n\n',FCTNAME)
    return
end

%--- info string ---
fprintf('\nSpectral data set 1 loaded from Simulation sheet:\n')
fprintf('larmor frequency: %.1f MHz\n',marss.sf)
fprintf('sweep width:      %.1f Hz\n',marss.sw_h)
fprintf('Complex points:   %.0f\n\n',marss.nspecC)

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update read flag ---
f_succ = 1;
