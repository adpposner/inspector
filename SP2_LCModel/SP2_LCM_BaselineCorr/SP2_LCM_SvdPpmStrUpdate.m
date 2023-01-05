%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SvdPpmStrUpdate
%% 
%%  Update function for frequency string assignment for SVD-based removal
%%  of spectral peaks.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_LCM_SvdPpmStrUpdate';


%--- initial string assignment ---
lcm.baseSvdPpmStr = get(fm.lcm.base.svdPpmStr,'String');

%--- consistency check ---
if any(lcm.baseSvdPpmStr==',') || any(lcm.baseSvdPpmStr==';') || ...
   any(lcm.baseSvdPpmStr=='[') || any(lcm.baseSvdPpmStr==']') || ...
   any(lcm.baseSvdPpmStr=='(') || any(lcm.baseSvdPpmStr==')') || ...
   any(lcm.baseSvdPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(lcm.baseSvdPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    lcm.baseSvdPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(lcm.baseSvdPpmStr,' ');
if length(spaceInd)+1~=lcm.baseSvdPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
lcm.baseSvdPpmMin = zeros(1,lcm.baseSvdPpmN);
lcm.baseSvdPpmMax = zeros(1,lcm.baseSvdPpmN);
bStr = lcm.baseSvdPpmStr;
for winCnt = 1:lcm.baseSvdPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    lcm.baseSvdPpmMin(winCnt) = str2double(minStr);
    lcm.baseSvdPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if lcm.baseSvdPpmMin(winCnt)>=lcm.baseSvdPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end




