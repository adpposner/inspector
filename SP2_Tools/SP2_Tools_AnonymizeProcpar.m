%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Tools_AnonymizeProcpar(filePath)
%% 
%%  Perform anonymization of procpar parameter file.
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Tools_AnonymizeProcpar';


%--- init success flag ---
f_succ = 0;

%--- path handling ---
[fileDir, fileName, f_succ] = SP2_ExtractFileDirAndName(filePath);
if ~f_succ
    return
end

%--- consistency check ---
if ~SP2_CheckDirAccess(fileDir)
    return
end
if ~SP2_CheckFileExistence(filePath)
    return
end

%--- load original parameter file ---
fidOrig = fopen(filePath,'r');
if fidOrig>0
    %--- create duplicate file ---
    randId = num2str(round(1e10*now));
    filePathTmp = [fileDir fileName sprintf('_%s',randId)];

    %--- file handling of temporary file ---
    fidTmp = fopen(filePathTmp,'w');
    if fidTmp==-1
        fprintf('%s ->\nOpening temporary file for anonymization failed. Program aborted.\n',FCTNAME);
        return
    end
    
    %--- read from original and write to temporary
    while ~feof(fidOrig)
        tline = fgetl(fidOrig);
        %if isempty(strfind(tline,'/home/')) 
        fprintf(fidTmp,'%s\n',tline);         
        %end
        if ~isempty(strfind(tline,'date')) || ~isempty(strfind(tline,'time')) || ...
           ~isempty(strfind(tline,'name')) || ~isempty(strfind(tline,'studyid')) || ...
           ~isempty(strfind(tline,'patient')) || ~isempty(strfind(tline,'subject'))
            if length(tline)>5
                if strcmp(tline(1:5),'date ')
                    fprintf(fidTmp,'1 "Dec 31 1999"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>13
                if strcmp(tline(1:13),'time_svfdate ')
                    fprintf(fidTmp,'1 "19991231T010101"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>9
                if strcmp(tline(1:9),'time_run ')
                    fprintf(fidTmp,'1 "19991231T010101"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>14
                if strcmp(tline(1:14),'time_complete ')
                    fprintf(fidTmp,'1 "19991231T010101"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>13
                if strcmp(tline(1:13),'time_plotted ')
                    fprintf(fidTmp,'1 "19991231T010101"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>15
                if strcmp(tline(1:15),'time_processed ')
                    fprintf(fidTmp,'1 "19991231T010101"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>15
                if strcmp(tline(1:15),'time_submitted ')
                    fprintf(fidTmp,'1 "19991231T010101"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>11
                if strcmp(tline(1:11),'time_saved ')
                    fprintf(fidTmp,'1 "19991231T010101"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>21
                if strcmp(tline(1:21),'time_submitted_local ')
                    fprintf(fidTmp,'1 "19991231T010101"\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>18
                if strcmp(tline(1:18),'filenameMrsB1Shim ')
                    fprintf(fidTmp,'1 ""\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>18
                if strcmp(tline(1:18),'filenameOvsB1Shim ')
                    fprintf(fidTmp,'1 ""\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>9
                if strcmp(tline(1:9),'studyid_ ')
                    fprintf(fidTmp,'1 ""\n');         
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end
            if length(tline)>6
                if strcmp(tline(1:6),'study ')
                    fprintf(fidTmp,'1 ""\n');
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end     
            if length(tline)>8
                if strcmp(tline(1:8),'pslabel ')
                    fprintf(fidTmp,'1 ""\n');
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end  
            if length(tline)>11
                if strcmp(tline(1:11),'filenameRF ')
                    fprintf(fidTmp,'1 ""\n');
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end  
            if length(tline)>12
                if strcmp(tline(1:12),'filenameOVS ')
                    fprintf(fidTmp,'1 ""\n');
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end  
            if length(tline)>11
                if strcmp(tline(1:11),'filenameWS ')
                    fprintf(fidTmp,'1 ""\n');
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end  
            if length(tline)>8
                if strcmp(tline(1:8),'exppath ')
                    fprintf(fidTmp,'1 ""\n');
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end  
            if length(tline)>7
                if strcmp(tline(1:7),'path3d ')
                    fprintf(fidTmp,'1 ""\n');
                    fgetl(fidOrig);         % skip next line (containing the info)         
                end
            end  
        end
    end
    fclose(fidOrig);
    fclose(fidTmp);
else
    fprintf('Opening original parameter file failed. Program aborted.\n');
    return
end

%--- remove orig and rename new ---
delete(filePath)
[f_done,msg,msgId] = movefile(filePathTmp,filePath);
if ~f_done
    fprintf('%s -> Renaming the temporary parameter file failed:\n',FCTNAME);
    fprintf('%s\n',filePath);
    fprintf('%s\nProgram aborted.\n',msg);
    return
end

%--- update success flag ---
f_succ = 1;


end
