%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_BasisImport
%% 
%%  Function for automated import of basis functions from file(s).
%%  Supported data formats: 
%%  1) INSPECTOR's .mat
%%  2) RAG's .par 
%%  3) jMRUI's .mrui 
%%  4) Provencher's .raw files
%%  5) Provencher's .basis file
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_BasisImport';


%--- init success flag ---
f_succ = 0;

%--- check directory access ---
[f_done,maxPath] = SP2_CheckDirAccessR(lcm.basisDir);
if ~f_done
    if isempty(maxPath)
        if ispc
            lcm.basisDir = 'C:\';
        elseif ismac
            lcm.basisDir = '/Users/';
        else
            lcm.basisDir = '/home/';
        end
    else
        if ispc
            lcm.basisDir = [maxPath '\'];
        else
            lcm.basisDir = [maxPath '/'];
        end
    end
end

%--- browse the fid file ---
[basisFidSelName, basisFidDir] = uigetfile('*.mat;*.par;*.raw;*.RAW;*.basis;*.BASIS','Select representative data set or basis',SP2_GuaranteeFinalSlash(lcm.basisDir));         % select data file
if ~ischar(basisFidSelName)             % buffer select cancelation
    if ~basisFidSelName            
        fprintf('%s aborted.\n',FCTNAME);
        return
    end
end

%--- derive format ---
flagLcmDataFormat = flag.lcmDataFormat;             % keep original data format
if strcmp(basisFidSelName(end-3:end),'.mat')
    flag.lcmDataFormat = 1;
elseif strcmp(basisFidSelName(end-5:end),'.basis') || strcmp(basisFidSelName(end-5:end),'.BASIS')
    flag.lcmDataFormat = 2;                 % note that this is (meant to be) the .txt case 
elseif strcmp(basisFidSelName(end-3:end),'.par')
    flag.lcmDataFormat = 3;
elseif strcmp(basisFidSelName(end-3:end),'.raw') || strcmp(basisFidSelName(end-3:end),'.RAW')
    flag.lcmDataFormat = 4;
else                    % .mrui
    flag.lcmDataFormat = 5;
end

%--- file import and basis creation ---
if flag.lcmDataFormat==2                % Provencher LCModel .basis
    %--- file path handling ---
    basisPath = [basisFidDir basisFidSelName];
    
    %--- parameter assignment ---
    lcm.ppmCalib       = 4.65;
    lcm.basis.ppmCalib = lcm.ppmCalib;
    
    %--- open data file ---
    unit = fopen(basisPath,'r');
    if unit==-1
        fprintf('%s ->\nOpening basis file failed. Program aborted.\n',FCTNAME);
        flag.lcmDataFormat = flagLcmDataFormat;             % reset original data format
        fclose(unit);
        return
    end
    
    %--- read parameter header ---
    tline = fgetl(unit);
    if ~strcmp(tline,' $SEQPAR')
        fprintf('%s ->\nThe assigned file seems not to contain a valid LCModel basis.\nProgram aborted.\n',FCTNAME);
        flag.lcmDataFormat = flagLcmDataFormat;             % reset original data format
        fclose(unit);
        return
    end
    
    %--- read file header ---
    f_hzpppm = 0;       % init
    f_sw_h   = 0;       % init
    f_nspecC = 0;       % init
    if flag.verbose
        fprintf('File header:\n');
    end
%     while isempty(strfind(tline,'ID=')) && isempty(strfind(tline,'ID =')) && ~feof(unit)
    while ~strcmp(tline,' $BASIS') && ~feof(unit)
        tline = fgetl(unit);
        if any(strfind(tline,'HZPPPM=')) || any(strfind(tline,'HZPPPM ='))           
            [fake,sfStr] = strtok(SP2_SubstStrPart(tline,' ',''),'=');
            [sfStr,fake] = strtok(sfStr,'=');
            [sfStr,fake] = strtok(sfStr,',');
            lcm.sf = str2double(sfStr);
            if ~isnan(lcm.sf)
                f_hzpppm = 1;
            end
        elseif any(strfind(tline,'BADELT=')) || any(strfind(tline,'BADELT ='))  
            [fake,deltatStr] = strtok(SP2_SubstStrPart(tline,' ',''),'=');
            [deltatStr,fake] = strtok(deltatStr,'=');
            [deltatStr,fake] = strtok(deltatStr,',');
            lcm.sw_h  = abs(1/str2double(deltatStr));           % abs() because of NYSPI
            if ~isnan(lcm.sw_h)
                f_sw_h = 1;
            end
        elseif any(strfind(tline,'NDATAB=')) || any(strfind(tline,'NDATAB ='))  
            [fake,nspecCStr] = strtok(SP2_SubstStrPart(tline,' ',''),'=');
            [nspecCStr,fake] = strtok(nspecCStr,'=');
            [nspecCStr,fake] = strtok(nspecCStr,',');
            lcm.nspecC = str2double(nspecCStr);
            lcm.nspecCOrig = lcm.nspecC;
            if ~isnan(lcm.nspecC)
                f_nspecC = 1;
            end
        end
        if flag.verbose
            fprintf('%s\n',tline);
        end
    end
    
    %--- consistency check ---
    if ~f_hzpppm || ~f_sw_h || ~f_nspecC
        fprintf('%s ->\nReading the basis file header failed.\n',FCTNAME);
        fprintf('f_hzpppm = %.0f\n',f_hzpppm);
        fprintf('f_sw_h   = %.0f\n',f_sw_h);
        fprintf('f_nspecC = %.0f\nProgram aborted.\n',f_nspecC);
        flag.lcmDataFormat = flagLcmDataFormat;             % reset original data format
        fclose(unit);
        return
    end
    
    %--- parameter update ---
    lcm.sw    = lcm.sw_h / lcm.sf;
    lcm.dwell = 1/lcm.sw_h;
    
    %--- intermediate info printout ---
    if flag.verbose
        fprintf('\nBasis file header:\nLarmor frequency: %.6f MHz\n',lcm.sf);
        fprintf('Bandwidth:        %.1f Hz\n',lcm.sw_h);
        fprintf('Complex points:   %.0f\n\n',lcm.nspecC);
    end

    %--- read metabolite headers and data ---
    bCnt = 0;                                   % init basis counter
    while ~feof(unit)
        bCnt = bCnt + 1;    % assuming that there will be another one
        f_metabo = 0;       % init/reset
        f_conc   = 0;       % init/reset
        while ~strcmp(tline,' $BASIS')          % skip until next basis
            % EOF needed to abort after last FID
            if feof(unit)
                break
            else
                tline = fgetl(unit);
            end
        end
        if ~feof(unit)
            while isempty(strfind(tline,'$END'))
                tline = fgetl(unit);
                if any(strfind(tline,'METABO=')) || any(strfind(tline,'METABO ='))           % grid size assignment: cylinder geometry  
                    [fake,metaboStr] = strtok(SP2_SubstStrPart(tline,' ',''),'''''');
                    [metabName,fake] = strtok(metaboStr,'''''');
                    if ~isempty(metabName)
                        f_metabo = 1;
                    end
                    
                    
                    
                elseif any(strfind(tline,'CONC=')) || any(strfind(tline,'CONC ='))    
                    [fake,concStr] = strtok(SP2_SubstStrPart(tline,' ',''),'=');
                    [concStr,fake] = strtok(concStr,'=');
                    [concStr,fake] = strtok(concStr,',');
                    metabConc(bCnt) = str2double(concStr);
                    if ~isnan(metabConc(bCnt))
                        f_conc = 1;
                    end
                end
                if flag.verbose
                    fprintf('%s\n',tline);
                end
            end
            fprintf('\n');

            %--- consistency check ---
            if ~f_metabo || ~f_conc
                if f_metabo
                    fprintf('%s ->\nReading individual metabolite header #%.0f (%s) failed.\nProgram aborted.\n',...
                            FCTNAME,bCnt,metabName(bCnt))
                else
                    fprintf('%s ->\nReading individual metabolite header #%.0f failed.\nProgram aborted.\n',...
                            FCTNAME,bCnt)
                end
                fprintf('f_metabo = %.0f\n',f_metabo);
                fprintf('f_conc   = %.0f\nProgram aborted.\n',f_conc);
                flag.lcmDataFormat = flagLcmDataFormat;             % reset original data format
                fclose(unit);
                return
            end

            %--- read data ---
            [dataTmp,readCnt] = fscanf(unit,'%g',[2 lcm.nspecC]);
            if readCnt~=2*lcm.nspecC                
                fprintf('%s ->\nReading individual metabolite #%.0f (%s) data failed.\nProgram aborted.\n',...
                        FCTNAME,bCnt,metabConc(bCnt))
                flag.lcmDataFormat = flagLcmDataFormat;             % reset original data format
                fclose(unit);
                return
            end
            lcm.fidOrig = conj(ifft(dataTmp(1,:)'+1i*dataTmp(2,:)',[],1));

            %--- frequency correction ---
            if 1
                % line broadening
                if bCnt==1
                    LB = 2;         
                    lbWeight = exp(-LB*lcm.dwell*(0:lcm.nspecC-1)*pi)';
                end
                lcmFidTmp  = lcm.fidOrig .* lbWeight;
                lcmSpecTmp = fftshift(fft(lcmFidTmp,32768,1),1);

                % target area extraction ---
                [tMinI,tMaxI,tPpmZoom,tSpecZoom,f_done] = ...
                    SP2_LCM_ExtractPpmRange(-0.2,0.2,lcm.basis.ppmCalib,lcm.sw,real(lcmSpecTmp));
                if ~f_done
                    fprintf('%s ->\nTarget area extraction for frequency correction failed of <%s> failed.\nProgram aborted.\n',...
                            FCTNAME,metabName)
                    return
                end
                [tMaxAmpl,tMaxInd] = max(tSpecZoom);            % frequency position [ppm]
                
                % frequency correction
                if bCnt==1
                    tVec = (0:lcm.nspecC-1)' * lcm.dwell;
                end
                frequCorr = -tPpmZoom(tMaxInd)*lcm.sf;          % frequency correction [Hz]
                lcm.fidOrig = lcm.fidOrig .* exp(1i*tVec*frequCorr*2*pi);   
                corrMsgStr = sprintf('%.1f Hz correction applied',frequCorr);
            else
                corrMsgStr = '';
            end
            
            %--- data formating ---
            if SP2_LCM_ProcLcmData
                if flag.verbose
                    fprintf('\nProcessing <%s> completed\n',metabName);
                end
            else
                fprintf('\nProcessing <%s> failed. Basis import aborted.\n',metabName);
                return
            end

            %--- assign to basis ---
            if bCnt==1                      % init for first basis function
                %--- reset basis ---
                lcm.basis.data     = 0;            

                %--- recreate basis ---
                if SP2_LCM_BasisAssign(bCnt)
                    if flag.verbose
                        fprintf('\nNew basis created\n');
                    end
                else
                    fprintf('\nCreation of new basis failed.\n');
                    return
                end
            else
                %--- create new basis entry ---
                if SP2_LCM_BasisAdd
                    if flag.verbose
                        fprintf('\nAdding basis entry for <%s> completed\n',metabName);
                    end
                else
                    fprintf('\nAdding basis entry for <%s> failed. Basis import aborted.\n',metabName);
                    return
                end
            end

            %--- assignment of basis FID ---
            if SP2_LCM_BasisAssign(bCnt)
                if flag.verbose
                    fprintf('\nAssignment of <%s> completed\n',metabName);
                end
            else
                fprintf('\nAssignment of <%s> failed. Basis import aborted.\n',metabName);
                return
            end
            lcm.basis.data{bCnt}{1} = metabName;
            lcm.basis.data{bCnt}{5} = corrMsgStr;            
        else
            bCnt = bCnt - 1;
            fclose(unit);
            break       % main while loop
        end
    end
    
    %--- concentration-based amplitude correction ---
    ampScaleVec = max(metabConc)./metabConc;
    if any(ampScaleVec~=1)
        fprintf('\nConcentration correction applied:\n');
        for bCnt = 1:lcm.basis.n
            lcm.basis.data{bCnt}{4} = ampScaleVec(bCnt) * lcm.basis.data{bCnt}{4};
            fprintf('%s: Scaling x%.3f applied\n',lcm.basis.data{bCnt}{1},ampScaleVec(bCnt));
        end
        fprintf('\n');
    else
        fprintf('\nIdentical concentrations - no amplitude correction applied\n');
    end 
    
else                                    % serial file formats, i.e. all non-.basis formats
        
    %--- file handling ---
    if flag.lcmDataFormat==1            % .mat
        basisFidPaths = SP2_FindFiles('mat',basisFidDir);
    elseif flag.lcmDataFormat==3        % .par
        basisFidPaths = SP2_FindFiles('par',basisFidDir);
    elseif flag.lcmDataFormat==4        % .raw
        basisFidPaths_RAW = SP2_FindFiles('RAW',basisFidDir);
        basisFidPaths_raw = SP2_FindFiles('raw',basisFidDir);
        if isempty(basisFidPaths_RAW) && ~isempty(basisFidPaths_raw)
            basisFidPaths = basisFidPaths_raw;
        elseif ~isempty(basisFidPaths_RAW) && isempty(basisFidPaths_raw)
            basisFidPaths = basisFidPaths_RAW;
        else                            % both non-empty || both empty
            basisFidPaths = [basisFidPaths_RAW basisFidPaths_raw];
        end
    else                                % .mrui
        basisFidPaths = SP2_FindFiles('mrui',basisFidDir);
    end
    nFIDs = length(basisFidPaths);

    %--- consistency check ---
    if nFIDs==0
        flag.lcmDataFormat = flagLcmDataFormat;             % reset original data format
        if flag.lcmDataFormat==1            % .mat
            fprintf('\n%s ->\nNo valid basis files <.mat> found. Creation of basis set aborted.\n',FCTNAME);
        elseif flag.lcmDataFormat==3        % .par
            fprintf('\n%s ->\nNo valid basis files <.par> found. Creation of basis set aborted.\n',FCTNAME);
        elseif flag.lcmDataFormat==4        % .par
            fprintf('\n%s ->\nNo valid basis files <.raw>/<.RAW> found. Creation of basis set aborted.\n',FCTNAME);
        else
            fprintf('\n%s ->\nNo valid basis files <.mrui> found. Creation of basis set aborted.\n',FCTNAME);
        end
        return
    end
    
    %--- file name and path handling ---
    basisFidFiles = {};          % full file names (including .par)
    basisFidNames = {};          % core file names (i.e. metabolite name only)
    for fidCnt = 1:nFIDs
        if ispc
            slInd = strfind(basisFidPaths{fidCnt},'\');
        else
            slInd = strfind(basisFidPaths{fidCnt},'/');
        end
        basisFidFiles{fidCnt} = basisFidPaths{fidCnt}(slInd(end)+1:end);
        if flag.lcmDataFormat==5            % JMRUI
            basisFidNames{fidCnt} = basisFidPaths{fidCnt}(slInd(end)+1:end-5);
        else
            basisFidNames{fidCnt} = basisFidPaths{fidCnt}(slInd(end)+1:end-4);
        end
    end

    %--- keep parameter settings ---
    lcmDataDir  = lcm.dataDir;
    if flag.lcmDataFormat==1            % .mat
        lcmDataPathMat    = lcm.dataPathMat;
    elseif flag.lcmDataFormat==3        % .par
        lcmDataPathPar    = lcm.dataPathPar;
    elseif flag.lcmDataFormat==4        % .raw
        lcmDataPathRaw    = lcm.dataPathRaw;
    else                                % .mrui
        lcmDataPathJmrui  = lcm.dataPathJmrui;
    end
    flagLcmData = flag.lcmData;

    %--- assign parameter settings ---
    flag.lcmData = 6;                     % LCM page itself
    lcm.dataDir  = basisFidDir;           % data directory

    %--- basis creation and basis FID handling ---
    bCnt = 0;                                   % basis counter
    for fidCnt = 1:nFIDs
        %--- path assignment ---
        if flag.lcmDataFormat==1            % .mat
            lcm.dataPathMat = basisFidPaths{fidCnt};
            lcm.dataFileMat = lcm.dataPathMat(slInd(end)+1:end);
        elseif flag.lcmDataFormat==3        % .par
            lcm.dataPathPar = basisFidPaths{fidCnt};
            lcm.dataFilePar = lcm.dataPathPar(slInd(end)+1:end);
        elseif flag.lcmDataFormat==4        % .raw
            lcm.dataPathRaw = basisFidPaths{fidCnt};
            lcm.dataFileRaw = lcm.dataPathRaw(slInd(end)+1:end);
        else                                % .mrui
            lcm.dataPathJmrui = basisFidPaths{fidCnt};
            lcm.dataFileJmrui = lcm.dataPathJmrui(slInd(end)+1:end);
        end

        %--- parameter handling for Provencher LCModel ---
        % as .RAW files do not contain nothing but data
        % 1) retrieve from makebasis.in
        % 2) request user input
        if flag.lcmDataFormat==4 && fidCnt==1           % .raw
            %--- 1) read parameters from file ---
            f_makebasis   = 0;
            makeBasisPath = [basisFidDir 'makebasis.in'];
            if SP2_CheckFileExistenceR(makeBasisPath)
                [fid,msg] = fopen(makeBasisPath,'r');
                if fid>0
                    %--- info printout ---
                    fprintf('%s -> Reading spetral parameters from\n<%s>\n',FCTNAME,makeBasisPath);

                    %--- parameter extraction ---
                    while ~feof(fid)
                        tline = fgetl(fid);
                        if flag.debug
                            fprintf('%s\n',tline);
                        end

                        %--- Larmor frequency ---
                        if any(findstr('hzpppm=',tline))
                            [fake,valStr] = strtok(tline,'=');
                            [valStr,fake] = strtok(valStr,'=');
                            lcm.sf = str2double(valStr);
                        end

                        %--- bandwidth ---
                        if any(findstr('deltat=',tline))
                            [fake,valStr] = strtok(tline,'=');
                            [valStr,fake] = strtok(valStr,'=');
                            lcm.sw_h = 1/str2double(valStr);
                        end
                    end

                    %--- update success flag ---
                    f_makebasis = 1;                    % parameters found and extracted
                else
                   fprintf('\n%s ->\nOpening makebasis.in file failed. Reading of parameters from file is not possible.\n\n',FCTNAME);
                end
            end

            %--- 2) request parameters from user ---
            if ~f_makebasis                             % makebasis.in not found or not successfully read
                if SP2_LCM_SpecDataAndParsAssign(0)
                    fprintf('\nDirect assignment of spectral properties:\n');
                    fprintf('larmor frequency: %.1f MHz\n',lcm.sf);
                    fprintf('sweep width:      %.1f Hz\n',lcm.sw_h);
                    fprintf('complex points:   %.0f\n\n',lcm.nspecC);
                else
                    fprintf('\nDirect assignment of spectral parameters failed\n');
                end
            end

            %--- basic consistency checks ---
            if ~isfield(lcm,'sf') || ~isfield(lcm,'sw_h')
                fprintf('%s ->\nAssignment of spectral properties failed. Creation of basis set aborted.\n',FCTNAME);
                return
            end
            if lcm.sf<1 || lcm.sw_h<1
                fprintf('%s ->\nAssignment of spectral properties failed. Creation of basis set aborted.\n',FCTNAME);
                return
            end    
        end

        %--- load and process FID ---
        if SP2_LCM_SpecDataAndParsAssign(1)
            %--- info printout ---
            if flag.verbose
                fprintf('\nLoading <%s> completed\n',basisFidNames{fidCnt});
            end

            %--- create basis structure ---
            if SP2_LCM_ProcLcmData
                if flag.verbose
                    fprintf('\nProcessing <%s> completed\n',basisFidNames{fidCnt});
                end
            else
                fprintf('\nProcessing <%s> failed. Basis import aborted.\n',basisFidNames{fidCnt});
                return
            end

            %--- basis init ---
            bCnt = bCnt + 1;
            if bCnt==1                                          % first basis function
                %--- reset basis ---
                lcm.basis.data = 0;

                %--- recreate basis ---
                if SP2_LCM_BasisAssign(bCnt)
                    if flag.verbose
                        fprintf('\nNew basis created\n');
                    end
                else
                    fprintf('\nCreation of new basis failed.\n');
                    return
                end
            else
                %--- create new basis entry ---
                if SP2_LCM_BasisAdd
                    if flag.verbose
                        fprintf('\nAdding basis entry for <%s> completed\n',basisFidNames{fidCnt});
                    end
                else
                    fprintf('\nAdding basis entry for <%s> failed. Basis import aborted.\n',basisFidNames{fidCnt});
                    return
                end
            end

            %--- assignment of basis FID ---
            if SP2_LCM_BasisAssign(bCnt)
                if flag.verbose
                    fprintf('\nAssignment of <%s> completed\n',basisFidNames{fidCnt});
                end
            else
                fprintf('\nAssignment of <%s> failed. Basis import aborted.\n',basisFidNames{fidCnt});
                return
            end
            lcm.basis.data{bCnt}{1} = basisFidNames{bCnt};
        else
            fprintf('\nLoading <%s> failed\n',basisFidNames{fidCnt});
        end
    end

    %--- consistency check ---
    if bCnt>0
        switch flag.lcmDataFormat
            case 1                  % matlab (.mat)
                fprintf('%.0f (.mat) basis fields imported from file.\n',bCnt);
            case 2                  % text (.txt for RAG software)
                fprintf('%.0f (.txt) basis fields imported from file.\n',bCnt);
            case 3                  % parameter file (.par) for all moeties of a metabolite
                fprintf('%.0f (.par) basis fields imported from file.\n',bCnt);
            case 4                  % Provencher LCModel (.lcm/.raw)
                fprintf('%.0f (.raw) basis fields imported from file.\n',bCnt);
            case 5                  % JMRUI (.mrui)
                fprintf('%.0f (.mrui) basis fields imported from file.\n',bCnt);
        end
    else
        fprintf('Import of basis fields failed.\n');
    end

    %--- restore parameter settings ---
    lcm.dataDir  = lcmDataDir;
    if flag.lcmDataFormat==1            % .mat
        lcm.dataPathMat   = lcmDataPathMat;
    elseif flag.lcmDataFormat==3        % .par
        lcm.dataPathPar   = lcmDataPathPar;
    elseif flag.lcmDataFormat==4        % .raw
        lcm.dataPathRaw   = lcmDataPathRaw;
    else                                % .mrui
        lcm.dataPathJmrui = lcmDataPathJmrui;
    end
    flag.lcmData = flagLcmData;

    %--- combine GlucoseA/GlucoseB ---
    cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
    if any(cellfun(cellfind('GlcA'),basisFidNames)) && any(cellfun(cellfind('GlcB'),basisFidNames))
        %--- open yes/no dialog ---
        choice = questdlg('Would you like to combine GlcA/B?','Glucose Handling Dialog', ...
                          'Yes','No','Yes');

        %--- combination of GlucoseA/B ---
        if strcmp(choice,'Yes')
            %--- index handling ---
            GlcAInd = find(cellfun(cellfind('GlcA'),basisFidNames));
            GlcBInd = find(cellfun(cellfind('GlcB'),basisFidNames));

            %--- replace GlucoseA by weighted sum and rename ---
            lcm.basis.data{GlcAInd}{4} = 0.36*lcm.basis.data{GlcAInd}{4} + 0.64*lcm.basis.data{GlcBInd}{4};
            lcm.basis.data{GlcAInd}{1} = 'Glc';
            lcm.basis.data{GlcAInd}{5} = '0.36*GlcA + 0.64*GlcB';

            %--- delete GlucoseB ---
            if ~SP2_LCM_BasisDelete(GlcBInd)
                fprintf('Deleting GlcB from basis set failed. Basis import is incomplete.\n');
                return
            end

            %--- info output ---
            fprintf('\nGlucose anomers combined as 0.36*GlcA + 0.64*GlcB\n');
        end
    end

    %--- combine GlcA/GlcB or GlucoseA/GlucoseB ---
    cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
    if any(cellfun(cellfind('GlucoseA'),basisFidNames)) && any(cellfun(cellfind('GlucoseB'),basisFidNames))
        %--- open yes/no dialog ---
        choice = questdlg('Would you like to combine GlucoseA/B?','Glucose Handling Dialog', ...
                          'Yes','No','Yes');

        %--- combination of GlucoseA/B ---
        if strcmp(choice,'Yes')
            %--- index handling ---
            GlcAInd = find(cellfun(cellfind('GlucoseA'),basisFidNames));
            GlcBInd = find(cellfun(cellfind('GlucoseB'),basisFidNames));

            %--- replace GlucoseA by weighted sum and rename ---
            lcm.basis.data{GlcAInd}{4} = 0.36*lcm.basis.data{GlcAInd}{4} + 0.64*lcm.basis.data{GlcBInd}{4};
            lcm.basis.data{GlcAInd}{1} = 'Glucose';
            lcm.basis.data{GlcAInd}{5} = '0.36*GlucoseA + 0.64*GlucoseB';

            %--- delete GlucoseB ---
            if ~SP2_LCM_BasisDelete(GlcBInd)
                fprintf('Deleting GlucoseB from basis set failed. Basis import is incomplete.\n');
                return
            end

            %--- info output ---
            fprintf('\nGlucose anomers combined as 0.36*GlucoseA + 0.64*GlucoseB\n');
        end
    end
end             % of .basis vs. serial file formats

%--- reset original data format ---
flag.lcmDataFormat = flagLcmDataFormat;             % reset original data format

%--- window update ---
SP2_LCM_BasisWinUpdate

%--- info printout ---
fprintf('Basis import from\n<%s>\ncompleted.\n',basisFidDir);

%--- update success flag ---
f_succ = 1;

