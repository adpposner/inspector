%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_BatchTable2Xls_Neonatal
%%
%%  Serial extraction of LCModel outputs from .table files and saving to 
%%  newly created summary xls file for further analysis. 
%%
%%  07-2021, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_BatchTable2Xls_Neonatal';

resultDir = 'C:\Users\juchem\Data\GE_MarisaSpann\02_Neonatal_22Jul2021\Neonatal_Proc\';             % result directory



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- consistency checks ---
if ~SP2_CheckDirAccessR(resultDir)
    return
end

%--- path and data handling  ---
resultDirStruct = dir(resultDir);
resultDirLen    = length(resultDirStruct);
resultCell      = {};
for dCnt = 1:resultDirLen               % for all elements found in directory
    for studyCnt = 1:999
        if strcmp(resultDirStruct(dCnt).name,sprintf('LCModel_%03i',studyCnt)) && ...
           resultDirStruct(dCnt).isdir==1
            if SP2_CheckDirAccessR([resultDir resultDirStruct(dCnt).name '\'])
                % overall study info
                cellElement = length(resultCell)+1;
                resultCell{cellElement}.studyName      = resultDirStruct(dCnt).name;
                resultCell{cellElement}.studyNumber    = studyCnt;
                resultCell{cellElement}.studyPath      = [resultDir resultDirStruct(dCnt).name '\'];
                
                % individual scans and tables within a study
                tableStructTmp                         = dir(fullfile(resultCell{cellElement}.studyPath,'*.table'));
                resultCell{cellElement}.scans          = length(tableStructTmp);
                for scanCnt = 1:resultCell{cellElement}.scans
                    resultCell{cellElement}.scanTables{scanCnt}     = tableStructTmp(scanCnt).name;
                    resultCell{cellElement}.scanTablePaths{scanCnt} = [resultCell{cellElement}.studyPath tableStructTmp(scanCnt).name];
                    resultCell{cellElement}.scanNames{scanCnt}      = resultCell{cellElement}.scanTables{scanCnt}(1:end-6);
                    resultCell{cellElement}.scanCsvPaths{scanCnt}   = [resultCell{cellElement}.scanTablePaths{scanCnt}(1:end-6) '.csv'];
                    if ~SP2_CheckFileExistenceR(resultCell{cellElement}.scanCsvPaths{scanCnt})
                        return
                    end
                    resultCell{cellElement}.scanDumpPaths{scanCnt}  = [resultCell{cellElement}.scanTablePaths{scanCnt}(1:end-6) '.dump'];
                    if ~SP2_CheckFileExistenceR(resultCell{cellElement}.scanDumpPaths{scanCnt})
                        return
                    end
                end                
            end
        end
    end
end
if ~exist('cellElement','var')
    fprintf('No LCModel results found. Program aborted.\n')
    return
elseif cellElement<=0
    fprintf('No LCModel results found. Program aborted.\n')
    return
end
studyN = cellElement;          % number of studies

%--- info printout ---
fprintf('Writing LCModel results to xls file started...\n')

% total number of scans, i.e. analyses
totN = 0;
for studyCnt = 1:studyN
    totN = totN + resultCell{studyCnt}.scans;
end

%--- serial SPX data processing analysis ---
totCnt = 0;             % total analysis counter
for studyCnt = 1:studyN
    for scanCnt = 1:resultCell{studyCnt}.scans
        % total analysis counter
        totCnt = totCnt + 1;
        
        %--- info printout ---
        fprintf('Study %s (%i of %i), scan %i (of %i), total %i (of %i)\n',...
                resultCell{studyCnt}.studyName,studyCnt,studyN,scanCnt,...
                resultCell{studyCnt}.scans,totCnt,totN)
    
        % read LCModel output
        tableCont = Loc_ReadTableFile(resultCell{studyCnt}.scanTablePaths{scanCnt});
        
        % creation of LCModel summary xls file
        if studyCnt==1 && scanCnt==1        % 1st scan of 1st study
            %--- consistency checks and path handling ---
            if ~SP2_CheckDirAccessR(resultDir)
                fprintf('Directory for xls summary file is not accessible. Program aborted.\n')
                return
            else
                xlsPath = [resultDir 'LCModel_Summary.xls'];
            end

            %--- delete old result file ---
            % note that this only works if the file is closed
            if exist(xlsPath,'file')
                delete(xlsPath)
            end

            %--- write labels to result page ---
            xlswrite(xlsPath,{'Summary of LCModel Batch Analysis'},'LCModel summary','A1');
            xlswrite(xlsPath,{sprintf('created %s',datestr(now))},'LCModel summary','A2');
            xlswrite(xlsPath,{'Data','FWHM','S/N'},'LCModel summary','A5');
            nMetab = length(tableCont.conc)-1;
            % metabolite labels
            cell2write = {'','',''};                % all metabolites (at once)
            cellLen    = length(cell2write);
            for mCnt = 1:nMetab
                for entryCnt = 1:3
                    cellLen = cellLen+1;
                    cell2write{cellLen} = tableCont.conc{mCnt+1}{4};
                end
            end
            xlswrite(xlsPath,cell2write,'LCModel summary','A4');
            % result labels
            cell2write = {'Data','FWHM','S/N'};     % all result values (at once)
            cellLen    = length(cell2write);
            for mCnt = 1:nMetab
                cellLen = cellLen+1;
                cell2write{cellLen} = 'Conc.';
                cellLen = cellLen+1;
                cell2write{cellLen} = '%SD';
                cellLen = cellLen+1;
                cell2write{cellLen} = '/Cr';
            end
            xlswrite(xlsPath,cell2write,'LCModel summary','A5');
            % init data counter
            rowCnt = 5;
        end

        % consistency check 
        if nMetab~=length(tableCont.conc)-1
            fprintf('\nInconsistent result format detected:\n')
            frpintf('nMetab=%.0f ~= length(tableCont.conc)-1=%.0f\nProgram aborted.\n\n',...
                    nMetab,length(tableCont.conc)-1)
        end
        
        % results
        rowCnt        = rowCnt + 1;             % row position in xls file
        cell2write    = {};
        cell2write{1} = tableCont.TITLE;
        cell2write{2} = tableCont.FWHM;
        cell2write{3} = tableCont.SNR;
        cellLen    = length(cell2write);
        for mCnt = 1:nMetab
            cellLen = cellLen+1;
            cell2write{cellLen} = tableCont.conc{mCnt+1}{1};
            cellLen = cellLen+1;
            cell2write{cellLen} = tableCont.conc{mCnt+1}{2};
            cellLen = cellLen+1;
            cell2write{cellLen} = tableCont.conc{mCnt+1}{3};
        end
        xlswrite(xlsPath,cell2write,'LCModel summary',sprintf('A%d',rowCnt));
    end
end             % end of study loop

%--- info printout ---
fprintf('%s completed.\n',FCTNAME)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     L O C A L    F U N C T I O N S                                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tableCont = Loc_ReadTableFile(tableFilePath)

%--- load LCModel result from file ---
tableCont = {};
fid = fopen(tableFilePath,'r');
if fid > 0
    while ~feof(fid)
        tline = fgetl(fid);
        if ~isempty(tline)
            % title
            if any(strfind(tline,'LCModel (Version')) && any(strfind(tline,')'))
                tableCont.TITLE = fgetl(fid);
            end
            
            % concentrations etc.
            if any(strfind(tline,'$$CONC')) && any(strfind(tline,'='))
                % number or result lines
                [fake,b] = strtok(tline);
                [numStr,b] = strtok(b);
                nLines = str2double(numStr);
                
                % result cell
                % format: conc., %SD, /Cr, Metabolite
                for tabCnt = 1:nLines
                    tline = fgetl(fid);
                    [tableCont.conc{tabCnt}{1},b] = strtok(tline);
                    [tableCont.conc{tabCnt}{2},b] = strtok(b);
                    if tabCnt>1
                        tableCont.conc{tabCnt}{2} = tableCont.conc{tabCnt}{2}(1:end-1);   % remove %
                    end
                    [tableCont.conc{tabCnt}{3},b] = strtok(b);
                    [tableCont.conc{tabCnt}{4},b] = strtok(b);
                end
            end
            
            % misc. info
            if any(strfind(tline,'$$MISC')) && any(strfind(tline,'misc.'))
                % number or misc lines
                [fake,b] = strtok(tline);
                [numStr,b] = strtok(b);
                nLines = str2double(numStr);
                
                % misc info
                for tabCnt = 1:nLines
                    tline = fgetl(fid);
                    tableCont.misc{tabCnt} = tline;
                    
                    % specific info
                    if any(strfind(tline,'FWHM = ')) && any(strfind(tline,'S/N = '))
                        equInd = strfind(tline,'=');
                        ppmInd = strfind(tline,'ppm');
                        tableCont.FWHM = str2double(tline(equInd(1)+1:ppmInd(1)-1));
                        tableCont.SNR  = str2double(tline(equInd(2)+1:end));
                    end
                end
            end  
            
            % diagnostic info
            if any(strfind(tline,'$$DIAG')) && any(strfind(tline,'diagnostic'))
                % number or diagnostic lines
                [fake,b] = strtok(tline);
                [numStr,b] = strtok(b);
                nLines = str2double(numStr);
                
                % diagnostic info
                for tabCnt = 1:nLines
                    tline = fgetl(fid);
                    tableCont.diag{tabCnt} = tline;
                end
            end
            
            % input info
            if any(strfind(tline,'$$INPU')) && any(strfind(tline,'input'))
                % number or input lines
                [fake,b] = strtok(tline);
                [numStr,b] = strtok(b);
                nLines = str2double(numStr);
                
                % input info
                for tabCnt = 1:nLines
                    tline = fgetl(fid);
                    tableCont.input{tabCnt} = tline;
                    
                    % specific info
                    if any(strfind(tline,'HZPPPM')) && any(strfind(tline,'='))
                        [a,b]=strtok(tline,'=');
                        [a,b]=strtok(b,'=');
                        tableCont.HZPPPM = str2double(a);
                    end
                    if any(strfind(tline,'DELTAT')) && any(strfind(tline,'='))
                        [a,b]=strtok(tline,'=');
                        [a,b]=strtok(b,'=');
                        tableCont.DELTAT = str2double(a);
                    end
                    if any(strfind(tline,'PPMST')) && any(strfind(tline,'='))
                        [a,b]=strtok(tline,'=');
                        [a,b]=strtok(b,'=');
                        tableCont.PPMST = str2double(a);
                    end
                    if any(strfind(tline,'PPMEND')) && any(strfind(tline,'='))
                        [a,b]=strtok(tline,'=');
                        [a,b]=strtok(b,'=');
                        tableCont.PPMEND = str2double(a);
                    end
%                     if any(strfind(tline,'FILRAW')) && any(strfind(tline,'='))
%                         [a,b]=strtok(tline,'=');
%                         [tableCont.FILRAW,b]=strtok(b,'=');
%                         tline = fgetl(fid);
%                         if isempty(strfind(tline,'='))
%                             tableCont.FILRAW = [tableCont.FILRAW tline];
%                         end
%                     end
%                     if any(strfind(tline,'FILBAS')) && any(strfind(tline,'='))
%                         [a,b]=strtok(tline,'=');
%                         [tableCont.FILBAS,b]=strtok(b,'=');
%                         if isempty(strfind(tline,'='))
%                             tableCont.FILBAS = [tableCont.FILBAS tline];
%                         end
%                     end
                end
            end
            
            % FWHM in [Hz]
            if isfield(tableCont,'HZPPM')
                tableCont.FWHM_hz = tableCont.FWHM * tableCont.tableCont.HZPPM;
            end
        end
    end
    fclose(fid);
else
    fprintf('%s -> <%s> exists but can not be opened...\n',tableFilePath);
end








