%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_InterpPpmStrUpdate
%% 
%%  Update function for frequency string assignment for interpolation
%%  baseline correction.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Proc_InterpPpmStrUpdate';


%--- initial string assignment ---
proc.baseInterpPpmStr = get(fm.proc.base.interpPpmStr,'String');

%--- consistency check ---
if any(proc.baseInterpPpmStr==',') || any(proc.baseInterpPpmStr==';') || ...
   any(proc.baseInterpPpmStr=='[') || any(proc.baseInterpPpmStr==']') || ...
   any(proc.baseInterpPpmStr=='(') || any(proc.baseInterpPpmStr==')') || ...
   any(proc.baseInterpPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n')
    fprintf('(single) space separated list using the following format:\n')
    fprintf('example 1, 1..2.5ppm: 1:2.5\n')
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n')
    return
end

%--- ppm range handling ---
colonInd = findstr(proc.baseInterpPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME)
    return
else
    proc.baseInterpPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(proc.baseInterpPpmStr,' ');
if length(spaceInd)+1~=proc.baseInterpPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME)
    return
end

%--- ppm range assignment ---
proc.baseInterpPpmMin = zeros(1,proc.baseInterpPpmN);
proc.baseInterpPpmMax = zeros(1,proc.baseInterpPpmN);
bStr = proc.baseInterpPpmStr;
for winCnt = 1:proc.baseInterpPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    proc.baseInterpPpmMin(winCnt) = str2double(minStr);
    proc.baseInterpPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if proc.baseInterpPpmMin(winCnt)>=proc.baseInterpPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt)
        return
    end
end




