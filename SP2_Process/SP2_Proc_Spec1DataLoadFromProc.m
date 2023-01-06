%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_Spec1DataLoadFromProc
%% 
%%  Function to load spectral data (FID) from .mat file.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag fm

FCTNAME = 'SP2_Proc_Spec1DataLoadFromProc';


%--- init success flag ---
f_succ = 0;

%--- load data and parameters from file ---
if flag.procDataFormat==1        % matlab format
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec1.dataPathMat)
        return
    end

    %--- load data & parameters from file ---
    load(proc.spec1.dataPathMat)

    %--- consistency check ---
    if ~exist('exptDat','var')
        fprintf('%s ->\nUnknown data format detected. Data loading aborted.\n',FCTNAME);
        return
    end

    %--- data & parameters assignment ---
    if isfield(exptDat,'fid')       % FID
        proc.spec1.fidOrig = exptDat.fid;
    else
        fprintf('%s ->\n<fid> data not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'sf')        % larmor frequency in [MHz]
        proc.spec1.sf = exptDat.sf;
%         proc.spec1.sf = exptDat.sf/1e6;
    else
        fprintf('%s ->\nParameter <sf> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'sw_h')      % sweep width in [Hz]
        proc.spec1.sw_h = exptDat.sw_h;
    else
        fprintf('%s ->\nParameter <sw_h> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
    if isfield(exptDat,'nspecC')    % number of complex data points
        proc.spec1.nspecCOrig = exptDat.nspecC;
        proc.spec1.nspecC     = exptDat.nspecC;
    else
        fprintf('%s ->\nParameter <nspecC> not found in data file. Program aborted.\n',FCTNAME);
        return
    end
elseif flag.procDataFormat==2            % RAG text data and parameter files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec1.dataPathTxt)
        return
    end
    
    %--- load data file ---
    unit = fopen(proc.spec1.dataPathTxt,'r');
    if unit==-1
        fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME);
        return
    end
    dataTmp = fscanf(unit,'%g		%g',[2 inf]);
    fclose(unit);
    proc.spec1.fidOrig = dataTmp(1,:)' + 1i*dataTmp(2,:)';

    %--- init key spectral parameters ---
    proc.spec1.sf     = 0;      % init
    proc.spec1.sw_h   = 0;      % init
    proc.spec1.nspecC = 0;      % init
    nspecCLowPrio     = 0;      % init
   
    %--- load parameter file ---
    % note that dataPathTxt does not need to have a .txt extension
    dotInd = find(proc.spec1.dataPathTxt=='.');
%     if isempty(dotInd)
%         parFilePath = [proc.spec1.dataPathTxt '.par'];
%     else
%         parFilePath = [proc.spec1.dataPathTxt(1:(dotInd(end)-1)) '.par'];
%     end
    % new standard extension of parameter file is .spx
    if isempty(dotInd)
        parFilePathPar = [proc.spec1.dataPathTxt '.par'];
        parFilePathSpx = [proc.spec1.dataPathTxt '.spx'];
    else
        parFilePathPar = [proc.spec1.dataPathTxt(1:(dotInd(end)-1)) '.par'];
        parFilePathSpx = [proc.spec1.dataPathTxt(1:(dotInd(end)-1)) '.spx'];
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
                    proc.spec1.sf = str2double(sfStr);
                    f_inspector   = 1;
                elseif strncmp('sw_h ',tline,5)  
                    [fake,sw_hStr]  = strtok(tline);
                    proc.spec1.sw_h = str2double(sw_hStr);
                    f_inspector     = 1; 
                elseif strncmp('nspecC ',tline,7)   
                    [fake,nspecCStr]  = strtok(tline);
                    proc.spec1.nspecC = str2double(nspecCStr);
                    proc.spec1.nspecCOrig = proc.spec1.nspecC;
                    f_inspector       = 1;
                elseif strncmp('Field strength',tline,14)
                    [fake,sfStr]  = strtok(tline,'=');
                    [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                    proc.spec1.sf = str2double(sfStr);
                    f_rag       = 1;
                elseif strncmp('Spectral width',tline,14)   
                    [fake,sw_hStr]  = strtok(tline,'=');
                    [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                    proc.spec1.sw_h = str2double(sw_hStr)*1000;
                    f_rag       = 1;
                elseif strncmp('Acquisition points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    proc.spec1.nspecC = str2double(nspecCStr(2:end));
                    proc.spec1.nspecCOrig = proc.spec1.nspecC;
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
        if proc.spec1.nspecC==0 && nspecCLowPrio>0
            proc.spec1.nspecC     = nspecCLowPrio;
            proc.spec1.nspecCOrig = proc.spec1.nspecC;
        end        
        
        %--- consistency check ---
        if f_inspector && f_rag
            fprintf('%s ->\nInconsisten parameter format (INSPECTOR vs. RAG) detected.\n',FCTNAME);
            return
        end

    %--- format of Robin's simulated, individual LCModel basis spectra ---    
    elseif SP2_CheckFileExistenceR([proc.spec1.dataDir 'BasisSetParameters.txt'])
        fid = fopen([proc.spec1.dataDir 'BasisSetParameters.txt'],'r');
        if (fid > 0)
            proc.spec1.sf   = str2double(fgetl(fid));
            proc.spec1.sw_h = 1000*str2double(fgetl(fid));
            fclose(fid);
        else
            fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
        end
        
        %--- info printout of simulation calibration frequency ---
        if SP2_CheckFileExistenceR([proc.spec1.dataDir 'BasisRFOffset.txt'])
            fid = fopen([proc.spec1.dataDir 'BasisRFOffset.txt'],'r');
            if (fid > 0)
                fprintf('LCModel parameter file found.\n');
                fprintf('Basis RF offset of simulated spectrum: %s ppm\n',fgetl(fid));
                fclose(fid);
            else
                fprintf('%s ->\n<%s> exists but can not be opened...\n',FCTNAME,file);
            end
        end
        
        %--- determined FID length directly from data set ---
        proc.spec1.nspecC = length(proc.spec1.fidOrig);        
        proc.spec1.nspecCOrig = proc.spec1.nspecC;
        
    %--- check for metabolite-specific parameter file, e.g. NAA.par for NAAH2 data set ---
    elseif (SP2_CheckFileExistenceR([proc.spec1.dataPathTxt(1:end-2) '.par']) && ...        % H1..9
            strcmp(proc.spec1.dataFileTxt(end-1),'H') && ...
            (strcmp(proc.spec1.dataFileTxt(end),'1') || ...
             strcmp(proc.spec1.dataFileTxt(end),'2') || ...
             strcmp(proc.spec1.dataFileTxt(end),'3') || ...
             strcmp(proc.spec1.dataFileTxt(end),'4') || ...
             strcmp(proc.spec1.dataFileTxt(end),'5') || ...
             strcmp(proc.spec1.dataFileTxt(end),'6') || ...
             strcmp(proc.spec1.dataFileTxt(end),'7') || ...
             strcmp(proc.spec1.dataFileTxt(end),'8') || ...
             strcmp(proc.spec1.dataFileTxt(end),'9'))) || ...
            (SP2_CheckFileExistenceR([proc.spec1.dataPathTxt(1:end-3) '.par']) && ...        % H10..19
            strcmp(proc.spec1.dataFileTxt(end-2),'H') && ...
            (strcmp(proc.spec1.dataFileTxt(end-1:end),'10') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'11') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'12') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'13') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'14') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'15') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'16') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'17') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'18') || ...
             strcmp(proc.spec1.dataFileTxt(end-1:end),'19'))) || ...
            (SP2_CheckFileExistenceR([proc.spec1.dataPathTxt(1:end-1) '.par']) && ...       % P / N
                strcmp(proc.spec1.dataPathTxt(end),'P') || ...          % P
                strcmp(proc.spec1.dataPathTxt(end),'N'))                % N
            
        %--- H/N/P handling ---
        if SP2_CheckFileExistenceR([proc.spec1.dataPathTxt(1:end-2) '.par'])                % H1..9
            parFilePath = [proc.spec1.dataPathTxt(1:end-2) '.par'];
        elseif SP2_CheckFileExistenceR([proc.spec1.dataPathTxt(1:end-3) '.par'])            % H10..19
            parFilePath = [proc.spec1.dataPathTxt(1:end-3) '.par'];
        else                                                                                % N or P
            parFilePath = [proc.spec1.dataPathTxt(1:end-1) '.par'];
        end
        
        %--- open parameter file ---
        fid = fopen(parFilePath,'r');
        if (fid > 0)
            while (~feof(fid))
                tline = fgetl(fid);
                if strncmp('Field strength',tline,14)
                    [fake,sfStr]  = strtok(tline,'=');
                    [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                    proc.spec1.sf = str2double(sfStr);
                elseif strncmp('Spectral width',tline,14)   
                    [fake,sw_hStr]  = strtok(tline,'=');
                    [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                    proc.spec1.sw_h = str2double(sw_hStr)*1000;
                elseif strncmp('Acquisition points',tline,18)   
                    [fake,nspecCStr]  = strtok(tline,'=');
                    proc.spec1.nspecC = str2double(nspecCStr(2:end));
                    proc.spec1.nspecCOrig = proc.spec1.nspecC;
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
        if ~isfield(proc.spec1,'sf')
            proc.spec1.sf     = 0;
        end
        if ~isfield(proc.spec1,'sw_h')
            proc.spec1.sw_h   = 0;
        end
        if ~isfield(proc.spec1,'nspecC')
            proc.spec1.nspecC = 0;
        end
        SP2_Proc_Spec1ParsDialogMain(1)
        waitfor(fm.proc.dialog1.fig)
    end
    
    %--- consistency checks ---
    if proc.spec1.sf==0 || proc.spec1.sw_h==0 || proc.spec1.nspecC==0 || proc.spec1.nspecCOrig==0
        fprintf('%s ->\nReading parameter file failed. Program aborted.\n',FCTNAME);
        return
    end
    if proc.spec1.nspecC~=size(dataTmp,2)
        fprintf('%s ->\nIncosistent data dimension detected:\n(parameter file) %i ~= %i (FID dimension)\nProgram aborted.\n',...
                FCTNAME,proc.spec1.nspecC,size(dataTmp,2))
        return
    end
elseif flag.procDataFormat==3           % all moeties of a metabolite defined by its .par file (core name)
    %--- check parameter file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec1.dataPathPar)
        return
    end
    
    %--- read parameter file ---
    fid = fopen(proc.spec1.dataPathPar,'r');
    if (fid > 0)
        while (~feof(fid))
            tline = fgetl(fid);
            if strncmp('Field strength',tline,14)
                [fake,sfStr]  = strtok(tline,'=');
                [sfStr,fake]  = strtok(sfStr(2:end),'MHz');
                proc.spec1.sf = str2double(sfStr);
            elseif strncmp('Spectral width',tline,14)   
                [fake,sw_hStr]  = strtok(tline,'=');
                [sw_hStr,fake]  = strtok(sw_hStr(2:end),'kHz');
                proc.spec1.sw_h = str2double(sw_hStr)*1000;
            elseif strncmp('Acquisition points',tline,18)   
                [fake,nspecCStr]  = strtok(tline,'=');
                proc.spec1.nspecC = str2double(nspecCStr(2:end));
                proc.spec1.nspecCOrig = proc.spec1.nspecC;
            elseif strncmp('RF offset',tline,9)   
                [fake,ppmCalibStr] = strtok(tline,'=');
                [ppmCalibStr,fake] = strtok(ppmCalibStr(2:end),'ppm');
                proc.ppmCalib      = str2double(ppmCalibStr);
            end
        end
        fclose(fid);
    else
        fprintf('%s ->\n<%s> exists but can not be opened...\n',...
                FCTNAME,proc.spec1.dataPathPar);
    end
    
    %--- extract key string ---
    metabStr  = proc.spec1.dataFilePar(1:end-4);
    metabStrN = length(metabStr);
    
    %--- moeity file handling ---
    fStructOrig = dir(proc.spec1.dataDir);      % retrieve directory files
    fStruct     = fStructOrig(3:end);           % remove . and ..
    fStructN    = size(fStruct,1);              % number of files
    moeities    = {};                           % metabolite moeity cell
    moeitiesN   = 0;                            % number of metabolite moeities
    for fCnt = 1:fStructN
        % note that .txt are potentially included
        if strcmp(metabStr,'NAA')
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
    
    %--- success check ---
    if moeitiesN==0
        fprintf('No individual moeities could be attributed to <%s.par>.\nProgram aborted.\n\n',metabStr);
        return
    end
    
    %--- info printout ---
    fprintf('Moeities associated with <%s>:\n',proc.spec1.dataFilePar);
    for mCnt = 1:moeitiesN
        fprintf('%2.0f: %s\n',mCnt,moeities{mCnt}) 
    end 
    
    %--- load and add individual moeities ---
    proc.spec1.fidOrig = zeros(proc.spec1.nspecC,1);
    for mCnt = 1:moeitiesN
        %--- load data file ---
        unit = fopen([proc.spec1.dataDir moeities{mCnt}],'r');
        if unit==-1
            fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME);
            return
        end
        dataTmp = fscanf(unit,'%g		%g',[2 inf]);
        fclose(unit);
        proc.spec1.fidOrig = proc.spec1.fidOrig + dataTmp(1,:)' + 1i*dataTmp(2,:)'; 
    end
