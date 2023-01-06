%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  function SP2_Batch_Jodi_Processing
%%
%%  Serial data processing of Jodi Weinstein's hippocampus study.
%% 
%%  Note that the function assumes a windows system, the INSPECTOR 
%%  software is in your matlab search path and
%%  predefined protocol files for regular sLASER and JDE (defining the
%%  appropriate parameter settings and flags).
%%
%%  10-2021, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag mm proc fm data

FCTNAME = 'SP2_Batch_Jodi_Processing';

%--- data/result directory selection ---
dataDir   = 'X:\data\Jodi_Analysis\Hippo_sLASER_Proc\';                     % raw data directory
resultDir = 'C:\Users\juchem\Data\Siemens_JodiWeinstein\003_Hippo_Proc\';   % result directory
lcmDir    = '/home/mrs2/Neonatal/';                                         % default LCModel directory on analysis computer


%--- processing selection ---
studyRg             = 1:2;          % study range vector, 1:6 prelim data available
f_procSLaserMetab   = 1;            % process sLASER metabolites scan
f_procSLaserMM      = 1;            % process sLASER MM scan
f_procSLaserWater   = 1;            % process sLASER water reference
f_procJdeMetab      = 1;            % process JDE metabolite scans
f_procJdeWater      = 1;            % process JDE water scans

%--- data format ---
numSLaserMetab  = 1;                % target data sLASER metabolite scan
numSLaserMM     = 3;                % sLASER MM scan
numSLaserWater  = 5;                % sLASER water scan
numJdeMetab     = [7 12];           % JDE metabolite scan
numJdeWater     = 13;               % JDE water scan




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- check if INSPECTOR is open ---
if ~isfield(mm,'cut') || ~isfield(proc,'alignPolyOrder')
    INSPECTOR
end

%--- consistency checks ---
if ~SP2_CheckDirAccessR(dataDir)
    return
end
if ~SP2_CheckDirAccessR(resultDir)
    return
