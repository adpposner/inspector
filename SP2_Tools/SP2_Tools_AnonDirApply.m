%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Tools_AnonDirApply
%% 
%%  Perform anonymization for all data / scans in the selected directory.
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile tools

FCTNAME = 'SP2_Tools_AnonDirApply';


%--- init success flag ---
f_succ = 0;

%--- check directory access ---
[f_succ,maxPath] = SP2_CheckDirAccessR(tools.anonDir);
if ~f_succ
    if isempty(maxPath)
        if ispc
            tools.anonDir = 'C:\';
        elseif ismac
            tools.anonDir = '/Users/';
        else
            tools.anonDir = '/home/';
        end
    else
        if ispc
            tools.anonDir = [maxPath '\'];
        else
            tools.anonDir = [maxPath '/'];
        end
    end
end

%--- retrieve all files ---
totFileCell = SP2_FindAllFiles(tools.anonDir);

%--- find files and perform anonymization ---
aCnt   = 0;       % anonymization counter
lCnt   = 0;       % log file deletion counter
tCnt   = 0;       % text file deletion counter
fidCnt = 0;       % fid data file counter
for fCnt = 1:length(totFileCell)
    %--- anonymize 'procpar' files ---
    if strcmp(SP2_ExtractFileName(totFileCell{fCnt}),'procpar') 
        aCnt = aCnt + 1;
        if SP2_Tools_AnonymizeProcpar(totFileCell{fCnt})
            fprintf('<%s> anonymized\n',totFileCell{fCnt});
        else
            fprintf('Anonymization failed for file:\n%s\n\n',totFileCell{fCnt});
            return
        end
    end
    
    %--- delete 'log' files ---
    if strcmp(SP2_ExtractFileName(totFileCell{fCnt}),'log') 
        lCnt = lCnt + 1;
        delete(totFileCell{fCnt})
        fprintf('<%s> deleted\n',totFileCell{fCnt});
    end
    
    %--- delete 'text' files ---
    % (although not truly necessary as typically does not containanything)
    if strcmp(SP2_ExtractFileName(totFileCell{fCnt}),'text') 
        tCnt = tCnt + 1;
        delete(totFileCell{fCnt})
        fprintf('<%s> deleted\n',totFileCell{fCnt});
    end
    
    %--- effectively touch 'fid' file ---
    if strcmp(SP2_ExtractFileName(totFileCell{fCnt}),'fid') 
        fidCnt = fidCnt + 1;

        %--- read 1st byte and write back to file ---
        fid = fopen(totFileCell{fCnt},'r+');
        byte = fread(fid,1);
        fseek(fid,0,'bof');
        fwrite(fid,byte);
        fclose(fid);

%         %--- create duplicate file ---
%         randId = num2str(round(1e9*now));
%         fidPathTmp = [totFileCell{fCnt} sprintf('_%s',randId)];
%         [f_done,msg,msgId] = movefile(totFileCell{fCnt},fidPathTmp);
%         if ~f_done
%             fprintf('\nCreation of temporary copy of fid file failed:\n');
%             fprintf('Orig: %s\n',totFileCell{fCnt});
%             fprintf('Tmp:  %s\n',fidPathTmp);
%             fprintf('Msg: %s\nProgram aborted.\n',msg);
%             return
%         end
%                 
%         %--- delete original file and replace by temporary file ---
%         delete(totFileCell{fCnt})
%         [f_done,msg,msgId] = copyfile(fidPathTmp,totFileCell{fCnt});
%         if ~f_done
%             fprintf('\nCopying of temporary copy back to fid file failed:\n');
%             fprintf('Tmp:  %s\n',fidPathTmp);
%             fprintf('Orig: %s\n',totFileCell{fCnt});
%             fprintf('Msg: %s\nProgram aborted.\n',msg);
%             return
%         end
%         delete(fidPathTmp)
        
        %--- info printout ---
        fprintf('<%s> touched\n',totFileCell{fCnt});
    end
end

%--- info printout ---
fprintf('\n%s successfully completed:\n1) %.0f <procpar> files anonymized\n',FCTNAME,aCnt);
fprintf('2) %.0f <log> files deleted\n3) %.0f <text> files deleted\n',lCnt,tCnt);
fprintf('4) %.0f <fid> time stamps updated\n\n',fidCnt);

%--- update success flag ---
f_succ = 1;

