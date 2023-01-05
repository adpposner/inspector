%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SvdPpmStrUpdate
%% 
%%  Update function for frequency string assignment for SVD-based removal
%%  of spectral peaks.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Proc_SvdPpmStrUpdate';


%--- initial string assignment ---
proc.baseSvdPpmStr = get(fm.proc.base.svdPpmStr,'String');

%--- consistency check ---
if any(proc.baseSvdPpmStr==',') || any(proc.baseSvdPpmStr==';') || ...
   any(proc.baseSvdPpmStr=='[') || any(proc.baseSvdPpmStr==']') || ...
   any(proc.baseSvdPpmStr=='(') || any(proc.baseSvdPpmStr==')') || ...
   any(proc.baseSvdPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(proc.baseSvdPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    proc.baseSvdPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(proc.baseSvdPpmStr,' ');
if length(spaceInd)+1~=proc.baseSvdPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
proc.baseSvdPpmMin = zeros(1,proc.baseSvdPpmN);
proc.baseSvdPpmMax = zeros(1,proc.baseSvdPpmN);
bStr = proc.baseSvdPpmStr;
for winCnt = 1:proc.baseSvdPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    proc.baseSvdPpmMin(winCnt) = str2double(minStr);
    proc.baseSvdPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if proc.baseSvdPpmMin(winCnt)>=proc.baseSvdPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end




