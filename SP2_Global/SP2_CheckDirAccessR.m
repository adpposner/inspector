%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [f_YesNo, maxPath, f_succ] = SP2_CheckDirAccessR(dirPath,varargin)
%%
%%  function [f_YesNo,maxPath] = SP2_CheckDirAccessR(dirPath)
%%  Checks the accessibility of a particular directory 'dirPath'. When dirPath is not
%%  accessible the path string is decomposed into its subdirectory components and a
%%  subsequent check indicates the first subdirectory which is not accessible.
%%  The function is of particular use when long path names are used which address
%%  directories on other machines, using some intermediate links,...
%%  A flag f_YesNo is returned to indicate the accessibility. maxPath is the
%%  maximum part of the directory string, which was accessible.
%%
%%  03-2005, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_CheckDirAccessR';


%--- init success flag ---
f_succ = 0;

%--- check path format ---
if ~SP2_Check4Str(dirPath)
    return
end

%--- verbose handling ---
f_verbose = 1;          % default: verbose
if nargin==2
    f_verbose = SP2_Check4FlagR(varargin{1});
end

%--- get rid of final slash if it exists ---
if flag.OS>0            % 1: linux, 2: mac
    if strcmp(dirPath(end),'/')
        dirPath = dirPath(1:end-1);
    end
else                    % 0: PC
    if strcmp(dirPath(end),'\')
        dirPath = dirPath(1:end-1);
    end
end

%--- init maxPath ---
maxPath = '';

%--- check accessibility of dirPath ---
if ~exist(dirPath,'dir')
    f_YesNo = 0;
    %--- decompose dirPath ---
    if flag.OS>0                % 1: linux, 2: mac
        I = find(dirPath=='/');
        if strcmp(dirPath(1),'/')
            INIT     = '/';             % initial string
            Slash1st = 1;               % first relevant (directory covering) slash 
        else
            if f_verbose
                fprintf(loggingfile,'%s ->\nString <%s> seems not to be a directory path...\n',FCTNAME,dirPath);
            end
        end
    else                        % 0: PC
        I = find(dirPath=='\');
        if strcmp(dirPath(1:2),'\\')
            INIT = '\\';                % initial string
            Slash1st = 2;               % first relevant (directory covering) slash 
        elseif strcmp(dirPath(2:3),':\') || strcmp(dirPath(1:3),'..\')
            INIT = dirPath(1:3);        % initial string
            Slash1st = 1;               % first relevant (directory covering) slash 
        else
            if f_verbose
                fprintf(loggingfile,'%s ->\nString <%s> seems not to be a directory path...\n',FCTNAME,dirPath);
            end
        end
    end
    
    %--- check of directory accessibility if valid directory structure
    % recognized ---
    if exist('Slash1st','var')
        %--- get directory names ---
        nFields = 0;        % number of fields (directories)
        for icnt = Slash1st:length(I)-1
            nFields = nFields + 1;
            eval('subdir{nFields} = dirPath(I(icnt)+1:I(icnt+1)-1);')
        end

        %--- subsequent check of directory accessibility ---
        % the problem is that e.g. //win27/Data/2004 may be accessible even if //win27
        % is not. This depends on the sharing policy...
        dirStr{1} = INIT;               % char array of subsequent directory paths
        existVec = zeros(1,nFields);    % vectors assigned accessible 'dirStr' fields
        for icnt = 1:nFields
            if icnt==1
                dirStr{1} = [INIT subdir{icnt}];
            else
                dirStr{icnt} = [dirStr{icnt-1} '\' subdir{icnt}];
            end
            if find(exist(char(dirStr{icnt}))==7)
                existVec(1,icnt) = 1;
            end
        end
        lastField = find(existVec==1);      % last accessible subdirectory
        if isempty(lastField)
            if f_verbose
                fprintf(loggingfile,'%s ->\n<%s> isn''t accessible at all,\nnot even <%s>...\n',...
                        FCTNAME,dirPath,dirStr{1})
            end
            maxPath = '';
        else
            if f_verbose
                fprintf(loggingfile,'%s ->\n<%s> isn''t accessible,\neven if <%s> is accessible...\n',...
                        FCTNAME,dirPath,dirStr{max(lastField)})
            end
            maxPath = dirStr{max(lastField)};
        end
    end
else
    f_YesNo = 1;
    maxPath = dirPath;      % entire dir string
end

%--- update success flag ---
f_succ = 1;






