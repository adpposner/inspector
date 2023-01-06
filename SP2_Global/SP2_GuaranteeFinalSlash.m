%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function pathStr = SP2_GuaranteeFinalSlash(pathStr)
%% 
%%  Windows/Linux specific check of trailing slash/backslash for path
%%  variable
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag


%--- machine based slash control / appending ---
if flag.OS>0                    % Linux / Mac
    if ~strcmp(pathStr(end),'/')
        pathStr = [pathStr '/'];
    end
else                            % Windows
    if ~strcmp(pathStr(end),'\')
        pathStr = [pathStr '\'];
    end
end




end
