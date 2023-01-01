%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_RefDataLoadFromProc
%% 
%%  Function to load reference data from .mat file.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_RefDataLoadFromProc';


%--- init success flag ---
f_done = 0;

%--- load data and parameters from file ---
if flag.mrsiDatFormat       % matlab format
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(mrsi.ref.dataPathMat)
        return
    end

    %--- load data & parameters from file ---
    load(mrsi.ref.dataPathMat)

    %--- consistency check ---
    if ~exist('exptDat','var')
        fprintf('%s ->\nUnknown data format detected. Data loading aborted.\n',FCTNAME)
        return
    end

    %--- data & parameters assignment ---
    if isfield(exptDat,'fid')       % FID
        mrsi.ref.fidOrig = exptDat.fid;
    else
        fprintf('%s ->\n<fid> data not found in data file. Program aborted.\n',FCTNAME)
        return
    end
    if isfield(exptDat,'sf')        % larmor frequency in [MHz]
        mrsi.ref.sf = exptDat.sf;
    else
        fprintf('%s ->\nParameter <sf> not found in data file. Program aborted.\n',FCTNAME)
        return
    end
    if isfield(exptDat,'sw_h')      % sweep width in [Hz]
        mrsi.ref.sw_h = exptDat.sw_h;
    else
        fprintf('%s ->\nParameter <sw_h> not found in data file. Program aborted.\n',FCTNAME)
        return
    end
    if isfield(exptDat,'nspecC')    % number of complex data points
        mrsi.ref.nspecCOrig = exptDat.nspecC;
        mrsi.ref.nspecC     = exptDat.nspecC;
    else
        fprintf('%s ->\nParameter <nspecC> not found in data file. Program aborted.\n',FCTNAME)
        return
    end
else                % RAG text data and parameter files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(mrsi.ref.dataPathTxt)
        return
    end
    
    %--- load data file ---
    unit = fopen(mrsi.ref.dataPathTxt,'r');
    if unit==-1
        fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME)
        return
    end
    dataTmp = fscanf(unit,'%g		%g',[2 inf]);
    fclose(unit);
    mrsi.ref.fidOrig = dataTmp(1,:)' + 1i*dataTmp(2,:)';

    %--- init key spectral parameters ---
    mrsi.ref.sf     = 0;      % init
    mrsi.ref.sw_h   = 0;      % init
    mrsi.ref.nspecC = 0;      % init
   
    %--- load parameter file ---
    % note that dataPathTxt does not need to have a .txt extension
    dotInd = find(mrsi.ref.dataPathTxt=='.');
