%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_AlignPpmStrUpdate
%% 
%%  Update function for frequency string assignment for spectrum
%%  alignment.
%%
%%  11-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Proc_AlignPpmStrUpdate';


%--- init success flag ---
f_succ = 0;

%--- initial string assignment ---
procAlignPpmStr = get(fm.proc.alignPpmStr,'String');

%--- consistency check ---
if any(procAlignPpmStr==',') || any(procAlignPpmStr==';') || ...
   any(procAlignPpmStr=='[') || any(procAlignPpmStr==']') || ...
   any(procAlignPpmStr=='(') || any(procAlignPpmStr==')') || ...
   any(procAlignPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
    return
end

%--- ppm range handling ---
colonInd = findstr(procAlignPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
    return
else
    procAlignPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(procAlignPpmStr,' ');
if length(spaceInd)+1~=procAlignPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    set(fm.proc.alignPpmStr,'String',proc.alignPpmStr)
    return
end

%--- parameter assignment ---
proc.alignPpmStr = procAlignPpmStr;
proc.alignPpmN   = procAlignPpmN;

%--- ppm range assignment ---
proc.alignPpmMin = zeros(1,proc.alignPpmN);
proc.alignPpmMax = zeros(1,proc.alignPpmN);
bStr = proc.alignPpmStr;
for winCnt = 1:proc.alignPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    proc.alignPpmMin(winCnt) = str2double(minStr);
    proc.alignPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if proc.alignPpmMin(winCnt)>=proc.alignPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end

%--- info printout ---
fprintf('Frequency selection for spectral alignment:\n');
for winCnt = 1:proc.alignPpmN
    fprintf('window %.0f: [%.3f %.3f]ppm\n',winCnt,...
            proc.alignPpmMin(winCnt),proc.alignPpmMax(winCnt))
end
fprintf('\n');

%--- update success flag ---
f_succ = 1;



