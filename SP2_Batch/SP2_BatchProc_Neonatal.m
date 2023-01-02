%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  function SP2_BatchProc_Neonatal
%%
%%  Serial data processing of neonatal MRS, collaboration with Marisa Spann
%% 
%%  Note that the function assumes a windows system, INSPECTOR running and
%%  predefined protocol files for regular sLASER (defining the appropriate
%%  parameter settings and flags).
%%
%%  07-2021, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag mm proc fm data

FCTNAME = 'SP2_BatchProc_Neonatal';


dataDir   = 'C:\Users\juchem\Data\GE_MarisaSpann\02_Neonatal_22Jul2021\';                         % raw data directory
resultDir = 'C:\Users\juchem\Data\GE_MarisaSpann\02_Neonatal_22Jul2021\Neonatal_Proc\';             % result directory

studyRg   = 1:17;         % study range vector



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
if SP2_CheckFileExistenceR([resultDir 'SPX_Neonatal_sLASER_metab.mat'])
    spxProt_sLASER_metab = [resultDir 'SPX_Neonatal_sLASER_metab.mat'];
else
    return
end
if SP2_CheckFileExistenceR([resultDir 'SPX_Neonatal_sLASER_water.mat'])
    spxProt_sLASER_water = [resultDir 'SPX_Neonatal_sLASER_water.mat'];
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
for studyCnt = 1:length(studyRg)
    for dCnt = 1:dataDirLen
        if any(strfind(dataDirStruct(dCnt).name,sprintf('Neonatal_%03i_',studyRg(studyCnt))) & dataDirStruct(dCnt).isdir==1);
            if SP2_CheckDirAccessR([dataDir dataDirStruct(dCnt).name '\'])
                studyVec(length(studyDirName)+1)     = studyRg(studyCnt);               % (effective) study numbers
                studyDirName{length(studyDirName)+1} = dataDirStruct(dCnt).name;        % study directories
                studyDirPath{length(studyDirPath)+1} = [dataDir dataDirStruct(dCnt).name '\'];  % study names
            end
        end
    end
end
studyN = length(studyVec);          % (effective) number of studies
if studyVec==0
    fprintf('No neonatal data found. Program aborted.\n')
    return
end

%--- create result directory ---
studyResultDir = {};
for studyCnt = 1:studyN
    studyResultDir{studyCnt} = [resultDir sprintf('LCModel_%03i',studyVec(studyCnt)) '\'];
    if ~SP2_CheckDirAccessR(studyResultDir{studyCnt})
        [f_done,msg,msgId] = mkdir(studyResultDir{studyCnt});
        if ~f_done
            fprintf('LCModel_%03i, %s\n',studyVec(studyCnt),msg)
        end
    end
end

% init overall batch script creation
f_batchOverall = 0;             % overall batch script over all sessions (i.e. babies) and scans; not initiated yet

%--- serial SPX data processing analysis ---
for studyCnt = 1:studyN
    %--- info printout ---
    fprintf('\n\nSTUDY %s (%i of %i)\n\n',studyDirName{studyCnt},studyCnt,studyN)
    
    % files/directories in selected session
    dirStruct = dir(studyDirPath{studyCnt});
    dirLen    = length(dirStruct);
    
    % init session-specific batch script creation
    f_batchSession = 0;             % 1 script per session, i.e. baby; not initiated yet
    
    % dirCnt is counter over individual directory elements including
    % individual experiments, i.e. scans.
    for scanCnt = 1:dirLen              % note that this is the expected file structure/nomenclature!
        for dirCnt = 1:dirLen           % search for given scan number across all directory elements
            if any(strfind(dirStruct(dirCnt).name,sprintf('%02i_E',scanCnt))) && ...
               ~any(strfind(dirStruct(dirCnt).name,sprintf('_%02i_E',scanCnt))) && ...
               any(strfind(dirStruct(dirCnt).name,'.7')) && ...
               dirStruct(dirCnt).isdir==0

                % experiment name / identifier
                scanName = dirStruct(dirCnt).name(1:end-2);     % 03_E1996_P60416 (with .7 removed)
           
                %*** sLASER METABOLITES ***
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
                scanPath = [studyDirPath{studyCnt} dirStruct(dirCnt).name];
                set(fm.data.spec1FidFile,'String',scanPath);
                if ~SP2_Data_Dat1FidFileUpdate
                    return
                end

                % assign scan series
                set(fm.data.spec1SeriesStr,'String',sprintf('%i %i',scanCnt,scanCnt));
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

                % transfer metabolite scan to Processing page
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

                % load alignment reference from file
                SP2_Proc_DataProcUpdate
                proc.spec2.dataPathMat = sLaserMetabAlignRefPath;
                set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
                if ~SP2_Proc_Spec2DataPathUpdate
                    return
                end
                if ~SP2_Proc_DataAndParsAssign2
                    return
                end

                % align current metabolite spectrum with metabolite reference
                flag.procSpec1Cut    = 1;
                proc.spec1.cut       = 2048;
                flag.procSpec2Cut    = 1;
                proc.spec2.cut       = 2048;
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
                % scanResultDir = [studyResultDir{studyCnt} sprintf('%03i_sLASER_metab',scanCnt) '\'];
                scanResultDir = studyResultDir{studyCnt};
                if ~SP2_CheckDirAccessR(scanResultDir)
                    [f_done,msg,msgId] = mkdir(scanResultDir);
                    if ~f_done
                        fprintf('scanResultDir sLASER (metab), %s\n',msg)
                    end
                end            

                % explicit data processing: FID 1, FID 2, difference
                flag.procSpec1Cut = 0;
                flag.procSpec2Cut = 0;
                flag.procSpec1Zf  = 0;
                flag.procSpec2Zf  = 0;
                if ~SP2_Proc_ProcComplete
                    return
                end                

                % save phased sLASER metabolite spectrum to file 
                exptFilePath = [scanResultDir sprintf('%s_metab.mat',scanName)];
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
                lcmDir = '/home/mrs2/Neonatal/';        % default neonatal study directory on mrs2@129.236.160.50
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
                flag.procSpec1Cut  = 1;
                flag.procSpec1Zf   = 1;
                flag.procSpec1Phc0 = 0;             
                set(fm.proc.numSpecOne,'Value',1);  % 1 data set
                SP2_Proc_NumSpecOneUpdate
                data.protPathMat = [scanResultDir sprintf('%s_SPX_metab.mat',scanName)];
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
                scanPath = [studyDirPath{studyCnt} dirStruct(dirCnt).name];
                set(fm.data.spec1FidFile,'String',scanPath);
                if ~SP2_Data_Dat1FidFileUpdate
                    return
                end
                
                % assign scan series
                set(fm.data.spec1SeriesStr,'String',sprintf('%i %i',scanCnt,scanCnt));
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

                % load water alignment reference from file to fid 2
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
                scanResultDir = studyResultDir{studyCnt};
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

                % save phased sLASER water spectrum to file 
                exptFilePath = [scanResultDir sprintf('%s_h2o.mat',scanName)];
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
                data.protPathMat = [scanResultDir sprintf('%s_SPX_h2o.mat',scanName)];
                dataProtPathMat  = data.protPathMat;
                SP2_Exit_ExitFct(data.protPathMat,0)
                INSPECTOR(dataProtPathMat)
       
            end
        end             % end of dirCnt
    end             % end of scanCnt
end             % end of study loop

%--- info printout ---
fprintf('%s completed.\n',FCTNAME)


