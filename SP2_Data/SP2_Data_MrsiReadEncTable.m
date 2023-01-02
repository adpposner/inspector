%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [specMrsi, f_done] = SP2_Data_MrsiReadEncTable(specMrsi)
%% 
%%  Function to load MRSI encoding table from file.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_MrsiReadEncTable';


%--- table directory ---
tablib = 'C:\Users\juchem\Matlab\matlab_cj\INSPECTOR_v2\SP2_MRSI\SP2_MRSI_Tablib\';

%--- check data access ---
if ~SP2_CheckDirAccessR(tablib)
    return
end
filePathR = sprintf('%s%s.txt',tablib,specMrsi.encFileR);
filePathP = sprintf('%s%s.txt',tablib,specMrsi.encFileP);
if ~SP2_CheckFileExistenceR(filePathR)
    return
end
if ~SP2_CheckFileExistenceR(filePathP)
    return
end

%--- open table files ---
[fileIdR,msg] = fopen(filePathR,'r');
if fileIdR==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end
[fileIdP,msg] = fopen(filePathP,'r');
if fileIdP==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end

%--- read <read> table from file ---
encCntR = 0;                    % init encoding counter: read
specMrsi.encTableR = 0;         % encoding vector
if (fileIdR > 0)
    while (~feof(fileIdR))
        tline = fgetl(fileIdR);
        if ~isempty(tline)                      % check existence
            if isempty(strfind(tline,'='))      % not the 1st line
                encCntR = encCntR+1;
                specMrsi.encTableR(encCntR) = str2double(tline);
            end
        end
    end
    fclose(fileIdR);
else
    fprintf('%s -> <%s> exists but can not be opened...\n',FCTNAME,filePathR);
end

%--- read <phase> table from file ---
encCntP = 0;                % init encoding counter: read
specMrsi.encTableP = 0;                % encoding vector
if (fileIdP > 0)
    while (~feof(fileIdP))
        tline = fgetl(fileIdP);
        if ~isempty(tline)                      % check existence
            if isempty(strfind(tline,'='))      % not the 1st line
                encCntP = encCntP+1;
                specMrsi.encTableP(encCntP) = str2double(tline);
            end
        end
    end
    fclose(fileIdP);
else
    fprintf('%s -> <%s> exists but can not be opened...\n',FCTNAME,filePathP);
end

%--- consistency check ---
if length(specMrsi.encTableR)~=specMrsi.nEnc
    fprintf('<read> encoding size and table dimension do not match: %.0f~=%.0f.\nProgram aborted.\n',...
            length(specMrsi.encTableR),specMrsi.nEnc)
    return
end
if length(specMrsi.encTableP)~=specMrsi.nEnc
    fprintf('<phase> encoding size and table dimension do not match: %.0f~=%.0f.\nProgram aborted.\n',...
            length(specMrsi.encTableR),specMrsi.nEnc)
    return
end     

%--- update success flag ---
f_done = 1;

