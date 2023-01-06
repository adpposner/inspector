%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [encVec,f_succ] = SP2_MRSI_ReadEncTableFromFile(filePath)
%% 
%%  Load phase encoding scheme from file.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_ReadEncTableFromFile';


%--- init success flag ---
f_succ = 0;

%--- read table from file ---
[fileId,msg] = fopen(filePath,'r');
if fileId==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end

%--- read table from file ---
encCnt = 0;                % init encoding counter: read
encVec = 0;                % encoding vector
if (fileId > 0)
    while (~feof(fileId))
        tline = fgetl(fileId);
        if ~isempty(tline)                      % check existence
            if isempty(strfind(tline,'='))      % not the 1st line
                encCnt = encCnt+1;
                encVec(encCnt) = str2double(tline);
            end
        end
    end
    fclose(fileId);
else
    fprintf('%s -> <%s> exists but can not be opened...\n',FCTNAME,filePathR);
end

%--- update success flag ---
f_succ = 1;

end