%     if isempty(dotInd)
%         parFilePath = [mrsi.ref.dataPathTxt '.par'];
%     else
%         parFilePath = [mrsi.ref.dataPathTxt(1:(dotInd(end)-1)) '.par'];
%     end
    % new standard extension of parameter file is .spx
    if isempty(dotInd)
        parFilePathPar = [mrsi.ref.dataPathTxt '.par'];
        parFilePathSpx = [mrsi.ref.dataPathTxt '.spx'];
    else
        parFilePathPar = [mrsi.ref.dataPathTxt(1:(dotInd(end)-1)) '.par'];
        parFilePathSpx = [mrsi.ref.dataPathTxt(1:(dotInd(end)-1)) '.spx'];
    end
    if SP2_CheckFileExistenceR(parFilePathSpx) || SP2_CheckFileExistenceR(parFilePathPar)
        % new spx format takes preference
        if SP2_CheckFileExistenceR(parFilePathSpx)
            fid = fopen(parFilePathSpx,'r');
        else
            fid = fopen(parFilePathPar,'r');
        end
        f_inspector       = 0;      % INSPECTOR-style parameter file
        f_rag             = 0;      % RAG-style parameter file
        if (fid > 0)
            while (~feof(fid))
                tline = fgetl(fid);
                if strncmp('sf ',tline,3)           % grid size assignment: cylinder geometry
                    [fake,sfStr]  = strtok(tline);
                    mrsi.ref.sf = str2double(sfStr);
                    f_inspector   = 1;
                elseif strncmp('sw_h ',tline,5)  
                    [fake,sw_hStr]  = strtok(tline);
                    mrsi.ref.sw_h = str2double(sw_hStr);
                    f_inspector     = 1; 
                elseif strncmp('nspecC ',tline,7)   
                    [fake,nspecCStr]  = strtok(tline);
                    mrsi.ref.nspecC = str2double(nspecCStr);
                    mrsi.ref.nspecCOrig = mrsi.ref.nspecC;
                    f_inspector       = 1;
                elseif strncmp('Field strength',tline,14)
                    [fake,sfStr]  = strtok(tline,'=');
                    [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                    mrsi.ref.sf = str2double(sfStr);
                    f_rag       = 1;
                elseif strncmp('Spectral width',tline,14)   
                    [fake,sw_hStr]  = strtok(tline,'=');
                    [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                    mrsi.ref.sw_h = str2double(sw_hStr)*1000;
                    f_rag       = 1;
                elseif strncmp('Acquisition points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    mrsi.ref.nspecC = str2double(nspecCStr(2:end));
                    mrsi.ref.nspecCOrig = mrsi.ref.nspecC;
                    f_rag       = 1;
                elseif strncmp('RF offset',tline,9)   
                    [fake,ppmCalibStr] = strtok(tline,'=');
                    [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
                    mrsi.ppmCalib      = str2double(ppmCalibStr);
                    f_rag              = 1;
                end
            end
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
        end
    
        %--- consistency check ---
        if f_inspector && f_rag
            fprintf('%s ->\nInconsisten parameter format (INSPECTOR vs. RAG) detected.\n',FCTNAME)
            return
        end

    %--- format of Robin's simulated, individual LCModel basis spectra ---    
    elseif SP2_CheckFileExistenceR([mrsi.ref.dataDir 'BasisSetParameters.txt'])
        fid = fopen([mrsi.ref.dataDir 'BasisSetParameters.txt'],'r');
        if (fid > 0)
            mrsi.ref.sf   = str2double(fgetl(fid));
            mrsi.ref.sw_h = 1000*str2double(fgetl(fid));
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
        end
        
        %--- info printout of simulation calibration frequency ---
        if SP2_CheckFileExistenceR([mrsi.ref.dataDir 'BasisRFOffset.txt'])
            fid = fopen([mrsi.ref.dataDir 'BasisRFOffset.txt'],'r');
            if (fid > 0)
                fprintf('LCModel parameter file found.\n')
                fprintf('Basis RF offset of simulated spectrum: %s ppm\n',fgetl(fid));
                fclose(fid);
            else
                fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
            end
        end
        
        %--- determined FID length directly from data set ---
        mrsi.ref.nspecC = length(mrsi.ref.fidOrig);        
        mrsi.ref.nspecCOrig = mrsi.ref.nspecC;
    else
        fprintf('%s ->\nNo parameter file found. Program aborted.\n',FCTNAME)
        return    
    end
    
    %--- consistency checks ---
    if mrsi.ref.sf==0 || mrsi.ref.sw_h==0 || mrsi.ref.nspecC==0
        fprintf('%s ->\nReading parameter file failed. Program aborted.\n',FCTNAME)
        return
    end
    if mrsi.ref.nspecC~=size(dataTmp,2)
        fprintf('%s ->\nIncosistent data dimension detected (%i~=%i).\nProgram aborted.\n',...
                FCTNAME,mrsi.ref.nspecC,size(dataTmp,2))
        return
    end
end
     
%--- derivation of secondary parameters ---
mrsi.ref.sw    = mrsi.ref.sw_h/mrsi.ref.sf;       % sweep width in [ppm]
mrsi.ref.dwell = 1/mrsi.ref.sw_h;                   % dwell time

%--- info string ---
if flag.mrsiDatFormat       % matlab format
    fprintf('\nSpectral data set 1 loaded from file\n%s\n',mrsi.ref.dataPathMat)
else
    fprintf('\nSpectral data set 1 loaded from file\n%s\n',mrsi.ref.dataPathTxt)
end
fprintf('larmor frequency: %.1f MHz\n',mrsi.ref.sf)
fprintf('sweep width:      %.1f Hz\n',mrsi.ref.sw_h)
fprintf('Complex points:   %.0f\n\n',mrsi.ref.nspecC)

%--- update success flag ---
f_done = 1;

