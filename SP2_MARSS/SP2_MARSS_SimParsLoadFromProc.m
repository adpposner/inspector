%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_SimParsLoadFromProc
%% 
%%  Assignment of specral parameters from Processing page.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc marss pars

FCTNAME = 'SP2_MARSS_SimParsLoadFromProc';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if isfield(proc,'expt')
    if isfield(proc.expt,'fid')
        %--- format handling ---
        % lcm.fidOrig = proc.expt.fid;
        % lcm.fid     = proc.expt.fid;
        
        %--- consistency check ---
        if ndims(proc.expt.fid)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.expt.fid),0));
        end
    else
        fprintf('%s ->\nNo raw data found. Program aborted.\n\n',FCTNAME);
        return
    end
else
    fprintf('%s ->\nNo data structure found. Program aborted.\n',FCTNAME);
    return
end

%--- assignment of further parameters ---
if isfield(proc.expt,'nspecC')
    marss.nspecCBasic = proc.expt.nspecC;       % number of complex data points (to be modified: cut, ZF)
    marss.nspecC      = proc.expt.nspecC;
else
    fprintf('%s ->\nData set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(proc.expt,'sf')
    marss.sf = proc.expt.sf;
    marss.b0 = marss.sf / pars.gyroRatio;
else
    fprintf('%s ->\nSynthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(proc.expt,'sw_h')
    marss.sw_h  = proc.expt.sw_h;                 % sweep width in Hz
    marss.dwell = 1/marss.sw_h;               % dwell time
    marss.sw    = marss.sw_h/marss.sf;   % sweep width in ppm
else
    fprintf('%s ->\nSweep width (sw_h) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(proc,'ppmCalib')
    marss.ppmCalib = proc.ppmCalib;              % frequency calibration
else
    fprintf('%s -> frequency calibration not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'te')
    marss.te = data.spec1.te;                      % echo time in ms
else
    fprintf('%s -> Echo time (te) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'tm')
    marss.tm = data.spec1.tm;                      % mixing time in ms
else
    fprintf('%s -> Mixing time (tm) not found. Program aborted.\n\n',FCTNAME);
    return
end

%--- info string ---
fprintf('\nSpectral data set loaded from Processing page:\n');
fprintf('Larmor frequency: %.1f MHz\n',marss.sf);
fprintf('Sweep width:      %.1f Hz\n',marss.sw_h);
fprintf('Complex points:   %.0f\n\n',marss.nspecC);

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update read flag ---
f_succ = 1;