end
if SP2_CheckFileExistenceR([resultDir 'SPX_JodiHippo_JDE_metab.mat'])
    spxProt_JDE_metab = [resultDir 'SPX_JodiHippo_JDE_metab.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'SPX_JodiHippo_JDE_water.mat'])
    spxProt_JDE_water = [resultDir 'SPX_JodiHippo_JDE_water.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'SPX_JodiHippo_sLASER_metab.mat'])
    spxProt_sLASER_metab = [resultDir 'SPX_JodiHippo_sLASER_metab.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'SPX_JodiHippo_sLASER_water.mat'])
    spxProt_sLASER_water = [resultDir 'SPX_JodiHippo_sLASER_water.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'SPX_JodiHippo_sLASER_MM.mat'])
    spxProt_sLASER_MM = [resultDir 'SPX_JodiHippo_sLASER_MM.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'SPX_JodiHippo_sLASER_water.mat'])
    spxProt_sLASER_water = [resultDir 'SPX_JodiHippo_sLASER_water.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'jdeOffAlignRef.mat'])
    jdeOffAlignRefPath = [resultDir 'jdeOffAlignRef.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'jdeWaterAlignRef.mat'])
    jdeWaterAlignRefPath = [resultDir 'jdeWaterAlignRef.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'sLaserMetabAlignRef.mat'])
    sLaserMetabAlignRefPath = [resultDir 'sLaserMetabAlignRef.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'sLaserWaterAlignRef.mat'])
    sLaserWaterAlignRefPath = [resultDir 'sLaserWaterAlignRef.mat'];
else
    return
end

%--- study path handling  ---
dataDirStruct = dir(dataDir);
dataDirLen    = length(dataDirStruct);
studyDirName  = {};
studyDirPath  = {};
studyVec      = 0;
for sCnt = 1:length(studyRg)
    for dCnt = 1:dataDirLen
        if any(strfind(dataDirStruct(dCnt).name,sprintf('JodiHippo_%02i_',studyRg(sCnt))) & dataDirStruct(dCnt).isdir==1);
            if SP2_CheckDirAccessR([dataDir dataDirStruct(dCnt).name '\'])
                studyVec(length(studyDirName)+1)     = studyRg(sCnt);               % (effective) study numbers
                studyDirName{length(studyDirName)+1} = dataDirStruct(dCnt).name;    % study directories
                studyDirPath{length(studyDirPath)+1} = [dataDir dataDirStruct(dCnt).name '\'];  % study names
            end
        end
    end
end
studyN = length(studyVec);          % (effective) number of studies

%--- create result directory ---
studyResultDir = {};
for sCnt = 1:studyN
    studyResultDir{sCnt} = [resultDir sprintf('%02i',studyVec(sCnt)) '\'];
    if ~SP2_CheckDirAccessR(studyResultDir{sCnt})
        [f_done,msg,msgId] = mkdir(studyResultDir{sCnt});
        if ~f_done
            fprintf('%02i, %s\n',studyVec(sCnt),msg)
        end
    end
end

%--- serial SPX LCModel analysis ---
for sCnt = 1:studyN
    %--- info printout ---
    fprintf('\n\nSTUDY %s (%i of %i)\n\n',studyDirName{sCnt},sCnt,studyN)
    
    % files/directories in selected session
    dirStruct = dir(studyDirPath{sCnt});
    dirLen    = length(dirStruct);
    
    %*** sLASER METABOLITES (SCAN 1) ***
    for dirCnt = 1:dirLen
%         if any(strfind(dirStruct(dirCnt).name,sprintf('%02i_meas_',numSLaserMetab)) & ...
%                strfind(dirStruct(dirCnt).name,'.dat') & ...
%                dirStruct(dirCnt).isdir==0)
        if any(strncmp(dirStruct(dirCnt).name,sprintf('%02i_meas_',numSLaserMetab),8) & ...
               strfind(dirStruct(dirCnt).name,'.dat') & ...
               dirStruct(dirCnt).isdir==0)
        
            %--- protocol path handling ---
            SP2_Data_DataMain
            set(fm.data.protPath,'String',spxProt_sLASER_metab)
            if ~SP2_Data_ProtocolPathUpdate
                return
            end
            if ~SP2_Data_ProtocolLoad
                return
            end

            % assign metabolite scan
            scanPath = [studyDirPath{sCnt} dirStruct(dirCnt).name];
            set(fm.data.spec1FidFile,'String',scanPath);
            if ~SP2_Data_Dat1FidFileUpdate
                return
            end

            % assign scan series
            set(fm.data.spec1SeriesStr,'String',sprintf('%i %i',numSLaserMetab,numSLaserMetab));
            if ~SP2_Data_Dat1SeriesUpdate
                return
            end

            % assign reference scan
            set(fm.data.spec2FidFile,'String',scanPath);
            if ~SP2_Data_Dat2FidFileUpdate
                return
            end

            % load data
            if ~SP2_Data_Dat1SeriesLoad
                return
            end
            if ~SP2_Data_Dat2FidFileLoad
                return
            end

            % frequency and phase alignment
            if ~SP2_Data_Dat1SeriesAlignRegular
                return
            end

            % QA here...

            % data averaging
            if ~SP2_Data_Dat1SeriesSum
                return
            end

            % transfer JDE conditions to Processing page
            SP2_Proc_ProcessMain
            flag.procDataFormat = 1;                % matlab format

            % set up 2 data sets fom Data page
            set(fm.proc.numSpecTwo,'Value',1);      % 2 data sets
            SP2_Proc_NumSpecTwoUpdate

            % load current data from Data page as fid 1
            SP2_Proc_DataDataUpdate
            if ~SP2_Proc_DataAndParsAssign1
                return
            end

            % load edit OFF alignment reference from file
            SP2_Proc_DataProcUpdate
            proc.spec2.dataPathMat = sLaserMetabAlignRefPath;
            set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
            if ~SP2_Proc_Spec2DataPathUpdate
                return
            end
            if ~SP2_Proc_DataAndParsAssign2
                return
            end

            % align edit OFF condition (fid 2) with edit OFF phase reference (fid 1)
            % proc pars
            flag.procSpec1Cut    = 1;
            proc.spec1.cut       = 1800;
            flag.procSpec2Cut    = 1;
            proc.spec2.cut       = 1800;
            flag.procSpec1Zf     = 1;
            proc.spec1.zf        = 8192;
            flag.procSpec2Zf     = 1;
            proc.spec2.zf        = 8192;
            % align pars
            proc.alignPpmStr     = '1.9:4.15';
            flag.procAlignLb     = 1;
            flag.procAlignGb     = 0;
            flag.procAlignPhc0   = 1;
            flag.procAlignPhc1   = 0;
            flag.procAlignScale  = 1;
            flag.procAlignShift  = 1;
            flag.procAlignOffset = 1;
            flag.procAlignPoly   = 0;

            % update alignment windows
            set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
            if ~SP2_Proc_AlignPpmStrUpdate
                return
            end

            % align measured with reference sLASER metabolite spectrum 
            if ~SP2_Proc_AlignSpec1
                return
            end

            % reset processing of data set 2 other than the phasing
            flag.procSpec1Lb     = 0;
            flag.procSpec1Gb     = 0;
            flag.procSpec1Phc1   = 0;
            flag.procSpec1Scale  = 0;
            flag.procSpec1Shift  = 0;
            flag.procSpec1Offset = 0;

            % result scan path handling
            scanResultDir = [studyResultDir{sCnt} '01_sLASER_metab\'];
            if ~SP2_CheckDirAccessR(scanResultDir)
                [f_done,msg,msgId] = mkdir(scanResultDir);
                if ~f_done
                    fprintf('scanResultDir sLASER, %s\n',msg)
                end
            end

            % explicit data processing: FID 1, FID 2, difference
            flag.procSpec1Zf = 0;
            flag.procSpec2Zf = 0;
            if ~SP2_Proc_ProcComplete
                return
            end                

            % save phased sLASER spectrum to file 
            exptFilePath = [scanResultDir 'fid_metab.mat'];
            set(fm.proc.exptDataPath,'String',exptFilePath);
            if ~SP2_Proc_ExptDataMatUpdate;
                return
            end
            proc.expt.fid    = ifft(ifftshift(proc.spec1.spec,1),[],1);
            proc.expt.sf     = proc.spec1.sf;
            proc.expt.sw_h   = proc.spec1.sw_h;
            proc.expt.nspecC = proc.spec1.nspecC;
            if ~SP2_Proc_ExptDataSave
                return
            end

            
            % save as Provencher .raw 
            flag.procDataFormat = 4;                % .raw format
            % temporarily change for .raw
            exptDataPath = [scanResultDir sprintf('%s.raw',scanName)];
            set(fm.proc.exptDataPath,'String',exptDataPath)
            if ~SP2_Proc_ExptDataRawUpdate
                return
            end         
            if ~SP2_Proc_ExptDataSave
                return
            end
            flag.procDataFormat = 1;                % matlab format
            % reset to original .mat path for protocol
            exptDataPath = [scanResultDir sprintf('%s_metab.mat',scanName)];
            set(fm.proc.exptDataPath,'String',exptDataPath)
            if ~SP2_Proc_ExptDataPathUpdate
                return
            end         

            % write CONTROL file
            controlFilePathPC = [scanResultDir sprintf('%s.control',scanName)];       % local: PC
            unit = fopen(controlFilePathPC,'w');
            if unit==-1
                fprintf('%s ->\nOpening CONTROL file <%s> failed.\nProgram aborted.\n',FCTNAME,controlFilePathPC)
                return
            end
            fprintf(unit, ' $LCMODL\n');
            fprintf(unit, ' OWNER=''Christoph Juchem, MR SCIENCE Lab, Columbia University''\n');
            fprintf(unit, ' TITLE=''%s, %s, GE 3T, sLASER, TE 40 ms''\n',studyDirName{studyCnt},scanName);
            fprintf(unit, ' KEY(1)=%d\n', 0);
            fprintf(unit, ' FILRAW=''%s''\n', sprintf('%sAnalysis/LCModel_%03i/%s.raw',lcmDir,studyVec(studyCnt),scanName));
            fprintf(unit, ' FILH2O=''%s''\n', sprintf('%sAnalysis/LCModel_%03i/%s.h2o',lcmDir,studyVec(studyCnt),scanName));
            fprintf(unit, ' FILBAS=''%s''\n', sprintf('%sBasis/slaser_40.basis',lcmDir));
            fprintf(unit, ' FILTAB=''%s''\n', sprintf('%sAnalysis/LCModel_%03i/%s.table',lcmDir,studyVec(studyCnt),scanName));
            fprintf(unit, ' FILPRI=''%s''\n', sprintf('%sAnalysis/LCModel_%03i/%s.dump',lcmDir,studyVec(studyCnt),scanName));
            fprintf(unit, ' FILCSV=''%s''\n', sprintf('%sAnalysis/LCModel_%03i/%s.csv',lcmDir,studyVec(studyCnt),scanName));
            fprintf(unit, ' FILPS=''%s''\n', sprintf('%sAnalysis/LCModel_%03i/%s.ps',lcmDir,studyVec(studyCnt),scanName));
            fprintf(unit, ' LTABLE=%d\n', 7);
            fprintf(unit, ' LPRINT=%d\n', 6);
            fprintf(unit, ' LCSV=%d\n', 11);
            fprintf(unit, ' NEACH=%d\n', 50);
            fprintf(unit, ' PPMEND=%g\n', 0);
            fprintf(unit, ' PPMST=%g\n', 4.2);
            fprintf(unit, ' SDDEGZ=%g\n', 2);
            fprintf(unit, ' DELTAT=%g\n', proc.spec1.dwell);
            fprintf(unit, ' NUNFIL=%d\n', proc.spec1.nspecC);
            fprintf(unit, ' HZPPPM=%g\n', proc.spec1.sf);
            fprintf(unit, ' DOECC=T\n');
            fprintf(unit, ' $END\n');
            fclose(unit);

            % session-specific (i.e. baby-specific) LCModel batch processing 
            if ~f_batchSession              % 1st run, create session-specific batch script
                batchSessionFilePath = [scanResultDir sprintf('batchSession.txt')];
                unit = fopen(batchSessionFilePath,'w');
                if unit==-1
                    fprintf('%s ->\nCreating session LCModel batch script <%s> failed.\nProgram aborted.\n',FCTNAME,batchSessionFilePath)
                    return
                end
                fprintf(unit, '#!/bin/sh\n')

                % update flag
                f_batchSession = 1;         % file created
            else
                unit = fopen(batchSessionFilePath,'a');
                if unit==-1
                    fprintf('%s ->\nAppending to session LCModel batch script <%s> failed (scanCnt=%.0f, dirCnt=%.0f).\nProgram aborted.\n',...
                            FCTNAME,batchSessionFilePath,scanCnt,dirCnt)
                    return
                end
            end
            controlFilePathLCModel = sprintf('%sAnalysis/LCModel_%03i/%s.control',lcmDir,studyVec(studyCnt),scanName);
            fprintf(unit, '/home/mrs2/.lcmodel/bin/lcmodel < %s\n',controlFilePathLCModel)
            fprintf(unit, 'echo "LCModel_%03i/%s.control completed"\n',studyVec(studyCnt),scanName)
            fclose(unit)

            % overall LCModel batch processing script including all
            % sessions (i.e. babies) and scans per session
            if ~f_batchOverall              % 1st run, create overall batch script
                batchOverallFilePath = [resultDir sprintf('batchOverall.txt')];
                unit = fopen(batchOverallFilePath,'w');
                if unit==-1
                    fprintf('%s ->\nCreating overall LCModel batch script <%s> failed.\nProgram aborted.\n',FCTNAME,batchOverallFilePath)
                    return
                end
                fprintf(unit, '#!/bin/sh\n')

                % update flag
                f_batchOverall = 1;         % file created
            else
                unit = fopen(batchOverallFilePath,'a');
                if unit==-1
                    fprintf('%s ->\nAppending to overall LCModel batch script <%s> failed (studyCnt=%.0f,scanCnt=%.0f, dirCnt=%.0f).\nProgram aborted.\n',...
                            FCTNAME,batchOverallFilePath,studyCnt,scanCnt,dirCnt)
                    return
                end
            end
            fprintf(unit, '/home/mrs2/.lcmodel/bin/lcmodel < %s\n',controlFilePathLCModel)
            fprintf(unit, 'echo "LCModel_%03i/%s.control completed"\n',studyVec(studyCnt),scanName)
            fclose(unit)                        

            % potentially add:
            % more comprehensive analysis updates (incl. time)
            % final statement:  fprintf(unit, 'echo "Batch LCModel analysis completed"\n')

            
            % save SPX protocol
            SP2_Proc_DataProcUpdate
            proc.spec1.dataPathMat = exptFilePath;
            set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
            if ~SP2_Proc_Spec1DataPathUpdate
                return
            end
            
            % save protocol
            % note that the values written to file are the ones that were
            % applied before the FIDs were saved, i.e. they are directly visible
            flag.procSpec1Zf   = 1;
            flag.procSpec1Phc0 = 0;             
            set(fm.proc.numSpecOne,'Value',1);  % 1 data set
            SP2_Proc_NumSpecOneUpdate
            data.protPathMat = [scanResultDir 'SPX_sLASER_metab.mat'];
            dataProtPathMat  = data.protPathMat;
            SP2_Exit_ExitFct(data.protPathMat,0)
            INSPECTOR(dataProtPathMat)
 
            
            %*** sLASER WATER REFERENCE ***
            %--- protocol path handling ---
            SP2_Data_DataMain
            set(fm.data.protPath,'String',spxProt_sLASER_water)
            if ~SP2_Data_ProtocolPathUpdate
                return
            end
            if ~SP2_Data_ProtocolLoad
                return
            end

            % assign metabolite scan
            scanPath = [studyDirPath{sCnt} dirStruct(dirCnt).name];
            set(fm.data.spec1FidFile,'String',scanPath);
            if ~SP2_Data_Dat1FidFileUpdate
                return
            end

            % assign scan series
            set(fm.data.spec1SeriesStr,'String',sprintf('%i %i',numSLaserMetab,numSLaserMetab));
            if ~SP2_Data_Dat1SeriesUpdate
                return
            end

            % assign reference scan
            set(fm.data.spec2FidFile,'String',scanPath);
            if ~SP2_Data_Dat2FidFileUpdate
                return
            end

            % load data
            if ~SP2_Data_Dat1SeriesLoad
                return
            end
            if ~SP2_Data_Dat2FidFileLoad
                return
            end

            % data averaging
            if ~SP2_Data_Dat2ExtractWater;
                return
            end

            % transfer water signal to Processing page
            SP2_Proc_ProcessMain
            flag.procDataFormat = 1;                    % matlab format

            % set up 2 data sets
            set(fm.proc.numSpecTwo,'Value',1);          % 2 data sets
            SP2_Proc_NumSpecTwoUpdate

            % load data set 1 (water) from Data page
            SP2_Proc_DataDataUpdate
            if ~SP2_Proc_DataAndParsAssign1
                return
            end

            % load edit water alignment reference from file to fid 2
            SP2_Proc_DataProcUpdate
            proc.spec2.dataPathMat = sLaserWaterAlignRefPath;
            set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
            if ~SP2_Proc_Spec2DataPathUpdate
                return
            end
            if ~SP2_Proc_DataAndParsAssign2
                return
            end

            % align edit current water ref (fid 1) with alignment reference (fid 2)
            % proc pars
            flag.procSpec1Cut    = 0;
            flag.procSpec2Cut    = 0;
            flag.procSpec1Zf     = 1;
            proc.spec1.zf        = 8192;
            flag.procSpec2Zf     = 1;
            proc.spec2.zf        = 8192;
            flag.procSpec2Lb     = 1;
            proc.spec2.lb        = 1;
            % align pars
            proc.alignPpmStr     = '3:6.3';
            flag.procAlignLb     = 1;
            flag.procAlignGb     = 0;
            flag.procAlignPhc0   = 1;
            flag.procAlignPhc1   = 0;
            flag.procAlignScale  = 1;
            flag.procAlignShift  = 1;
            flag.procAlignOffset = 1;
            flag.procAlignPoly   = 0;

            % update alignment windows
            set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
            if ~SP2_Proc_AlignPpmStrUpdate
                return
            end

            % align measured water reference with alignment reference 
            if ~SP2_Proc_AlignSpec1
                return
            end

            % reset processing of data set 1 other than the phasing
            flag.procSpec1Lb     = 0;
            flag.procSpec1Gb     = 0;
            flag.procSpec1Phc1   = 0;
            flag.procSpec1Scale  = 0;
            flag.procSpec1Shift  = 0;
            flag.procSpec1Offset = 0;

            % result scan path handling
            scanResultDir = [studyResultDir{sCnt} '01_sLASER_metab\'];

            % explicit data processing: FID 1, FID 2, difference
            flag.procSpec1Zf = 0;
            flag.procSpec2Zf = 0;
            if ~SP2_Proc_ProcComplete
                return
            end                

            % save phased water reference to file 
            exptFilePath = [scanResultDir 'fid_water.mat'];
            set(fm.proc.exptDataPath,'String',exptFilePath);
            if ~SP2_Proc_ExptDataMatUpdate;
                return
            end
            proc.expt.fid    = ifft(ifftshift(proc.spec1.spec,1),[],1);
            proc.expt.sf     = proc.spec1.sf;
            proc.expt.sw_h   = proc.spec1.sw_h;
            proc.expt.nspecC = proc.spec1.nspecC;
            if ~SP2_Proc_ExptDataSave
                return
            end
                            
            % save as Provencher .raw 
            flag.procDataFormat = 4;                % .raw format
            % temporarily change for .raw
            exptDataPath = [scanResultDir sprintf('%s_h2o.raw',scanName)];      % tmp, then _h2o is moved to .h2o
            set(fm.proc.exptDataPath,'String',exptDataPath)
            if ~SP2_Proc_ExptDataRawUpdate
                return
            end         
            if ~SP2_Proc_ExptDataSave
                return
            end
            % rename .raw to .h2o
            fileH2oPath = [scanResultDir sprintf('%s.h2o',scanName)];
            [f_done,msg,msgId] = copyfile(exptDataPath,fileH2oPath);
            if f_done
                delete(exptDataPath)
                fprintf('scanResultDir sLASER (H2O), %s\n',msg)
            end
            flag.procDataFormat = 1;                % matlab format
            % reset to original .mat path for protocol
            exptDataPath = [scanResultDir sprintf('%s_h2o.mat',scanName)];
            set(fm.proc.exptDataPath,'String',exptDataPath)
            if ~SP2_Proc_ExptDataPathUpdate
                return
            end   
            
            % save SPX protocol
            SP2_Proc_DataProcUpdate
            proc.spec1.dataPathMat = exptFilePath;
            set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
            if ~SP2_Proc_Spec1DataPathUpdate
                return
            end

            % save protocol
            % note that the values written to file are the ones that were
            % applied before the FIDs were saved, i.e. they are directly visible
            flag.procSpec1Zf   = 1;
            flag.procSpec1Phc0 = 0;             
            set(fm.proc.numSpecOne,'Value',1);  % 1 data set
            SP2_Proc_NumSpecOneUpdate
            data.protPathMat = [scanResultDir 'SPX_sLASER_water.mat'];
            dataProtPathMat  = data.protPathMat;
            SP2_Exit_ExitFct(data.protPathMat,0)
            INSPECTOR(dataProtPathMat)
        end
    end             % end of sLASER water
    
    %*** sLASER MACROMOLECULES (SCAN 2) ***
    for dirCnt = 1:dirLen
%         if any(strfind(dirStruct(dirCnt).name,sprintf('%02i_meas_',numSLaserMM)) & ...
%                strfind(dirStruct(dirCnt).name,'.dat') & ...
%                dirStruct(dirCnt).isdir==0)
        if any(strncmp(dirStruct(dirCnt).name,sprintf('%02i_meas_',numSLaserMM),8) & ...
               strfind(dirStruct(dirCnt).name,'.dat') & ...
               dirStruct(dirCnt).isdir==0)
        
            %--- protocol path handling ---
            SP2_Data_DataMain
            set(fm.data.protPath,'String',spxProt_sLASER_MM)
            if ~SP2_Data_ProtocolPathUpdate
                return
            end
            if ~SP2_Data_ProtocolLoad
                return
            end

            % assign metabolite scan
            scanPath = [studyDirPath{sCnt} dirStruct(dirCnt).name];
            set(fm.data.spec1FidFile,'String',scanPath);
            if ~SP2_Data_Dat1FidFileUpdate
                return
            end

            % assign scan series
            set(fm.data.spec1SeriesStr,'String',sprintf('%i %i',numSLaserMetab,numSLaserMetab));
            if ~SP2_Data_Dat1SeriesUpdate
                return
            end

            % assign reference scan
            set(fm.data.spec2FidFile,'String',scanPath);
            if ~SP2_Data_Dat2FidFileUpdate
                return
            end

            % load data
            if ~SP2_Data_Dat1SeriesLoad
                return
            end
            if ~SP2_Data_Dat2FidFileLoad
                return
            end

            % frequency and phase alignment
            if ~SP2_Data_Dat1SeriesAlignRegular
                return
            end

            % QA here...

            % data averaging
            if ~SP2_Data_Dat1SeriesSum
                return
            end

            % transfer current MM signal to Processing page
            SP2_Proc_ProcessMain
            flag.procDataFormat = 1;                % matlab format

            % set up 2 data sets fom Data page
            set(fm.proc.numSpecTwo,'Value',1);      % 2 data sets
            SP2_Proc_NumSpecTwoUpdate

            % load current MM data from Data page as fid 2
            SP2_Proc_DataDataUpdate
            if ~SP2_Proc_DataAndParsAssign2
                return
            end

            % load processed sLASER metabolite signal from scan 1 of same study
            SP2_Proc_DataProcUpdate
            sLaserMetabPath = [studyResultDir{sCnt} '01_sLASER_metab\fid_metab.mat'];
            proc.spec1.dataPathMat = sLaserMetabPath;
            set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
            if ~SP2_Proc_Spec1DataPathUpdate
                return
            end
            if ~SP2_Proc_DataAndParsAssign1
                return
            end

            % align edit OFF condition (fid 2) with edit OFF phase reference (fid 1)
            % proc pars
            flag.procSpec1Cut    = 1;
            proc.spec1.cut       = 1800;
            flag.procSpec2Cut    = 1;
            proc.spec2.cut       = 1800;
            flag.procSpec1Zf     = 1;
            proc.spec1.zf        = 8192;
            flag.procSpec2Zf     = 1;
            proc.spec2.zf        = 8192;
            % align pars
            proc.alignPpmStr     = '0:1.9';         % leaving 4.15:4.4 out
            flag.procAlignLb     = 1;
            flag.procAlignGb     = 0;
            flag.procAlignPhc0   = 1;
            flag.procAlignPhc1   = 0;
            flag.procAlignScale  = 1;
            flag.procAlignShift  = 1;
            flag.procAlignOffset = 1;
            flag.procAlignPoly   = 0;

            % update alignment windows
            set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
            if ~SP2_Proc_AlignPpmStrUpdate
                return
            end

            % align measured with reference sLASER metabolite spectrum 
            if ~SP2_Proc_AlignSpec2
                return
            end

            % result scan path handling
            scanResultDir = [studyResultDir{sCnt} '03_sLASER_MM\'];
            if ~SP2_CheckDirAccessR(scanResultDir)
                [f_done,msg,msgId] = mkdir(scanResultDir);
                if ~f_done
                    fprintf('scanResultDir sLASER, %s\n',msg)
                end
            end

            % explicit data processing: FID 1, FID 2, difference
            flag.procSpec1Zf = 0;
            flag.procSpec2Zf = 0;
            if ~SP2_Proc_ProcComplete
                return
            end                

            % save phased sLASER spectrum to file 
            exptFilePath = [scanResultDir 'fid_MM.mat'];
            set(fm.proc.exptDataPath,'String',exptFilePath);
            if ~SP2_Proc_ExptDataMatUpdate;
                return
            end
            proc.expt.fid    = ifft(ifftshift(proc.spec2.spec,1),[],1);
            proc.expt.sf     = proc.spec2.sf;
            proc.expt.sw_h   = proc.spec2.sw_h;
            proc.expt.nspecC = proc.spec2.nspecC;
            if ~SP2_Proc_ExptDataSave
                return
            end
            
            % save MM-removed metabolite (difference) signal to file 
            exptFilePathDiff = [scanResultDir 'fid_diff.mat'];
            set(fm.proc.exptDataPath,'String',exptFilePathDiff);
            if ~SP2_Proc_ExptDataMatUpdate;
                return
            end
            proc.expt.fid    = ifft(ifftshift(proc.specDiff,1),[],1);
            proc.expt.sf     = proc.spec1.sf;
            proc.expt.sw_h   = proc.spec1.sw_h;
            proc.expt.nspecC = proc.spec1.nspecC;
            if ~SP2_Proc_ExptDataSave
                return
            end
            
            % reset processing options before protocol saving
            % spec 1
            flag.procSpec1Cut    = 0;
            flag.procSpec1Zf     = 1;
            flag.procSpec1Lb     = 0;
            flag.procSpec1Gb     = 0;
            flag.procSpec1Phc0   = 0;
            flag.procSpec1Phc1   = 0;
            flag.procSpec1Scale  = 0;
            flag.procSpec1Shift  = 0;
            flag.procSpec1Offset = 0;
            % spec 2
            flag.procSpec2Cut    = 0;
            flag.procSpec2Zf     = 1;
            flag.procSpec2Lb     = 0;
            flag.procSpec2Gb     = 0;
            flag.procSpec2Phc0   = 0;
            flag.procSpec2Phc1   = 0;
            flag.procSpec2Scale  = 0;
            flag.procSpec2Shift  = 0;
            flag.procSpec2Offset = 0;
            
            % connect fid 2 file path to MM file
            SP2_Proc_DataProcUpdate
            proc.spec2.dataPathMat = exptFilePath;
            set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
            if ~SP2_Proc_Spec2DataPathUpdate
                return
            end
            
            % save SPX protocol
            % note that the values written to file are the ones that were
            % applied before the FIDs were saved, i.e. they are directly visible
            flag.procSpec1Zf   = 1;
            flag.procSpec1Phc0 = 0;             
            data.protPathMat = [scanResultDir 'SPX_sLASER_MM.mat'];
            dataProtPathMat  = data.protPathMat;
            SP2_Exit_ExitFct(data.protPathMat,0)
            INSPECTOR(dataProtPathMat)
        end
    end             % end of sLASER MM
    
    
    %*** DEDICATED sLASER WATER (SCAN 3, 'W_pFC') ***
    % nr/nspecC/nRcvrs: 2+4/2048/32
    for dirCnt = 1:dirLen
%         if any(strfind(dirStruct(dirCnt).name,sprintf('%02i_meas_',numSLaserWater)) & ...
%                strfind(dirStruct(dirCnt).name,'.dat') & ...
%                dirStruct(dirCnt).isdir==0)
        if any(strncmp(dirStruct(dirCnt).name,sprintf('%02i_meas_',numSLaserWater),8) & ...
               strfind(dirStruct(dirCnt).name,'.dat') & ...
               dirStruct(dirCnt).isdir==0)
        
            %--- protocol path handling ---
            SP2_Data_DataMain
            set(fm.data.protPath,'String',spxProt_sLASER_water)
            if ~SP2_Data_ProtocolPathUpdate
                return
            end
            if ~SP2_Data_ProtocolLoad
                return
            end

            % assign 'metabolite' scan
            scanPath = [studyDirPath{sCnt} dirStruct(dirCnt).name];
            set(fm.data.spec1FidFile,'String',scanPath);
            if ~SP2_Data_Dat1FidFileUpdate
                return
            end

            % assign scan series
            set(fm.data.spec1SeriesStr,'String',sprintf('%i %i',numSLaserWater,numSLaserWater));
            if ~SP2_Data_Dat1SeriesUpdate
                return
            end

            % assign water reference scan
            set(fm.data.spec2FidFile,'String',scanPath);
            if ~SP2_Data_Dat2FidFileUpdate
                return
            end

            % load data
            if ~SP2_Data_Dat1SeriesLoad
                return
            end
            if ~SP2_Data_Dat2FidFileLoad
                return
            end

            % frequency and phase alignment
            if ~SP2_Data_Dat1SeriesAlignRegular
                return
            end

            % QA here...

            % data averaging
            if ~SP2_Data_Dat1SeriesSum
                return
            end
            
            % transfer water signal to Processing page
            SP2_Proc_ProcessMain
            flag.procDataFormat = 1;                    % matlab format

            % set up 2 data sets
            set(fm.proc.numSpecTwo,'Value',1);          % 2 data sets
            SP2_Proc_NumSpecTwoUpdate

            % load data set 1 (water) from Data page
            SP2_Proc_DataDataUpdate
            if ~SP2_Proc_DataAndParsAssign1
                return
            end

            % load edit water alignment reference from file to fid 2
            SP2_Proc_DataProcUpdate
            proc.spec2.dataPathMat = sLaserWaterAlignRefPath;
            set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
            if ~SP2_Proc_Spec2DataPathUpdate
                return
            end
            if ~SP2_Proc_DataAndParsAssign2
                return
            end

            % align edit current water ref (fid 1) with alignment reference (fid 2)
            % proc pars
            flag.procSpec1Cut    = 1;
            proc.spec1.cut       = 1800;
            flag.procSpec2Cut    = 1;
            proc.spec2.cut       = 1800;
            flag.procSpec1Zf     = 1;
            proc.spec1.zf        = 8192;
            flag.procSpec2Zf     = 1;
            proc.spec2.zf        = 8192;
            flag.procSpec2Lb     = 1;
            proc.spec2.lb        = 1;
            % align pars
            proc.alignPpmStr     = '0:9';
            flag.procAlignLb     = 1;
            flag.procAlignGb     = 0;
            flag.procAlignPhc0   = 1;
            flag.procAlignPhc1   = 0;
            flag.procAlignScale  = 1;
            flag.procAlignShift  = 1;
            flag.procAlignOffset = 1;
            flag.procAlignPoly   = 0;

            % update alignment windows
            set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
            if ~SP2_Proc_AlignPpmStrUpdate
                return
            end

            % align measured water reference with alignment reference 
            if ~SP2_Proc_AlignSpec1
                return
            end

            % reset processing of data set 1 other than the phasing
            flag.procSpec1Lb     = 0;
            flag.procSpec1Gb     = 0;
            flag.procSpec1Phc1   = 0;
            flag.procSpec1Scale  = 0;
            flag.procSpec1Shift  = 0;
            flag.procSpec1Offset = 0;

            % result scan path handling
            scanResultDir = [studyResultDir{sCnt} '05_sLASER_water\'];
            if ~SP2_CheckDirAccessR(scanResultDir)
                [f_done,msg,msgId] = mkdir(scanResultDir);
                if ~f_done
                    fprintf('scanResultDir sLASER_water, %s\n',msg)
                end
            end

            % explicit data processing: FID 1, FID 2, difference
            flag.procSpec1Zf = 0;
            flag.procSpec2Zf = 0;
            if ~SP2_Proc_ProcComplete
                return
            end                

            % save phased water reference to file 
            exptFilePath = [scanResultDir 'fid_water.mat'];
            set(fm.proc.exptDataPath,'String',exptFilePath);
            if ~SP2_Proc_ExptDataMatUpdate;
                return
            end
            proc.expt.fid    = ifft(ifftshift(proc.spec1.spec,1),[],1);
            proc.expt.sf     = proc.spec1.sf;
            proc.expt.sw_h   = proc.spec1.sw_h;
            proc.expt.nspecC = proc.spec1.nspecC;
            if ~SP2_Proc_ExptDataSave
                return
            end

            % save SPX protocol
            SP2_Proc_DataProcUpdate
            proc.spec1.dataPathMat = exptFilePath;
            set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
            if ~SP2_Proc_Spec1DataPathUpdate
                return
            end

            % save protocol
            % note that the values written to file are the ones that were
            % applied before the FIDs were saved, i.e. they are directly visible
            flag.procSpec1Zf   = 1;
            flag.procSpec1Phc0 = 0;             
            set(fm.proc.numSpecOne,'Value',1);  % 1 data set
            SP2_Proc_NumSpecOneUpdate
            data.protPathMat = [scanResultDir 'SPX_sLASER_water.mat'];
            dataProtPathMat  = data.protPathMat;
            SP2_Exit_ExitFct(data.protPathMat,0)
            INSPECTOR(dataProtPathMat)
        end
    end             % end of sLASER dedicated water 'W_pFC'
    
       
    %*** JDE ***
    scanCnt = 0;                                % scan counter 1..8 for 2 reference and 6 infusion scans
    for jdeCnt = numJdeMetab(1):numJdeMetab(2)  % note that this is the expected file structure/nomenclature!
        % find individual scan in study directory
        for dirCnt = 1:dirLen
%             if any(strfind(dirStruct(dirCnt).name,sprintf('%02i_meas_',jdeCnt)) & ...
%                    strfind(dirStruct(dirCnt).name,'.dat') & ...
%                    dirStruct(dirCnt).isdir==0)
            if any(strncmp(dirStruct(dirCnt).name,sprintf('%02i_meas_',jdeCnt),8) & ...
                   strfind(dirStruct(dirCnt).name,'.dat') & ...
                   dirStruct(dirCnt).isdir==0)
               
                %*** METABOLITES ***
                %--- protocol path handling ---
                SP2_Data_DataMain
                set(fm.data.protPath,'String',spxProt_JDE_metab)
                if ~SP2_Data_ProtocolPathUpdate
                    return
                end
                if ~SP2_Data_ProtocolLoad
                    return
                end
                
                % assign metabolite scan
                scanPath = [studyDirPath{sCnt} dirStruct(dirCnt).name];
                set(fm.data.spec1FidFile,'String',scanPath);
                if ~SP2_Data_Dat1FidFileUpdate
                    return
                end
                
                % assign scan series
                set(fm.data.spec1SeriesStr,'String',sprintf('%i %i',jdeCnt,jdeCnt));
                if ~SP2_Data_Dat1SeriesUpdate
                    return
                end

                % assign reference scan
                set(fm.data.spec2FidFile,'String',scanPath);
                if ~SP2_Data_Dat2FidFileUpdate
                    return
                end
        
                % load data
                if ~SP2_Data_Dat1SeriesLoad
                    return
                end
                if ~SP2_Data_Dat2FidFileLoad
                    return
                end
                
                % frequency and phase alignment
                if ~SP2_Data_Dat1SeriesAlignJde
                    return
                end
                
                % QA here...
                
                % data averaging
                if ~SP2_Data_Dat1SeriesSum
                    return
                end
                
                % transfer JDE conditions to Processing page
                SP2_Proc_ProcessMain
                flag.procDataFormat = 1;                % matlab format
                
                % set up 2 data sets fom Data page
                set(fm.proc.numSpecTwo,'Value',1);      % 2 data sets
                SP2_Proc_NumSpecTwoUpdate
                               
                % load edit OFF from Data page
                SP2_Proc_DataDataUpdate
                if ~SP2_Proc_DataAndParsAssign2
                    return
                end
                
                % load edit OFF alignment reference from file
                SP2_Proc_DataProcUpdate
                proc.spec1.dataPathMat = jdeOffAlignRefPath;
                set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
                if ~SP2_Proc_Spec1DataPathUpdate
                    return
                end
                if ~SP2_Proc_DataAndParsAssign1
                    return
                end
                
                % align edit OFF condition (fid 2) with edit OFF phase reference (fid 1)
                % proc pars
                flag.procSpec1Cut    = 1;
                proc.spec1.cut       = 1800;
                flag.procSpec2Cut    = 1;
                proc.spec2.cut       = 1800;
                flag.procSpec1Zf     = 1;
                proc.spec1.zf        = 8192;
                flag.procSpec2Zf     = 1;
                proc.spec2.zf        = 8192;
                % align pars
                proc.alignPpmStr     = '1.9:4.15';
                flag.procAlignLb     = 1;
                flag.procAlignGb     = 0;
                flag.procAlignPhc0   = 1;
                flag.procAlignPhc1   = 0;
                flag.procAlignScale  = 1;
                flag.procAlignShift  = 1;
                flag.procAlignOffset = 1;
                flag.procAlignPoly   = 0;
                
                % update alignment windows
                set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
                if ~SP2_Proc_AlignPpmStrUpdate
                    return
                end
                
                % align measured edit OFF with OFF alignment reference 
                if ~SP2_Proc_AlignSpec2
                    return
                end
                
                % reset processing of data set 2 other than the phasing
                flag.procSpec2Lb     = 0;
                flag.procSpec2Gb     = 0;
                flag.procSpec2Phc1   = 0;
                flag.procSpec2Scale  = 0;
                flag.procSpec2Shift  = 0;
                flag.procSpec2Offset = 0;
                
                % replace phase reference (fid 1) with edit ON condition
                % from Data page
                SP2_Proc_DataDataUpdate
                if ~SP2_Proc_DataAndParsAssign1
                    return
                end
                                
                % align edit ON condition (fid 1) with phased edit OFF
                % condition (fid 2)
                proc.alignPpmStr = '0:0.7 2.6:2.83 3.15:3.6 3.87:4.2';
                set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
                if ~SP2_Proc_AlignPpmStrUpdate
                    return
                end
                if ~SP2_Proc_AlignSpec1
                    return
                end
                
                % result scan path handling
                scanCnt = scanCnt + 1;
                scanResultDir = [studyResultDir{sCnt} sprintf('%02i_JDE_scan%02i',jdeCnt,scanCnt) '\'];
                if ~SP2_CheckDirAccessR(scanResultDir)
                    [f_done,msg,msgId] = mkdir(scanResultDir);
                    if ~f_done
                        fprintf('scanResultDir %02i, %s\n',jdeCnt,msg)
                    end
                end
                
                % explicit data processing: FID 1, FID 2, difference
                flag.procSpec1Zf = 0;
                flag.procSpec2Zf = 0;
                if ~SP2_Proc_ProcComplete
                    return
                end                
                
                % save JDE ON condition to file 
                exptFilePathON = [scanResultDir 'fid_ON.mat'];
                set(fm.proc.exptDataPath,'String',exptFilePathON);
                if ~SP2_Proc_ExptDataMatUpdate;
                    return
                end
                proc.expt.fid    = ifft(ifftshift(proc.spec1.spec,1),[],1);
                proc.expt.sf     = proc.spec1.sf;
                proc.expt.sw_h   = proc.spec1.sw_h;
                proc.expt.nspecC = proc.spec1.nspecC;
                if ~SP2_Proc_ExptDataSave
                    return
                end
                
                % save JDE OFF condition to file 
                exptFilePathOFF = [scanResultDir 'fid_OFF.mat'];
                set(fm.proc.exptDataPath,'String',exptFilePathOFF);
                if ~SP2_Proc_ExptDataMatUpdate;
                    return
                end
                proc.expt.fid    = ifft(ifftshift(proc.spec2.spec,1),[],1);
                proc.expt.sf     = proc.spec2.sf;
                proc.expt.sw_h   = proc.spec2.sw_h;
                proc.expt.nspecC = proc.spec2.nspecC;
                if ~SP2_Proc_ExptDataSave
                    return
                end
                
                % save JDE difference signal to file 
                exptFilePathDiff = [scanResultDir 'fid_diff.mat'];
                set(fm.proc.exptDataPath,'String',exptFilePathDiff);
                if ~SP2_Proc_ExptDataMatUpdate;
                    return
                end
                proc.expt.fid    = ifft(ifftshift(proc.specDiff,1),[],1);
                proc.expt.sf     = proc.spec1.sf;
                proc.expt.sw_h   = proc.spec1.sw_h;
                proc.expt.nspecC = proc.spec1.nspecC;
                if ~SP2_Proc_ExptDataSave
                    return
                end
                
                % save scan-specific SPX protocol of individual JDE
                % conditions
                SP2_Proc_DataProcUpdate
                proc.spec1.dataPathMat = exptFilePathON;
                set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
                if ~SP2_Proc_Spec1DataPathUpdate
                    return
                end
                proc.spec2.dataPathMat = exptFilePathOFF;
                set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
                if ~SP2_Proc_Spec2DataPathUpdate
                    return
                end

                % save protocol
                flag.procSpec1Zf   = 1;
                flag.procSpec2Zf   = 1;
                flag.procSpec1Phc0 = 0;         % note that the values written to file are the ones that were
                flag.procSpec2Phc0 = 0;         % applied before the FIDs were saved, i.e. they are directly visible
                data.protPathMat = [scanResultDir 'SPX_JDE_GABA.mat'];
                dataProtPathMat  = data.protPathMat;
                SP2_Exit_ExitFct(data.protPathMat,0)
                INSPECTOR(dataProtPathMat)
      
                
                %*** WATER ***               
                %--- protocol path handling ---
                SP2_Data_DataMain
                set(fm.data.protPath,'String',spxProt_JDE_water)
                if ~SP2_Data_ProtocolPathUpdate
                    return
                end
                if ~SP2_Data_ProtocolLoad
                    return
                end

                % assign metabolite scan
                scanPath = [studyDirPath{sCnt} dirStruct(dirCnt).name];
                set(fm.data.spec1FidFile,'String',scanPath);
                if ~SP2_Data_Dat1FidFileUpdate
                    return
                end
                
                % assign scan series
                set(fm.data.spec1SeriesStr,'String',sprintf('%i %i',jdeCnt,jdeCnt));
                if ~SP2_Data_Dat1SeriesUpdate
                    return
                end

                % assign reference scan
                set(fm.data.spec2FidFile,'String',scanPath);
                if ~SP2_Data_Dat2FidFileUpdate
                    return
                end
        
                % load data
                if ~SP2_Data_Dat1SeriesLoad
                    return
                end
                if ~SP2_Data_Dat2FidFileLoad
                    return
                end
                                
                % QA here...
                
                % data averaging
                if ~SP2_Data_Dat2ExtractWater;
                    return
                end
                
                % transfer water signal to Processing page
                SP2_Proc_ProcessMain
                flag.procDataFormat = 1;                    % matlab format
                
                % set up 2 data sets
                set(fm.proc.numSpecTwo,'Value',1);          % 2 data sets
                SP2_Proc_NumSpecTwoUpdate
                               
                % load data set 1 (water) from Data page
                SP2_Proc_DataDataUpdate
                if ~SP2_Proc_DataAndParsAssign1
                    return
                end
                
                % load edit water alignment reference from file to fid 2
                SP2_Proc_DataProcUpdate
                proc.spec2.dataPathMat = jdeWaterAlignRefPath;
                set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
                if ~SP2_Proc_Spec2DataPathUpdate
                    return
                end
                if ~SP2_Proc_DataAndParsAssign2
                    return
                end
                
                % align edit current water ref (fid 1) with alignment reference (fid 2)
                % proc pars
                flag.procSpec1Cut    = 1;
                proc.spec1.cut       = 1800;
                flag.procSpec2Cut    = 1;
                proc.spec2.cut       = 1800;
                flag.procSpec1Zf     = 1;
                proc.spec1.zf        = 8192;
                flag.procSpec2Zf     = 1;
                proc.spec2.zf        = 8192;
                flag.procSpec2Lb     = 1;
                proc.spec2.lb        = 1;
                % align pars
                proc.alignPpmStr     = '3:6.3';
                flag.procAlignLb     = 1;
                flag.procAlignGb     = 0;
                flag.procAlignPhc0   = 1;
                flag.procAlignPhc1   = 0;
                flag.procAlignScale  = 1;
                flag.procAlignShift  = 1;
                flag.procAlignOffset = 1;
                flag.procAlignPoly   = 0;
                
                % update alignment windows
                set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
                if ~SP2_Proc_AlignPpmStrUpdate
                    return
                end
                
                % align measured water reference with alignment reference 
                if ~SP2_Proc_AlignSpec1
                    return
                end
                
                % reset processing of data set 1 other than the phasing
                flag.procSpec1Lb     = 0;
                flag.procSpec1Gb     = 0;
                flag.procSpec1Phc1   = 0;
                flag.procSpec1Scale  = 0;
                flag.procSpec1Shift  = 0;
                flag.procSpec1Offset = 0;
                                
                % result scan path handling
%                 scanResultDir = [studyResultDir{sCnt} sprintf('%02i_JDE_scan%02i',jdeCnt,scanCnt) '\'];
                
                % explicit data processing: FID 1, FID 2, difference
                flag.procSpec1Zf = 0;
                flag.procSpec2Zf = 0;
                if ~SP2_Proc_ProcComplete
                    return
                end                
                
                % save phased water reference to file 
                exptFilePath = [scanResultDir 'fid_water.mat'];
                set(fm.proc.exptDataPath,'String',exptFilePath);
                if ~SP2_Proc_ExptDataMatUpdate;
                    return
                end
                proc.expt.fid    = ifft(ifftshift(proc.spec1.spec,1),[],1);
                proc.expt.sf     = proc.spec1.sf;
                proc.expt.sw_h   = proc.spec1.sw_h;
                proc.expt.nspecC = proc.spec1.nspecC;
                if ~SP2_Proc_ExptDataSave
                    return
                end
                
                % save SPX protocol
                SP2_Proc_DataProcUpdate
                proc.spec1.dataPathMat = exptFilePath;
                set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
                if ~SP2_Proc_Spec1DataPathUpdate
                    return
                end

                % save protocol
                % note that the values written to file are the ones that were
                % applied before the FIDs were saved, i.e. they are directly visible
                flag.procSpec1Zf   = 1;
                flag.procSpec1Phc0 = 0;             
                set(fm.proc.numSpecOne,'Value',1);  % 1 data set
                SP2_Proc_NumSpecOneUpdate
                data.protPathMat = [scanResultDir 'SPX_JDE_water.mat'];
                dataProtPathMat  = data.protPathMat;
                SP2_Exit_ExitFct(data.protPathMat,0)
                INSPECTOR(dataProtPathMat)
            end
        end
    end             % end of JDE water
end             % end of study loop

%--- info printout ---
fprintf('%s completed.\n',FCTNAME)


