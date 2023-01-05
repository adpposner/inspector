%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PolyPpmStrUpdate
%% 
%%  Update function for frequency string assignment for polynomial baseline
%%  correction.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Proc_PolyPpmStrUpdate';


%--- initial string assignment ---
proc.basePolyPpmStr = get(fm.proc.base.polyPpmStr,'String');

%--- consistency check ---
if any(proc.basePolyPpmStr==',') || any(proc.basePolyPpmStr==';') || ...
   any(proc.basePolyPpmStr=='[') || any(proc.basePolyPpmStr==']') || ...
   any(proc.basePolyPpmStr=='(') || any(proc.basePolyPpmStr==')') || ...
   any(proc.basePolyPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(proc.basePolyPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    proc.basePolyPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(proc.basePolyPpmStr,' ');
if length(spaceInd)+1~=proc.basePolyPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
proc.basePolyPpmMin = zeros(1,proc.basePolyPpmN);
proc.basePolyPpmMax = zeros(1,proc.basePolyPpmN);
bStr = proc.basePolyPpmStr;
for winCnt = 1:proc.basePolyPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    proc.basePolyPpmMin(winCnt) = str2double(minStr);
    proc.basePolyPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if proc.basePolyPpmMin(winCnt)>=proc.basePolyPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end




