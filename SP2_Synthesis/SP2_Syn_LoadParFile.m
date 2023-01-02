%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Syn_LoadParFile(parFilePath)
%% 
%%  Load FID parameters from .par text file.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile syn

FCTNAME = 'SP2_Syn_LoadParFile';


%--- init success flag ---
f_succ = 0;

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
            syn.sf             = str2double(sfStr);
        elseif strncmp('Spectral width',tline,14)   
            [fake,sw_hStr]     = strtok(tline,'=');
            [sw_hStr,fake]     = strtok(sw_hStr(2:end),'kHz');
            syn.sw_h           = str2double(sw_hStr)*1000;
        elseif strncmp('Acquisition points',tline,18)   
            [fake,nspecCStr]   = strtok(tline,'=');
            syn.nspecC         = str2double(nspecCStr(2:end));
            syn.nspecCOrig     = syn.nspecC;
        elseif strncmp('Zerofilling points',tline,18)   
            [fake,nspecCStr]   = strtok(tline,'=');
            nspecCLowPrio      = str2double(nspecCStr(2:end));
        elseif strncmp('RF offset',tline,9)   
            [fake,ppmCalibStr] = strtok(tline,'=');
            [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
            syn.ppmCalib       = str2double(ppmCalibStr);
        end
    end
    fclose(fid);
else
    fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
end

%--- low priority assignment ---
if syn.nspecC==0 && nspecCLowPrio>0
    syn.nspecC     = nspecCLowPrio;
    syn.nspecCOrig = syn.nspecC;
end        

%--- consistency checks ---
if syn.sf==0 || syn.sw_h==0 || syn.nspecC==0 || syn.nspecCOrig==0
    fprintf('%s ->\nReading parameter file failed. Program aborted.\n',FCTNAME);
    return
end
    
%--- derivation of secondary parameters ---
syn.sw         = syn.sw_h/syn.sf;        % sweep width in [ppm]
syn.dwell      = 1/syn.sw_h;             % dwell time
syn.nspecCOrig = syn.nspecC;

%--- info string ---
fprintf('larmor frequency: %.1f MHz\n',syn.sf);
fprintf('sweep width:      %.1f Hz\n',syn.sw_h);
fprintf('complex points:   %.0f\n',syn.nspecC);
fprintf('ppm calibration:  %.3f ppm (global loggingfile)\n',syn.ppmCalib);

%--- update success flag ---
f_succ = 1;

