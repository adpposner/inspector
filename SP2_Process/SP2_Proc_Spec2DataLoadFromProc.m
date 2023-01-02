%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_Spec2DataLoadFromProc
%% 
%%  Function to load spectral data (FID) from .mat file.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag fm

FCTNAME = 'SP2_Proc_Spec2DataLoadFromProc';


%--- init success flag ---
f_done = 0;

%--- load data and parameters from file ---
if flag.procDataFormat==1        % matlab format
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec2.dataPathMat)
        return
    end

    %--- load data & parameters from file ---
    load(proc.spec2.dataPathMat)

    %--- consistency check ---
    if ~exist('exptDat','var')
        fprintf('%s ->\nUnknown data format detected. Data loading aborted.\n',FCTNAME);
        return
    end

    %--- data & parameters assignment ---
    if isfield(exptDat,'fid')       % FID
        proc.spec2.fidOrig = exptDat.fid;
    else
        fprintf('%s ->\n<fid> data not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'sf')        % larmor frequency in [MHz]
        proc.spec2.sf = exptDat.sf;
%         proc.spec2.sf = exptDat.sf/1e6;
    else
        fprintf('%s ->\nParameter <sf> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'sw_h')      % sweep width in [Hz]
        proc.spec2.sw_h = exptDat.sw_h;
    else
        fprintf('%s ->\nParameter <sw_h> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'nspecC')    % number of complex data points
        proc.spec2.nspecCOrig = exptDat.nspecC;
        proc.spec2.nspecC     = exptDat.nspecC;
    else
        fprintf('%s ->\nParameter <nspecC> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
elseif flag.procDataFormat==2            % RAG text data and parameter files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec2.dataPathTxt)
        return
    end
    
    %--- load data file ---
    unit = fopen(proc.spec2.dataPathTxt,'r');
    if unit==-1
        fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME);
        return
    end
    dataTmp = fscanf(unit,'%g		%g',[2 inf]);
    fclose(unit);
    proc.spec2.fidOrig = dataTmp(1,:)' + 1i*dataTmp(2,:)';

    %--- init key spectral parameters ---
    proc.spec2.sf     = 0;      % init
    proc.spec2.sw_h   = 0;      % init
    proc.spec2.nspecC = 0;      % init
    nspecCLowPrio     = 0;      % init
   
    %--- load parameter file ---
    % note that dataPathTxt does not need to have a .txt extension
    dotInd = find(proc.spec2.dataPathTxt=='.');
%     if isempty(dotInd)
%         parFilePath = [proc.spec2.dataPathTxt '.par'];
%     else
%         parFilePath = [proc.spec2.dataPathTxt(1:(dotInd(end)-1)) '.par'];
%     end
    % new standard extension of parameter file is .spx
    if isempty(dotInd)
        parFilePathPar = [proc.spec2.dataPathTxt '.par'];
        parFilePathSpx = [proc.spec2.dataPathTxt '.spx'];
    else
        parFilePathPar = [proc.spec2.dataPathTxt(1:(dotInd(end)-1)) '.par'];
        parFilePathSpx = [proc.spec2.dataPathTxt(1:(dotInd(end)-1)) '.spx'];
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
                    proc.spec2.sf = str2double(sfStr);
                    f_inspector   = 1;
                elseif strncmp('sw_h ',tline,5)  
                    [fake,sw_hStr]  = strtok(tline);
                    proc.spec2.sw_h = str2double(sw_hStr);
                    f_inspector     = 1; 
                elseif strncmp('nspecC ',tline,7)   
                    [fake,nspecCStr]  = strtok(tline);
                    proc.spec2.nspecC = str2double(nspecCStr);
                    proc.spec2.nspecCOrig = proc.spec2.nspecC;
                    f_inspector       = 1;
                elseif strncmp('Field strength',tline,14)
                    [fake,sfStr]  = strtok(tline,'=');
                    [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                    proc.spec2.sf = str2double(sfStr);
                    f_rag       = 1;
                elseif strncmp('Spectral width',tline,14)   
                    [fake,sw_hStr]  = strtok(tline,'=');
                    [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                    proc.spec2.sw_h = str2double(sw_hStr)*1000;
                    f_rag       = 1;
                elseif strncmp('Acquisition points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    proc.spec2.nspecC = str2double(nspecCStr(2:end));
                    proc.spec2.nspecCOrig = proc.spec2.nspecC;
                    f_rag       = 1;
                elseif strncmp('Zerofilling points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    nspecCLowPrio = str2double(nspecCStr(2:end));
                    f_rag       = 1;
                elseif strncmp('RF offset',tline,9)   
                    [fake,ppmCalibStr] = strtok(tline,'=');
                    [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
                    proc.ppmCalib      = str2double(ppmCalibStr);
                    f_rag              = 1;
                end
            end
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
        end
        
        %--- low priority assignment ---
        if proc.spec2.nspecC==0 && nspecCLowPrio>0
            proc.spec2.nspecC     = nspecCLowPrio;
            proc.spec2.nspecCOrig = proc.spec2.nspecC;
        end        
        
        %--- consistency check ---
        if f_inspector && f_rag
            fprintf('%s ->\nInconsisten parameter format (INSPECTOR vs. RAG) detected.\n',FCTNAME);
            return
        end

    %--- format of Robin's simulated, individual LCModel basis spectra ---    
    elseif SP2_CheckFileExistenceR([proc.spec2.dataDir 'BasisSetParameters.txt'])
        fid = fopen([proc.spec2.dataDir 'BasisSetParameters.txt'],'r');
        if (fid > 0)
            proc.spec2.sf   = str2double(fgetl(fid));
            proc.spec2.sw_h = 1000*str2double(fgetl(fid));
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
        end
        
        %--- info printout of simulation calibration frequency ---
        if SP2_CheckFileExistenceR([proc.spec2.dataDir 'BasisRFOffset.txt'])
            fid = fopen([proc.spec2.dataDir 'BasisRFOffset.txt'],'r');
            if (fid > 0)
                fprintf('LCModel parameter file found.\n');
                fprintf('Basis RF offset of simulated spectrum: %s ppm\n',fgetl(fid));
                fclose(fid);
            else
                fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
            end
        end
        
        %--- determined FID length directly from data set ---
        proc.spec2.nspecC = length(proc.spec2.fidOrig);        
        proc.spec2.nspecCOrig = proc.spec2.nspecC;
        
    %--- check for metabolite-specific parameter file, e.g. NAA.par for NAAH2 data set ---
    elseif (SP2_CheckFileExistenceR([proc.spec2.dataPathTxt(1:end-2) '.par']) && ...        % H1..9
            strcmp(proc.spec2.dataFileTxt(end-1),'H') && ...
            (strcmp(proc.spec2.dataFileTxt(end),'1') || ...
             strcmp(proc.spec2.dataFileTxt(end),'2') || ...
             strcmp(proc.spec2.dataFileTxt(end),'3') || ...
             strcmp(proc.spec2.dataFileTxt(end),'4') || ...
             strcmp(proc.spec2.dataFileTxt(end),'5') || ...
             strcmp(proc.spec2.dataFileTxt(end),'6') || ...
             strcmp(proc.spec2.dataFileTxt(end),'7') || ...
             strcmp(proc.spec2.dataFileTxt(end),'8') || ...
             strcmp(proc.spec2.dataFileTxt(end),'9'))) || ...
            (SP2_CheckFileExistenceR([proc.spec2.dataPathTxt(1:end-3) '.par']) && ...        % H10..19
            strcmp(proc.spec2.dataFileTxt(end-2),'H') && ...
            (strcmp(proc.spec2.dataFileTxt(end-1:end),'10') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'11') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'12') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'13') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'14') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'15') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'16') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'17') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'18') || ...
             strcmp(proc.spec2.dataFileTxt(end-1:end),'19'))) || ...
            (SP2_CheckFileExistenceR([proc.spec2.dataPathTxt(1:end-1) '.par']) && ...       % P / N
                strcmp(proc.spec2.dataPathTxt(end),'P') || ...          % P
                strcmp(proc.spec2.dataPathTxt(end),'N'))                % N
            
        %--- H/N/P handling ---
        if SP2_CheckFileExistenceR([proc.spec2.dataPathTxt(1:end-2) '.par'])                % H1..9
            parFilePath = [proc.spec2.dataPathTxt(1:end-2) '.par'];
        elseif SP2_CheckFileExistenceR([proc.spec2.dataPathTxt(1:end-3) '.par'])            % H10..19
            parFilePath = [proc.spec2.dataPathTxt(1:end-3) '.par'];
        else                                                                                % N or P
            parFilePath = [proc.spec2.dataPathTxt(1:end-1) '.par'];
        end
        
        %--- open parameter file ---
        fid = fopen(parFilePath,'r');
        if (fid > 0)
            while (~feof(fid))
                tline = fgetl(fid);
                if strncmp('Field strength',tline,14)
                    [fake,sfStr]  = strtok(tline,'=');
                    [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                    proc.spec2.sf = str2double(sfStr);
                elseif strncmp('Spectral width',tline,14)   
                    [fake,sw_hStr]  = strtok(tline,'=');
                    [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                    proc.spec2.sw_h = str2double(sw_hStr)*1000;
                elseif strncmp('Acquisition points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    proc.spec2.nspecC = str2double(nspecCStr(2:end));
                    proc.spec2.nspecCOrig = proc.spec2.nspecC;
                elseif strncmp('RF offset',tline,9)   
                    [fake,ppmCalibStr] = strtok(tline,'=');
                    [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
                    proc.ppmCalib      = str2double(ppmCalibStr);
                end
            end
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',...
                    FCTNAME,parFilePath);
        end
    else
        fprintf('%s ->\nNo parameter file found. Direct assignment required...\n',FCTNAME);
        SP2_Proc_Spec2ParsDialogMain(1)
        if ~isfield(proc.spec2,'sf')
            proc.spec2.sf     = 0;
        end
        if ~isfield(proc.spec2,'sw_h')
            proc.spec2.sw_h   = 0;
        end
        if ~isfield(proc.spec2,'nspecC')
            proc.spec2.nspecC = 0;
        end
        waitfor(fm.proc.dialog2.fig)
    end
    
    %--- consistency checks ---
    if proc.spec2.sf==0 || proc.spec2.sw_h==0 || proc.spec2.nspecC==0 || proc.spec2.nspecCOrig==0
        fprintf('%s ->\nReading parameter file failed. Program aborted.\n',FCTNAME);
        return
    end
    if proc.spec2.nspecC~=size(dataTmp,2)
        fprintf('%s ->\nIncosistent data dimension detected (%i~=%i).\nProgram aborted.\n',...
                FCTNAME,proc.spec2.nspecC,size(dataTmp,2))
        return
    end
elseif flag.procDataFormat==3            % all moeties of a metabolite defined by its .par file (core name)
    %--- check parameter file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec2.dataPathPar)
        return
    end
    
    %--- read parameter file ---
    fid = fopen(proc.spec2.dataPathPar,'r');
    if (fid > 0)
        while (~feof(fid))
            tline = fgetl(fid);
            if strncmp('Field strength',tline,14)
                [fake,sfStr]  = strtok(tline,'=');
                [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                proc.spec2.sf = str2double(sfStr);
            elseif strncmp('Spectral width',tline,14)   
                [fake,sw_hStr]  = strtok(tline,'=');
                [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                proc.spec2.sw_h = str2double(sw_hStr)*1000;
            elseif strncmp('Acquisition points',tline,18)   
                [fake,nspecCStr]  = strtok(tline,'=');
                proc.spec2.nspecC = str2double(nspecCStr(2:end));
                proc.spec2.nspecCOrig = proc.spec2.nspecC;
            elseif strncmp('RF offset',tline,9)   
                [fake,ppmCalibStr] = strtok(tline,'=');
                [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
                proc.ppmCalib      = str2double(ppmCalibStr);
            end
        end
        fclose(fid);
    else
        fprintf('%s ->\n<%s> exists but can not be opened...\n',...
                FCTNAME,proc.spec2.dataPathPar);
    end
    
    %--- extract key string ---
    metabStr  = proc.spec2.dataFilePar(1:end-4);
    metabStrN = length(metabStr);
    
    %--- moeity file handling ---
    fStructOrig = dir(proc.spec2.dataDir);      % retrieve directory files
    fStruct     = fStructOrig(3:end);           % remove . and ..
    fStructN    = size(fStruct,1);              % number of files
    moeities    = {};                           % metabolite moeity cell
    moeitiesN   = 0;                            % number of metabolite moeities
    for fCnt = 1:fStructN
        if strcmp(metabStr,'NAA')
            % note that .txt are potentially included
            if strncmp(metabStr,fStruct(fCnt).name,metabStrN) && ...
               isempty(findstr(fStruct(fCnt).name,'.par')) && ...
               isempty(findstr(fStruct(fCnt).name,'.mat')) && ...
               isempty(strfind(fStruct(fCnt).name,'NAAG'))
                moeitiesN = moeitiesN + 1;
                moeities{moeitiesN} = fStruct(fCnt).name;
            end    
        else
            if strncmp(metabStr,fStruct(fCnt).name,metabStrN) && ...
               isempty(findstr(fStruct(fCnt).name,'.par')) && ...
               isempty(findstr(fStruct(fCnt).name,'.mat'))
                moeitiesN = moeitiesN + 1;
                moeities{moeitiesN} = fStruct(fCnt).name;
            end    
        end
    end
    
    %--- info printout ---
    fprintf('Moeities associated with <%s>:\n',proc.spec2.dataFilePar);
    for mCnt = 1:moeitiesN
        fprintf('%2.0f: %s\n',mCnt,moeities{mCnt}) 
    end 
    
    %--- load and add individual moeities ---
    proc.spec2.fidOrig = zeros(proc.spec2.nspecC,1);
    for mCnt = 1:moeitiesN
        %--- load data file ---
        unit = fopen([proc.spec2.dataDir moeities{mCnt}],'r');
        if unit==-1
            fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME);
            return
        end
        dataTmp = fscanf(unit,'%g		%g',[2 inf]);
        fclose(unit);
        proc.spec2.fidOrig = proc.spec2.fidOrig + dataTmp(1,:)' + 1i*dataTmp(2,:)'; 
    end
elseif flag.procDataFormat==4       % LCModel .raw data files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec2.dataPathRaw)
        return
    end
    
    %--- open data file ---
    unit = fopen(proc.spec2.dataPathRaw,'r');
    if unit==-1
        fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME);
        return
    end
    
    %--- read parameter header ---
    fprintf('File header:\n');
    tline = '';
    f_hzpppm = 0;       % init
    f_sw_h   = 0;       % init
    while isempty(strfind(tline,'$END'))
        tline = fgetl(unit);
        if strfind(tline,'HZPPPM')           % grid size assignment: cylinder geometry
            [fake,sfStr]  = strtok(tline);
            proc.spec2.sf = str2double(sfStr);
            f_hzpppm = 1;
        elseif strfind(tline,'DELTAT')  
            [fake,deltatStr] = strtok(tline);
            proc.spec2.sw_h  = 1/str2double(deltatStr);
            f_sw_h = 1;
        end
        if flag.debug
            fprintf('%s\n',tline);
        end
    end
    fprintf('\n');
    
    %--- read data ---
    dataTmp = fscanf(unit,'%g',[2 inf]);
    fclose(unit);
    proc.spec2.fidOrig    = dataTmp(1,:)' - 1i*dataTmp(2,:)';
    % proc.spec2.fidOrig(1) = proc.spec2.fidOrig(1)/2;

    %--- init key spectral parameters ---
    if f_hzpppm
        fprintf('Larmor frequency read from file: %.1f MHz\n',proc.spec2.sf);
%     else
%         proc.spec2.sf     = 298.1;      % init
%         proc.spec2.sf     = 123.3;       % init
%                 fprintf('\nWARNING: NO LARMOR FREQUENCY FOUND, ASSIGNED AS %.1f MHZ\n\n',proc.spec2.sf);
    end
    if f_sw_h
        fprintf('Bandwidth read from file: %.1f Hz\n',proc.spec2.sw_h);
%     else
%         proc.spec2.sw_h   = 5000;       % init
%         proc.spec2.sw_h   = 2800.3;       % init
%         fprintf('\nWARNING: NO BANDWIDTH FOUND, ASSIGNED AS %.1f HZ\n\n',proc.spec2.sw_h);
    end
    
    %--- ask for parameters ---
    if ~f_hzpppm || ~f_sw_h
        fprintf('%s ->\nNo parameter file found. Direct assignment required...\n',FCTNAME);
        if ~isfield(proc.spec2,'sf')
            proc.spec2.sf     = 0;
        end
        if ~isfield(proc.spec2,'sw_h')
            proc.spec2.sw_h   = 0;
        end
        SP2_Proc_Spec2ParsDialogMain(0)
        waitfor(fm.proc.dialog2.fig)
    end
    
    %--- determined FID length directly from data set ---
    proc.spec2.nspecC = length(proc.spec2.fidOrig);        
    proc.spec2.nspecCOrig = proc.spec2.nspecC;
else                                % LCModel .coord result/output files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec2.dataPathCoord)
        return
    end
    
    %--- load COORD file ---
    [coord, f_succ] = SP2_Proc_PlcmReadCoord(proc.spec2.dataPathCoord);
    if ~f_succ
        return
    end
    
    %--- format COORD content ---
    [plcm, f_succ] = SP2_Proc_PlcmFormatCoord( coord );
    if ~f_succ
        return
    end
    
    %--- metabolite summation ---
    metabSum = zeros(coord.ndata,1);                    % init metabolite sum
    for mCnt = 1:plcm.nconc                             % all metabolites
        if isempty(strfind(coord.metab{mCnt},'+'))      % non-combined
            metabSum = metabSum + plcm.diff{mCnt};
        end
    end

    %--- init export structure ---
    % apparently LCModel applies zero-filling to 8k when 4k are fed in
    exptDat.sf     = coord.hzpppm;
    exptDat.sw_h   = 1/coord.deltat;
    exptDat.sw     = exptDat.sw_h / exptDat.sf;
    exptDat.nspecC = coord.ndata*exptDat.sw/(coord.ppmst-coord.ppmend);
    [exptDat.nspecC,nThPower] = SP2_RoundToPowerOfN(exptDat.nspecC,2);
    exptDat.spec   = complex(zeros(exptDat.nspecC,1));
        
    %--- ppm extraction for spectrum synthesis ---
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(coord.ppmend,coord.ppmst,proc.ppmCalib,...
                                                                    exptDat.sw,real(exptDat.spec));
                                                                
    %--- consistency check ---
    if maxI-minI+1~=coord.ndata
        %--- info printout ---
        fprintf('\nWARNING:\nDimension mismatch: COORD %.0f ~= SPX %.0f.\n\n',maxI-minI+1,coord.ndata);
        
        %--- adopt data dimension (not ideal!) ---
        maxI = minI + coord.ndata - 1;
    end                 
        
    %--- create result folder ---
    coordDirName = [proc.spec2.dataFileCoord(1:end-6) '_COORD'];
    coordDirPath = [proc.spec2.dataDir coordDirName '\'];
    [f_succ,msg,msgId] = mkdir(proc.spec2.dataDir,coordDirName);
    if ~f_succ
        fprintf('%s -> Creation of COORD directory failed. Program aborted.\n%s\n\n',FCTNAME,msg);
        return
    end
    
    %--- save metabolites to separate files ---
    for mCnt = 1:2*coord.nconc+4
        %--- synthesis of imaginary part ---
        if mCnt==2*coord.nconc+1      % orig
            realSpec = flipdim(plcm.orig,1);
        elseif mCnt==2*coord.nconc+2        % fit
            realSpec = flipdim(plcm.fit,1);
        elseif mCnt==2*coord.nconc+3        % baseline
            realSpec = flipdim(plcm.basel,1);
        elseif mCnt==2*coord.nconc+4        % metabolite sum
            realSpec = flipdim(metabSum,1);
        elseif mCnt<coord.nconc+1           % individual metabolites, 1st run: metab alone
            realSpec = flipdim(plcm.diff{mCnt},1);
        else        % mCnt>coord.nconc & mCnt<=2*coord.nconc, individual metabolites, 2nd run: metab + base
            realSpec = flipdim(plcm.data{mCnt-coord.nconc},1);
        end
        imagSpec = 0*realSpec;
%         imagSpec = plcm.diff{mCnt}*exp(1i*pi/2);        
        
        %--- data assignment ---
        exptDat.spec(minI:maxI) = realSpec + 1i*imagSpec;
        
        %--- FID creation ---
        exptDat.fid = ifft(ifftshift(exptDat.spec,1),[],1);        
        
        %--- data export to file ---
        if mCnt==2*coord.nconc+1      % orig
            metabPath = [coordDirPath proc.spec2.dataFileCoord(1:end-6) '_orig.mat'];
        elseif mCnt==2*coord.nconc+2        % fit
            metabPath = [coordDirPath proc.spec2.dataFileCoord(1:end-6) '_fit.mat'];
        elseif mCnt==2*coord.nconc+3        % baseline
            metabPath = [coordDirPath proc.spec2.dataFileCoord(1:end-6) '_base.mat'];
        elseif mCnt==2*coord.nconc+4        % metabolite sum
            metabPath = [coordDirPath proc.spec2.dataFileCoord(1:end-6) '_sum_plusBase.mat'];
        elseif mCnt<coord.nconc+1           % individual metabolites, 1st run: metab alone
            metabPath = [coordDirPath proc.spec2.dataFileCoord(1:end-6) '_' sprintf('%s',coord.metab{mCnt}) '.mat'];
        else        % mCnt>coord.nconc & mCnt<=2*coord.nconc, individual metabolites, 2nd run: metab + base
            metabPath = [coordDirPath proc.spec2.dataFileCoord(1:end-6) '_' sprintf('%s',coord.metab{mCnt-coord.nconc}) '_plusBase.mat'];
        end
        save(metabPath,'exptDat')
        fprintf('%s data written to file\n',metabPath);
    end
    
    %--- copy basic parameters to spec1 (fake init) ---
    proc.spec2.fid        = exptDat.fid;
    proc.spec2.fidOrig    = exptDat.fid;
    proc.spec2.sw_h       = exptDat.sw_h;
    proc.spec2.sf         = exptDat.sf;
    proc.spec2.nspecC     = exptDat.nspecC;
    proc.spec2.nspecCOrig = exptDat.nspecC;
end
     
%--- derivation of secondary parameters ---
proc.spec2.sw    = proc.spec2.sw_h/proc.spec2.sf;       % sweep width in [ppm]
proc.spec2.dwell = 1/proc.spec2.sw_h;                   % dwell time

%--- info string ---
if flag.procDataFormat==1            % matlab format
    fprintf('\nSpectral data set 2 loaded from file\n%s\n',proc.spec2.dataPathMat);
elseif flag.procDataFormat==2        % text format
    fprintf('\nSpectral data set 2 loaded from file\n%s\n',proc.spec2.dataPathTxt);
elseif flag.procDataFormat==3        % (.par) metabolite moeities
    fprintf('\nSpectral data set 2 assembled from <%s> moeities\n',metabStr);
elseif flag.procDataFormat==4       % LCModel (.raw) format
    fprintf('\nSpectral data set 1 loaded from file\n<%s>\n',proc.spec2.dataPathRaw);
else                                % LCModel (.coord) format
    fprintf('\nConversion of COORD file to individual result FIDs completed.\n\n');
end
fprintf('larmor frequency: %.1f MHz\n',proc.spec2.sf);
fprintf('sweep width:      %.1f Hz\n',proc.spec2.sw_h);
fprintf('complex points:   %.0f\n',proc.spec2.nspecC);
fprintf('ppm calibration:  %.3f ppm (global loggingfile)\n\n',proc.ppmCalib);

%--- update success flag ---
f_done = 1;

