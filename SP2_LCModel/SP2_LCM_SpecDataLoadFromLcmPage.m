%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_SpecDataLoadFromLcmPage( f_import )
%% 
%%  Function to load spectral data (FID) from .mat file.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag fm

FCTNAME = 'SP2_LCM_SpecDataLoadFromLcmPage';


%--- init success flag ---
f_succ = 0;

%--- load data and parameters from file ---
if flag.lcmDataFormat==1        % matlab format
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(lcm.dataPathMat)
        return
    end

    %--- check file size >0 ---
    D = dir(lcm.dataPathMat);
    if D.bytes<1
        fprintf('%s:\nSelected data file appears to be empty. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- load data & parameters from file ---
    load(lcm.dataPathMat)

    %--- consistency check ---
    if ~exist('exptDat','var')
        fprintf('%s ->\nUnknown data format detected. Data loading aborted.\n',FCTNAME);
        return
    end

    %--- data & parameters assignment ---
    if isfield(exptDat,'fid')       % FID
        lcm.fidOrig = exptDat.fid;
    else
        fprintf('%s ->\n<fid> data not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'sf')        % larmor frequency in [MHz]
        lcm.sf = exptDat.sf;
%         lcm.sf = exptDat.sf/1e6;
    else
        fprintf('%s ->\nParameter <sf> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'sw_h')      % sweep width in [Hz]
        lcm.sw_h = exptDat.sw_h;
    else
        fprintf('%s ->\nParameter <sw_h> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'nspecC')    % number of complex data points
        lcm.nspecCOrig = exptDat.nspecC;
        lcm.nspecC     = exptDat.nspecC;
    else
        fprintf('%s ->\nParameter <nspecC> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
elseif flag.lcmDataFormat==2            % RAG text data and parameter files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(lcm.dataPathTxt)
        return
    end
    
    %--- load data file ---
    unit = fopen(lcm.dataPathTxt,'r');
    if unit==-1
        fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME);
        return
    end
    dataTmp = fscanf(unit,'%g		%g',[2 inf]);
    fclose(unit);
    lcm.fidOrig = dataTmp(1,:)' + 1i*dataTmp(2,:)';

    %--- init key spectral parameters ---
    lcm.sf     = 0;      % init
    lcm.sw_h   = 0;      % init
    lcm.nspecC = 0;      % init
    nspecCLowPrio     = 0;      % init
   
    %--- load parameter file ---
    % note that dataPathTxt does not need to have a .txt extension
    dotInd = find(lcm.dataPathTxt=='.');
%     if isempty(dotInd)
%         parFilePath = [lcm.dataPathTxt '.par'];
%     else
%         parFilePath = [lcm.dataPathTxt(1:(dotInd(end)-1)) '.par'];
%     end
    % new standard extension of parameter file is .spx
    if isempty(dotInd)
        parFilePathPar = [lcm.dataPathTxt '.par'];
        parFilePathSpx = [lcm.dataPathTxt '.spx'];
    else
        parFilePathPar = [lcm.dataPathTxt(1:(dotInd(end)-1)) '.par'];
        parFilePathSpx = [lcm.dataPathTxt(1:(dotInd(end)-1)) '.spx'];
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
                    lcm.sf = str2double(sfStr);
                    f_inspector   = 1;
                elseif strncmp('sw_h ',tline,5)  
                    [fake,sw_hStr]  = strtok(tline);
                    lcm.sw_h = str2double(sw_hStr);
                    f_inspector     = 1; 
                elseif strncmp('nspecC ',tline,7)   
                    [fake,nspecCStr]  = strtok(tline);
                    lcm.nspecC = str2double(nspecCStr);
                    lcm.nspecCOrig = lcm.nspecC;
                    f_inspector       = 1;
                elseif strncmp('Field strength',tline,14)
                    [fake,sfStr]  = strtok(tline,'=');
                    [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                    lcm.sf = str2double(sfStr);
                    f_rag       = 1;
                elseif strncmp('Spectral width',tline,14)   
                    [fake,sw_hStr]  = strtok(tline,'=');
                    [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                    lcm.sw_h = str2double(sw_hStr)*1000;
                    f_rag       = 1;
                elseif strncmp('Acquisition points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    lcm.nspecC = str2double(nspecCStr(2:end));
                    lcm.nspecCOrig = lcm.nspecC;
                    f_rag       = 1;
                elseif strncmp('Zerofilling points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    nspecCLowPrio = str2double(nspecCStr(2:end));
                    f_rag       = 1;
                elseif strncmp('RF offset',tline,9)   
                    [fake,ppmCalibStr] = strtok(tline,'=');
                    [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
                    lcm.ppmCalib      = str2double(ppmCalibStr);
                    f_rag              = 1;
                end
            end
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
        end
    
        %--- low priority assignment ---
        if lcm.nspecC==0 && nspecCLowPrio>0
            lcm.nspecC     = nspecCLowPrio;
            lcm.nspecCOrig = lcm.nspecC;
        end        
        
        %--- consistency check ---
        if f_inspector && f_rag
            fprintf('%s ->\nInconsisten parameter format (INSPECTOR vs. RAG) detected.\n',FCTNAME);
            return
        end

    %--- format of Robin's simulated, individual LCModel basis spectra ---    
    elseif SP2_CheckFileExistenceR([lcm.dataDir 'BasisSetParameters.txt'])
        fid = fopen([lcm.dataDir 'BasisSetParameters.txt'],'r');
        if (fid > 0)
            lcm.sf   = str2double(fgetl(fid));
            lcm.sw_h = 1000*str2double(fgetl(fid));
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
        end
        
        %--- info printout of simulation calibration frequency ---
        if SP2_CheckFileExistenceR([lcm.dataDir 'BasisRFOffset.txt'])
            fid = fopen([lcm.dataDir 'BasisRFOffset.txt'],'r');
            if (fid > 0)
                fprintf('LCModel parameter file found.\n');
                fprintf('Basis RF offset of simulated spectrum: %s ppm\n',fgetl(fid));
                fclose(fid);
            else
                fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
            end
        end
        
        %--- determined FID length directly from data set ---
        lcm.nspecC = length(lcm.fidOrig);        
        lcm.nspecCOrig = lcm.nspecC;
        
    %--- check for metabolite-specific parameter file, e.g. NAA.par for NAAH2 data set ---
    elseif (SP2_CheckFileExistenceR([lcm.dataPathTxt(1:end-2) '.par']) && ...        % H1..9
            strcmp(lcm.dataFileTxt(end-1),'H') && ...
            (strcmp(lcm.dataFileTxt(end),'1') || ...
             strcmp(lcm.dataFileTxt(end),'2') || ...
             strcmp(lcm.dataFileTxt(end),'3') || ...
             strcmp(lcm.dataFileTxt(end),'4') || ...
             strcmp(lcm.dataFileTxt(end),'5') || ...
             strcmp(lcm.dataFileTxt(end),'6') || ...
             strcmp(lcm.dataFileTxt(end),'7') || ...
             strcmp(lcm.dataFileTxt(end),'8') || ...
             strcmp(lcm.dataFileTxt(end),'9'))) || ...
            (SP2_CheckFileExistenceR([lcm.dataPathTxt(1:end-3) '.par']) && ...        % H10..19
            strcmp(lcm.dataFileTxt(end-2),'H') && ...
            (strcmp(lcm.dataFileTxt(end-1:end),'10') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'11') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'12') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'13') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'14') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'15') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'16') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'17') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'18') || ...
             strcmp(lcm.dataFileTxt(end-1:end),'19'))) || ...
            (SP2_CheckFileExistenceR([lcm.dataPathTxt(1:end-1) '.par']) && ...       % P / N
                strcmp(lcm.dataPathTxt(end),'P') || ...          % P
                strcmp(lcm.dataPathTxt(end),'N'))                % N
            
        %--- H/N/P handling ---
        if SP2_CheckFileExistenceR([lcm.dataPathTxt(1:end-2) '.par'])                % H1..9
            parFilePath = [lcm.dataPathTxt(1:end-2) '.par'];
        elseif SP2_CheckFileExistenceR([lcm.dataPathTxt(1:end-3) '.par'])            % H10..19
            parFilePath = [lcm.dataPathTxt(1:end-3) '.par'];
        else                                                                                % N or P
            parFilePath = [lcm.dataPathTxt(1:end-1) '.par'];
        end
        
        %--- open parameter file ---
        fid = fopen(parFilePath,'r');
        if (fid > 0)
            while (~feof(fid))
                tline = fgetl(fid);
                if strncmp('Field strength',tline,14)
                    [fake,sfStr]  = strtok(tline,'=');
                    [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                    lcm.sf = str2double(sfStr);
                elseif strncmp('Spectral width',tline,14)   
                    [fake,sw_hStr]  = strtok(tline,'=');
                    [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                    lcm.sw_h = str2double(sw_hStr)*1000;
                elseif strncmp('Acquisition points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    lcm.nspecC = str2double(nspecCStr(2:end));
                    lcm.nspecCOrig = lcm.nspecC;
                elseif strncmp('RF offset',tline,9)   
                    [fake,ppmCalibStr] = strtok(tline,'=');
                    [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
                    lcm.ppmCalib      = str2double(ppmCalibStr);
                end
            end
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',...
                    FCTNAME,parFilePath);
        end
    else
        fprintf('%s ->\nNo parameter file found. Direct assignment required...\n',FCTNAME);
        if ~isfield(lcm,'sf')
            lcm.sf     = 0;
        end
        if ~isfield(lcm,'sw_h')
            lcm.sw_h   = 0;
        end
        if ~isfield(lcm,'nspecC')
            lcm.nspecC = 0;
        end
        SP2_LCM_SpecParsDialogMain(1)
        waitfor(fm.lcm.dialog1.fig)
    end
    
    %--- consistency checks ---
    if lcm.sf==0 || lcm.sw_h==0 || lcm.nspecC==0 || lcm.nspecCOrig==0
        fprintf('%s ->\nReading parameter file failed. Program aborted.\n',FCTNAME);
        return
    end
    if lcm.nspecC~=size(dataTmp,2)
        fprintf('%s ->\nIncosistent data dimension detected:\n(parameter file) %i ~= %i (FID dimension)\nProgram aborted.\n',...
                FCTNAME,lcm.nspecC,size(dataTmp,2))
        return
    end
elseif flag.lcmDataFormat==3           % all moeties of a metabolite defined by its .par file (core name)
    %--- check parameter file existence ---
    if ~SP2_CheckFileExistenceR(lcm.dataPathPar)
        return
    end
    
    %--- read parameter file ---
    fid = fopen(lcm.dataPathPar,'r');
    if (fid > 0)
        while (~feof(fid))
            tline = fgetl(fid);
            if strncmp('Field strength',tline,14)
                [fake,sfStr]  = strtok(tline,'=');
                [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                lcm.sf = str2double(sfStr);
            elseif strncmp('Spectral width',tline,14)   
                [fake,sw_hStr]  = strtok(tline,'=');
                [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                lcm.sw_h = str2double(sw_hStr)*1000;
            elseif strncmp('Acquisition points',tline,18)   
                [fake,nspecCStr]  = strtok(tline,'=');
                lcm.nspecC = str2double(nspecCStr(2:end));
                lcm.nspecCOrig = lcm.nspecC;
            elseif strncmp('RF offset',tline,9)   
                [fake,ppmCalibStr] = strtok(tline,'=');
                [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
                lcm.ppmCalib      = str2double(ppmCalibStr);
            end
        end
        fclose(fid);
    else
        fprintf('%s ->\n<%s> exists but can not be opened...\n',...
                FCTNAME,lcm.dataPathPar);
    end
    
    %--- extract key string ---
    metabStr  = lcm.dataFilePar(1:end-4);
    metabStrN = length(metabStr);
    
    %--- moiety file handling ---
    fStructOrig = dir(lcm.dataDir);             % retrieve directory files
    fStruct     = fStructOrig(3:end);           % remove . and ..
    fStructN    = size(fStruct,1);              % number of files
    moieties    = {};                           % metabolite moiety cell
    moietiesN   = 0;                            % number of metabolite moieties
    for fCnt = 1:fStructN
        % note that .txt are potentially included
        if strcmp(metabStr,'NAA')
            if strncmp(metabStr,fStruct(fCnt).name,metabStrN) && ...
               isempty(findstr(fStruct(fCnt).name,'.par')) && ...
               isempty(findstr(fStruct(fCnt).name,'.mat')) && ...
               isempty(strfind(fStruct(fCnt).name,'NAAG'))
                moietiesN = moietiesN + 1;
                moieties{moietiesN} = fStruct(fCnt).name;
            end    
        else
            if strncmp(metabStr,fStruct(fCnt).name,metabStrN) && ...
               isempty(findstr(fStruct(fCnt).name,'.par')) && ...
               isempty(findstr(fStruct(fCnt).name,'.mat'))
                moietiesN = moietiesN + 1;
                moieties{moietiesN} = fStruct(fCnt).name;
            end    
        end
    end
    
    %--- info printout ---
    fprintf('Moieties associated with <%s>:\n',lcm.dataFilePar);
    for mCnt = 1:moietiesN
        fprintf('%2.0f: %s\n',mCnt,moieties{mCnt}) 
    end 
    
    %--- load and add individual moieties ---
    lcm.fidOrig = zeros(lcm.nspecC,1);
    for mCnt = 1:moietiesN
        %--- load data file ---
        unit = fopen([lcm.dataDir moieties{mCnt}],'r');
        if unit==-1
            fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME);
            return
        end
        dataTmp = fscanf(unit,'%g		%g',[2 inf]);
        fclose(unit);
        lcm.fidOrig = lcm.fidOrig + dataTmp(1,:)' + 1i*dataTmp(2,:)'; 
    end
elseif flag.lcmDataFormat==4                        % LCModel .raw files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(lcm.dataPathRaw)
        return
    end
    
    %--- open data file ---
    unit = fopen(lcm.dataPathRaw,'r');
    if unit==-1
        fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME);
        return
    end
    
    %--- read parameter header ---
    if flag.verbose
        fprintf('File header:\n');
    end
    tline = '';
    f_hzpppm = 0;       % init
    f_sw_h   = 0;       % init
    while isempty(strfind(tline,'$END'))
        tline = fgetl(unit);
        if strfind(tline,'HZPPPM')           % grid size assignment: cylinder geometry
            [fake,sfStr]  = strtok(tline);
            lcm.sf = str2double(sfStr);
            f_hzpppm = 1;
        elseif strfind(tline,'DELTAT')  
            [fake,deltatStr] = strtok(tline);
            lcm.sw_h  = 1/str2double(deltatStr);
            f_sw_h = 1;
        end
        if flag.verbose
            fprintf('%s\n',tline);
        end
    end
    fprintf('\n');
    
    %--- read data ---
    dataTmp = fscanf(unit,'%g',[2 inf]);
    fclose(unit);
    lcm.fidOrig    = dataTmp(1,:)' - 1i*dataTmp(2,:)';
    % lcm.fidOrig(1) = lcm.fidOrig(1)/2;


    %--- init key spectral parameters ---
    if f_hzpppm
        fprintf('Larmor frequency read from file: %.1f MHz\n',lcm.sf);
    end
    if f_sw_h
        fprintf('Bandwidth read from file: %.1f Hz\n',lcm.sw_h);
    end
        
    %--- ask for parameters if not serial import of basis functions ---
    if ~f_import
        if ~f_hzpppm || ~f_sw_h
            fprintf('%s ->\nNo parameter file found. Direct assignment required...\n',FCTNAME);
            if ~isfield(lcm,'sf')
                lcm.sf     = 0;
            end
            if ~isfield(lcm,'sw_h')
                lcm.sw_h   = 0;
            end
            SP2_LCM_SpecParsDialogMain(0)
            waitfor(fm.lcm.dialog1.fig)
        end
    end
    
    %--- determined FID length directly from data set ---
    lcm.nspecC = length(lcm.fidOrig);        
    lcm.nspecCOrig = lcm.nspecC;
else                                            % JMRUI format
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(lcm.dataPathJmrui)
        return
    end

    %--- file handling ---
    [fid, msg] = fopen(lcm.dataPathJmrui,'rb','ieee-be');             % PC
    if fid <= 0
        fprintf('%s ->\nOpening %s failed;\n%s\n\n',FCTNAME,lcm.dataPathJmrui,msg);
        return
    end

    %--- read header and data from file ---
    [raw,nRead] = fread(fid,inf,'double');
    % data(1)  = raw(1);          % type of signal, 1: FID, 2: simulated spectrum, 3: simulated FID, 4: peak table
    % data(2)  = raw(2);          % number of points
    % data(3)  = raw(3);          % sampling interval [ms]
    % data(4)  = raw(4);          % begin time
    % data(5)  = raw(5);          % zero-order phase
    % data(6)  = raw(6);          % transmitter frequency
    % data(7)  = raw(7);          % magnetic field
    % data(8)  = raw(8);          % type of nucleus
    % data(9)  = raw(9);          % reference frequency [Hz]
    % data(10) = raw(10);         % reference frequency [ppm]
    % data(11) = raw(11);         % 0: FID, 
    % data(12) = raw(12);         % apodization
    % data(13) = raw(13);         % ZF

    %--- data conversion ---
    lcm.nspecC     = raw(2);
    lcm.nspecCOrig = lcm.nspecC;
    lcm.sf         = raw(6)/1e6;
    lcm.sw_h       = 1/(raw(3)/1e3);
    lcm.sw         = lcm.sw_h / lcm.sf;
    hLen           = 64;          % header length, 512 bytes at 8 bytes/double, 64 header entries total
    lcm.fidOrig    = -raw(hLen+1:2:hLen+2*lcm.nspecC) - 1i*raw(hLen+2:2:hLen+2*lcm.nspecC);
    lcm.ppmCalib   = raw(10);
end
     
%--- derivation of secondary parameters ---
lcm.fid   = lcm.fidOrig;            % init FID
lcm.sw    = lcm.sw_h/lcm.sf;        % sweep width in [ppm]
lcm.dwell = 1/lcm.sw_h;             % dwell time

%--- info string ---
if flag.lcmDataFormat==1           % matlab format
    fprintf('\nSpectral data set loaded from file\n%s\n',lcm.dataPathMat);
elseif flag.lcmDataFormat==2       % text format
    fprintf('\nSpectral data set loaded from file\n%s\n',lcm.dataPathTxt);
elseif flag.lcmDataFormat==3       % (.par) metabolite moieties
    fprintf('\nSpectral data set assembled from <%s> moieties\n',metabStr);
elseif flag.lcmDataFormat==4       % LCModel format
    fprintf('\nSpectral data set loaded from file\n<%s>\n',lcm.dataPathRaw);
else                               % JMRUI
    fprintf('\nSpectral data set loaded from file\n<%s>\n',lcm.dataPathJmrui);
end
fprintf('larmor frequency: %.1f MHz\n',lcm.sf);
fprintf('sweep width:      %.1f Hz\n',lcm.sw_h);
fprintf('complex points:   %.0f\n',lcm.nspecC);
fprintf('ppm calibration:  %.3f ppm (global)\n\n',lcm.ppmCalib);

%--- update success flag ---
f_succ = 1;

