%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MARSS_SimParsLoadFromMrsi
%% 
%%  Assignment of specral parameters from MRSI page.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi marss pars


FCTNAME = 'SP2_MARSS_SimParsLoadFromMrsi';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if isfield(mrsi,'expt')
    if isfield(mrsi.expt,'fid')
        %--- format handling ---
        % proc.spec1.fidOrig = mrsi.expt.fid;
        
        %--- consistency check ---
        if ndims(mrsi.expt.fid)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(mrsi.expt.fid),0));
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
    marss.nspecCBasic = mrsi.expt.nspecC;       % number of complex data points (to be modified: cut, ZF)
    marss.nspecC      = mrsi.expt.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(mrsi.expt,'sf')
    marss.sf = mrsi.expt.sf;
    marss.b0 = marss.sf / pars.gyroRatio;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(mrsi.expt,'sw_h')
    marss.sw_h  = mrsi.expt.sw_h;                 % sweep width in Hz
    marss.dwell = 1/marss.sw_h;               % dwell time
    marss.sw    = marss.sw_h/marss.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw_h) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(mrsi,'ppmCalib')
    marss.ppmCalib = mrsi.ppmCalib;              % frequency calibration
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
fprintf('\nSpectral data set 1 loaded from MRSI sheet:\n');
fprintf('larmor frequency: %.1f MHz\n',marss.sf);
fprintf('sweep width:      %.1f Hz\n',marss.sw_h);
fprintf('Complex points:   %.0f\n\n',marss.nspecC);

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update read flag ---
f_succ = 1;