elseif flag.procDataFormat==4           % LCModel .raw data files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec1.dataPathRaw)
        return
    end
    
    %--- open data file ---
    unit = fopen(proc.spec1.dataPathRaw,'r');
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
            proc.spec1.sf = str2double(sfStr);
            f_hzpppm = 1;
        elseif strfind(tline,'DELTAT')  
            [fake,deltatStr] = strtok(tline);
            proc.spec1.sw_h  = 1/str2double(deltatStr);
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
    proc.spec1.fidOrig    = dataTmp(1,:)' - 1i*dataTmp(2,:)';
    % proc.spec1.fidOrig(1) = proc.spec1.fidOrig(1)/2;

    %--- init key spectral parameters ---
    if f_hzpppm
        fprintf('Larmor frequency read from file: %.1f MHz\n',proc.spec1.sf);
%     else
%         proc.spec1.sf     = 298.1;      % init
%         proc.spec1.sf     = 123.3;      % init
%         fprintf('\nWARNING: NO LARMOR FREQUENCY FOUND, ASSIGNED AS %.1f MHZ\n\n',proc.spec1.sf);
    end
    if f_sw_h
        fprintf('Bandwidth read from file: %.1f Hz\n',proc.spec1.sw_h);
%     else
%         proc.spec1.sw_h   = 5000;       % init
%         proc.spec1.sw_h   = 2800.3;       % init
%         fprintf('\nWARNING: NO BANDWIDTH FOUND, ASSIGNED AS %.1f HZ\n\n',proc.spec1.sw_h);
    end
    
    %--- ask for parameters ---
    if ~f_hzpppm || ~f_sw_h
        fprintf('%s ->\nNo parameter file found. Direct assignment required...\n',FCTNAME);
        if ~isfield(proc.spec1,'sf')
            proc.spec1.sf     = 0;
        end
        if ~isfield(proc.spec1,'sw_h')
            proc.spec1.sw_h   = 0;
        end
        SP2_Proc_Spec1ParsDialogMain(0)
        waitfor(fm.proc.dialog1.fig)
    end
    
    %--- determined FID length directly from data set ---
    proc.spec1.nspecC = length(proc.spec1.fidOrig);        
    proc.spec1.nspecCOrig = proc.spec1.nspecC;
