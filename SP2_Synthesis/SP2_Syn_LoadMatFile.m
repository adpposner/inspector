%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [fid,nspecC,sf,sw_h,f_succ] = SP2_Syn_LoadMatFile(matFilePath)
%% 
%%  Load FID parameters from .mat file.
%%
%%  12-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn

FCTNAME = 'SP2_Syn_LoadMatFile';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(matFilePath)
    return
end

%--- load data & parameters from file ---
load(matFilePath)

%--- consistency check ---
if ~exist('exptDat','var')
    fprintf('%s ->\nUnknown data format detected. Data loading aborted.\n',FCTNAME)
    return
end

%--- data & parameters assignment ---
if isfield(exptDat,'fid')       % FID
    fid = exptDat.fid;
else
    fprintf('%s ->\n<fid> data not found in data file. Program aborted.\n',FCTNAME)
    return
end
if isfield(exptDat,'sf')        % larmor frequency in [MHz]
    sf = exptDat.sf;
else
    fprintf('%s ->\nParameter <sf> not found in data file. Program aborted.\n',FCTNAME)
    return
end
if isfield(exptDat,'sw_h')      % sweep width in [Hz]
    sw_h = exptDat.sw_h;
else
    fprintf('%s ->\nParameter <sw_h> not found in data file. Program aborted.\n',FCTNAME)
    return
end
if isfield(exptDat,'nspecC')    % number of complex data points
    nspecC     = exptDat.nspecC;
else
    fprintf('%s ->\nParameter <nspecC> not found in data file. Program aborted.\n',FCTNAME)
    return
end

%--- consistency checks ---
if sf==0 || sw_h==0 || nspecC==0
    fprintf('%s ->\nReading parameter file failed. Program aborted.\n',FCTNAME)
    return
end
    
%--- derivation of secondary parameters ---
if ~isfield(syn,'nspecC')
    syn.nspecC = nspecC;
end
if ~isfield(syn,'sf')
    syn.sf = sf;
end
if ~isfield(syn,'sw_h')
    syn.sw_h = sw_h;
end
syn.sw   = syn.sw_h/syn.sf;
syn.dwell = 1/syn.sw_h;

% syn.sw         = syn.sw_h/syn.sf;        % sweep width in [ppm]
% syn.dwell      = 1/syn.sw_h;             % dwell time
% syn.nspecCOrig = syn.nspecC;

%--- info string ---
fprintf('larmor frequency: %.1f MHz\n',syn.sf)
fprintf('sweep width:      %.1f Hz\n',syn.sw_h)
fprintf('complex points:   %.0f\n',syn.nspecC)
fprintf('ppm calibration:  %.3f ppm (global)\n',syn.ppmCalib)

%--- update success flag ---
f_succ = 1;

