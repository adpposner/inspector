%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignAmplPpmStrUpdate
%% 
%%  Update function for frequency string assignment for spectrum
%%  amplitude alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Data_AlignAmplPpmStrUpdate';


%--- initial string assignment ---
data.amAlignPpmStr = get(fm.data.align.amPpmStr,'String');

%--- consistency check ---
if any(data.amAlignPpmStr==',') || any(data.amAlignPpmStr==';') || ...
   any(data.amAlignPpmStr=='[') || any(data.amAlignPpmStr==']') || ...
   any(data.amAlignPpmStr=='(') || any(data.amAlignPpmStr==')') || ...
   any(data.amAlignPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(data.amAlignPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    data.amAlignPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(data.amAlignPpmStr,' ');
if length(spaceInd)+1~=data.amAlignPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
data.amAlignPpmMin = zeros(1,data.amAlignPpmN);
data.amAlignPpmMax = zeros(1,data.amAlignPpmN);
bStr = data.amAlignPpmStr;
for winCnt = 1:data.amAlignPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    data.amAlignPpmMin(winCnt) = str2double(minStr);
    data.amAlignPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if data.amAlignPpmMin(winCnt)>=data.amAlignPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end

%--- info printout ---
fprintf('Frequency selection for amplitude alignment:\n');
for winCnt = 1:data.amAlignPpmN
    fprintf('window %.0f: [%.3f %.3f]ppm\n',winCnt,...
            data.amAlignPpmMin(winCnt),data.amAlignPpmMax(winCnt))
end
fprintf('\n');





end