else                                % LCModel .coord result/output files
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(proc.spec1.dataPathCoord)
        return
    end
    
    %--- load COORD file ---
    [coord, f_done] = SP2_Proc_PlcmReadCoord(proc.spec1.dataPathCoord);
    if ~f_done
        return
    end
    
    %--- format COORD content ---
    [plcm, f_done] = SP2_Proc_PlcmFormatCoord( coord );
    if ~f_done
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
    coordDirName = [proc.spec1.dataFileCoord(1:end-6) '_COORD'];
    coordDirPath = [proc.spec1.dataDir coordDirName '\'];
    [f_done,msg,msgId] = mkdir(proc.spec1.dataDir,coordDirName);
    if ~f_done
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
            metabPath = [coordDirPath proc.spec1.dataFileCoord(1:end-6) '_orig.mat'];
        elseif mCnt==2*coord.nconc+2        % fit
            metabPath = [coordDirPath proc.spec1.dataFileCoord(1:end-6) '_fit.mat'];
        elseif mCnt==2*coord.nconc+3        % baseline
            metabPath = [coordDirPath proc.spec1.dataFileCoord(1:end-6) '_base.mat'];
        elseif mCnt==2*coord.nconc+4        % metabolite sum
            metabPath = [coordDirPath proc.spec1.dataFileCoord(1:end-6) '_sum_plusBase.mat'];
        elseif mCnt<coord.nconc+1           % individual metabolites, 1st run: metab alone
            metabPath = [coordDirPath proc.spec1.dataFileCoord(1:end-6) '_' sprintf('%s',coord.metab{mCnt}) '.mat'];
        else        % mCnt>coord.nconc & mCnt<=2*coord.nconc, individual metabolites, 2nd run: metab + base
            metabPath = [coordDirPath proc.spec1.dataFileCoord(1:end-6) '_' sprintf('%s',coord.metab{mCnt-coord.nconc}) '_plusBase.mat'];
        end
        save(metabPath,'exptDat')
        fprintf('%s data written to file\n',metabPath);
    end
    
    %--- copy basic parameters to spec1 (fake init) ---
    proc.spec1.fid        = exptDat.fid;
    proc.spec1.fidOrig    = exptDat.fid;
    proc.spec1.sw_h       = exptDat.sw_h;
    proc.spec1.sf         = exptDat.sf;
    proc.spec1.nspecC     = exptDat.nspecC;
    proc.spec1.nspecCOrig = exptDat.nspecC;
end
     
%--- derivation of secondary parameters ---
proc.spec1.sw    = proc.spec1.sw_h/proc.spec1.sf;       % sweep width in [ppm]
proc.spec1.dwell = 1/proc.spec1.sw_h;                   % dwell time

%--- info string ---
if flag.procDataFormat==1           % matlab format
    fprintf('\nSpectral data set 1 loaded from file\n%s\n',proc.spec1.dataPathMat);
elseif flag.procDataFormat==2       % text format
    fprintf('\nSpectral data set 1 loaded from file\n%s\n',proc.spec1.dataPathTxt);
elseif flag.procDataFormat==3       % (.par) metabolite moeities
    fprintf('\nSpectral data set 1 assembled from <%s> moeities\n',metabStr);
elseif flag.procDataFormat==4       % LCModel (.raw) format
    fprintf('\nSpectral data set 1 loaded from file\n<%s>\n',proc.spec1.dataPathRaw);
else                                % LCModel (.coord) format
    fprintf('\nConversion of COORD file to individual result FIDs completed.\n\n');
end
fprintf('larmor frequency: %.1f MHz\n',proc.spec1.sf);
fprintf('sweep width:      %.1f Hz\n',proc.spec1.sw_h);
fprintf('complex points:   %.0f\n',proc.spec1.nspecC);
fprintf('ppm calibration:  %.3f ppm (global)\n\n',proc.ppmCalib);

%--- update success flag ---
f_succ = 1;


end
