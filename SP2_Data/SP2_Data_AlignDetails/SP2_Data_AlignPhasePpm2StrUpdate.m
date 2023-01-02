%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignPhasePpm2StrUpdate
%% 
%%  Update function for frequency string assignment for spectrum
%%  phase alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm data flag

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Data_AlignPhasePpm2StrUpdate';


%--- initial string assignment ---
data.phAlignPpm2Str = get(fm.data.align.phPpm2Str,'String');

%--- consistency check ---
if any(data.phAlignPpm2Str==',') || any(data.phAlignPpm2Str==';') || ...
   any(data.phAlignPpm2Str=='[') || any(data.phAlignPpm2Str==']') || ...
   any(data.phAlignPpm2Str=='(') || any(data.phAlignPpm2Str==')') || ...
   any(data.phAlignPpm2Str=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(data.phAlignPpm2Str,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    data.phAlignPpm2N = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(data.phAlignPpm2Str,' ');
if length(spaceInd)+1~=data.phAlignPpm2N
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
data.phAlignPpm2Min = zeros(1,data.phAlignPpm2N);
data.phAlignPpm2Max = zeros(1,data.phAlignPpm2N);
bStr = data.phAlignPpm2Str;
for winCnt = 1:data.phAlignPpm2N
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    data.phAlignPpm2Min(winCnt) = str2double(minStr);
    data.phAlignPpm2Max(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if data.phAlignPpm2Min(winCnt)>=data.phAlignPpm2Max(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end

%--- info printout ---
if flag.dataExpType==3 || flag.dataExpType==7          % editing experiment, i.e. 2 conditions                                     
    fprintf('Frequency selection for phase alignment (condition 2):\n');
else
    fprintf('Frequency selection for phase alignment:\n');
end
for winCnt = 1:data.phAlignPpm2N
    fprintf('window %.0f: [%.3f %.3f]ppm\n',winCnt,...
            data.phAlignPpm2Min(winCnt),data.phAlignPpm2Max(winCnt))
end
fprintf('\n');




