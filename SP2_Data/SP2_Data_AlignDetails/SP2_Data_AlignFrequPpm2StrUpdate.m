%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignFrequPpm2StrUpdate
%% 
%%  Update function for frequency string assignment for spectrum
%%  frequency alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data flag

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Data_AlignFrequPpm2StrUpdate';


%--- initial string assignment ---
data.frAlignPpm2Str = get(fm.data.align.frPpm2Str,'String');

%--- consistency check ---
if any(data.frAlignPpm2Str==',') || any(data.frAlignPpm2Str==';') || ...
   any(data.frAlignPpm2Str=='[') || any(data.frAlignPpm2Str==']') || ...
   any(data.frAlignPpm2Str=='(') || any(data.frAlignPpm2Str==')') || ...
   any(data.frAlignPpm2Str=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(data.frAlignPpm2Str,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    data.frAlignPpm2N = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(data.frAlignPpm2Str,' ');
if length(spaceInd)+1~=data.frAlignPpm2N
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
data.frAlignPpm2Min = zeros(1,data.frAlignPpm2N);
data.frAlignPpm2Max = zeros(1,data.frAlignPpm2N);
bStr = data.frAlignPpm2Str;
for winCnt = 1:data.frAlignPpm2N
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    data.frAlignPpm2Min(winCnt) = str2double(minStr);
    data.frAlignPpm2Max(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if data.frAlignPpm2Min(winCnt)>=data.frAlignPpm2Max(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end

%--- info printout ---
if flag.dataExpType==3 || flag.dataExpType==7          % editing experiment, i.e. 2 conditions                                     
    fprintf('Frequency selection for frequency alignment (condition 2):\n');
else
    fprintf('Frequency selection for frequency alignment:\n');
end
for winCnt = 1:data.frAlignPpm2N
    fprintf('window %.0f: [%.3f %.3f]ppm\n',winCnt,...
            data.frAlignPpm2Min(winCnt),data.frAlignPpm2Max(winCnt))
end
fprintf('\n');




