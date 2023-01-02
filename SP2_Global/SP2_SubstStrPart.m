%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [newStr, f_succ] = SP2_SubstStrPart(origStr,delStr,substStr)
%%
%%  function newStr = SP2_SubstStrPart(origStr,delStr,substStr)
%%  searchs in 'origStr' (1st arg) for 'delStr' (2nd arg) and (if it is found) substitutes it by 'substStr' (3rd arg)
%%
%%  Christoph Juchem, 03-2006
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_SubstStrPart';

%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
narg = nargin;
if narg~=3
    fprintf('%s -> the number of input arguments must be three',FCTNAME);
    return
end
if ~SP2_Check4Str(origStr)
    return
end
if ~SP2_Check4Str(delStr)
    return
end
if ~SP2_Check4Str(substStr)
    return
end

delLen = length(delStr);
origLen = length(origStr);
I = findstr(origStr,delStr);
newStr = '';
if delLen<=origLen          % 'findstr' searchs for shorter string in longer one -> restriction necessary
    if ~isempty(I)
        for icnt=1:length(origStr)
            if icnt==1 || icnt>strCnt                    % strCnt is necessary, since incrementing icnt during the for-loop is not possible
                strCnt = icnt;
            end
            if icnt==strCnt                             % when a string was found copying the original string must be stopped for all string letters
                if ~isempty(find(strCnt==I))            % string pattern found; to be substituted
                    newStr = [newStr substStr];         % substitute string part
                    strCnt = strCnt + delLen;           % shift string index
                else
                    newStr = [newStr origStr(icnt)];    % non-relevant part of the original string, not to be modified
                end
            end
        end
    else
        newStr = origStr;
    end
end

%--- update success flag ---
f_succ = 1;



