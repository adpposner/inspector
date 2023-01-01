%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [fid,f_succ] = SP2_Syn_LoadRawFile(rawFilePath)
%% 
%%  Load FID parameters from .raw (or .RAW) file.
%%
%%  12-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_LoadRawFile';


%--- init success flag ---
f_succ = 0;
fid    = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(rawFilePath)
    return
end

%--- open data file ---
unit = fopen(rawFilePath,'r');
if unit==-1
    fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME)
    return
end

%--- read parameter header ---
% fprintf('File header:\n')
tline = '';
f_hzpppm = 0;       % init
f_sw_h   = 0;       % init
while isempty(strfind(tline,'$END'))
    tline = fgetl(unit);
    if strfind(tline,'HZPPPM')           % grid size assignment: cylinder geometry
        [fake,sfStr]  = strtok(tline);
        sf = str2double(sfStr);
        f_hzpppm = 1;
    elseif strfind(tline,'DELTAT')  
        [fake,deltatStr] = strtok(tline);
        sw_h  = 1/str2double(deltatStr);
        f_sw_h = 1;
    end
    if flag.debug
        fprintf('%s\n',tline);
    end
end
fprintf('\n')

%--- read data ---
dataTmp = fscanf(unit,'%g',[2 inf]);
fclose(unit);
fid = dataTmp(1,:)' - 1i*dataTmp(2,:)';

%--- init key spectral parameters ---
if f_hzpppm
    fprintf('Larmor frequency read from file: %.1f MHz\n',sf)
end
if f_sw_h
    fprintf('Bandwidth read from file: %.1f Hz\n',sw_h)
end

% %--- ask for parameters ---
% if ~f_hzpppm || ~f_sw_h
%     fprintf('%s ->\nNo parameter file found. Direct assignment required...\n',FCTNAME)
%     if ~isfield(proc.spec1,'sf')
%         syn.sf     = 0;
%     end
%     if ~isfield(proc.spec1,'sw_h')
%         syn.sw_h   = 0;
%     end
%     SP2_Syn_SpecParsDialogMain(0)
%     waitfor(fm.syn.dialog1.fig)
% end

%--- determined FID length directly from data set ---
nspecC = length(fid);        

%--- consistency checks ---
% if sf==0 || sw_h==0 || nspecC==0 || nspecCOrig==0
if nspecC==0
    fprintf('%s ->\nParameter/data reading failed. Program aborted.\n',FCTNAME)
    return
end
    
%--- derivation of secondary parameters ---
% syn.sw         = syn.sw_h/syn.sf;        % sweep width in [ppm]
% syn.dwell      = 1/syn.sw_h;             % dwell time
% syn.nspecCOrig = syn.nspecC;

%--- info string ---
% fprintf('larmor frequency: %.1f MHz\n',syn.sf)
% fprintf('sweep width:      %.1f Hz\n',syn.sw_h)
fprintf('complex points:   %.0f\n',nspecC)
fprintf('ppm calibration:  %.3f ppm (global)\n\n',syn.ppmCalib)

%--- update success flag ---
f_succ = 1;

