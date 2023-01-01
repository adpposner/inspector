%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_LoadParFile(parFilePath)
%% 
%%  Load FID parameters from .par text file.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm

FCTNAME = 'SP2_MM_LoadParFile';


%--- init success flag ---
f_done = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(parFilePath)
    return
end

%--- read parameter file ---
fid = fopen(parFilePath,'r');
if (fid > 0)
    while (~feof(fid))
        tline = fgetl(fid);
        if strncmp('Field strength',tline,14)
            [fake,sfStr]       = strtok(tline,'=');
            [sfStr,fake]       = strtok(sfStr(2:end),'MHz');
            mm.sf              = str2double(sfStr);
        elseif strncmp('Spectral width',tline,14)   
            [fake,sw_hStr]     = strtok(tline,'=');
            [sw_hStr,fake]     = strtok(sw_hStr(2:end),'kHz');
            mm.sw_h            = str2double(sw_hStr)*1000;
        elseif strncmp('Acquisition points',tline,18)   
            [fake,nspecCStr]   = strtok(tline,'=');
            mm.nspecC          = str2double(nspecCStr(2:end));
            mm.nspecCOrig      = mm.nspecC;
        elseif strncmp('Zerofilling points',tline,18)   
            [fake,nspecCStr]   = strtok(tline,'=');
            nspecCLowPrio      = str2double(nspecCStr(2:end));
        elseif strncmp('RF offset',tline,9)   
            [fake,ppmCalibStr] = strtok(tline,'=');
            [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
            mm.ppmCalib        = str2double(ppmCalibStr);
        end
    end
    fclose(fid);
else
    fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
end

%--- low priority assignment ---
if mm.nspecC==0 && nspecCLowPrio>0
    mm.nspecC     = nspecCLowPrio;
    mm.nspecCOrig = mm.nspecC;
end        

%--- consistency checks ---
if mm.sf==0 || mm.sw_h==0 || mm.nspecC==0 || mm.nspecCOrig==0
    fprintf('%s ->\nReading parameter file failed. Program aborted.\n',FCTNAME)
    return
end
    
%--- derivation of secondary parameters ---
mm.sw    = mm.sw_h/mm.sf;       % sweep width in [ppm]
mm.dwell = 1/mm.sw_h;                   % dwell time

%--- info string ---
fprintf('larmor frequency: %.1f MHz\n',mm.sf)
fprintf('sweep width:      %.1f Hz\n',mm.sw_h)
fprintf('complex points:   %.0f\n',mm.nspecC)
fprintf('ppm calibration:  %.3f ppm (global)\n\n',mm.ppmCalib)

%--- update success flag ---
f_done = 1;

