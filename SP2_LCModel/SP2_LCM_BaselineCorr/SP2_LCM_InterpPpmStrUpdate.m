%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_InterpPpmStrUpdate
%% 
%%  Update function for frequency string assignment for interpolation
%%  baseline correction.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_LCM_InterpPpmStrUpdate';


%--- initial string assignment ---
lcm.baseInterpPpmStr = get(fm.lcm.base.interpPpmStr,'String');

%--- consistency check ---
if any(lcm.baseInterpPpmStr==',') || any(lcm.baseInterpPpmStr==';') || ...
   any(lcm.baseInterpPpmStr=='[') || any(lcm.baseInterpPpmStr==']') || ...
   any(lcm.baseInterpPpmStr=='(') || any(lcm.baseInterpPpmStr==')') || ...
   any(lcm.baseInterpPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(lcm.baseInterpPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    lcm.baseInterpPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(lcm.baseInterpPpmStr,' ');
if length(spaceInd)+1~=lcm.baseInterpPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
lcm.baseInterpPpmMin = zeros(1,lcm.baseInterpPpmN);
lcm.baseInterpPpmMax = zeros(1,lcm.baseInterpPpmN);
bStr = lcm.baseInterpPpmStr;
for winCnt = 1:lcm.baseInterpPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    lcm.baseInterpPpmMin(winCnt) = str2double(minStr);
    lcm.baseInterpPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if lcm.baseInterpPpmMin(winCnt)>=lcm.baseInterpPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end





end
