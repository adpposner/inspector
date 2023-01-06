%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MARSS_SimParsLoadFromLcm
%% 
%%  Assignment of specral parameters from LCM page.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm marss pars


FCTNAME = 'SP2_MARSS_SimParsLoadFromLcm';


%--- init success flag ---
f_succ = 0;

%--- data assignment ---
if isfield(lcm,'expt')
    if isfield(lcm.expt,'fid')
        %--- format handling ---
        % proc.spec1.fidOrig = lcm.expt.fid;
        
        %--- consistency check ---
        if ndims(lcm.expt.fid)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(lcm.expt.fid),0));
        end
    else
        fprintf('%s ->\nLCM data not found. Program aborted.\n\n',FCTNAME);
        return
    end
else
    fprintf('%s ->\nNo data structure for FID 1 found (''lcm.expt''). Program aborted.\n',FCTNAME);
    return
end

%--- assignment of further parameters ---
if isfield(lcm.expt,'nspecC')
    marss.nspecCBasic = lcm.expt.nspecC;       % number of complex data points (to be modified: cut, ZF)
    marss.nspecC      = lcm.expt.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(lcm.expt,'sf')
    marss.sf = lcm.expt.sf;
    marss.b0 = marss.sf / pars.gyroRatio;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(lcm.expt,'sw_h')
    marss.sw_h  = lcm.expt.sw_h;                 % sweep width in Hz
    marss.dwell = 1/marss.sw_h;               % dwell time
    marss.sw    = marss.sw_h/marss.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw_h) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(lcm,'ppmCalib')
    marss.ppmCalib = lcm.ppmCalib;              % frequency calibration
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
fprintf('\nSpectral data set 1 loaded from LCM sheet:\n');
fprintf('larmor frequency: %.1f MHz\n',marss.sf);
fprintf('sweep width:      %.1f Hz\n',marss.sw_h);
fprintf('Complex points:   %.0f\n\n',marss.nspecC);

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update read flag ---
f_succ = 1;

end
