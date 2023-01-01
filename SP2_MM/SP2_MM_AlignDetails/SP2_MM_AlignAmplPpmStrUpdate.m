%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignAmplPpmStrUpdate
%% 
%%  Update function for frequency string assignment for spectrum
%%  amplitude alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_MM_AlignAmplPpmStrUpdate';


%--- initial string assignment ---
mm.amAlignPpmStr = get(fm.mm.align.amPpmStr,'String');

%--- consistency check ---
if any(mm.amAlignPpmStr==',') || any(mm.amAlignPpmStr==';') || ...
   any(mm.amAlignPpmStr=='[') || any(mm.amAlignPpmStr==']') || ...
   any(mm.amAlignPpmStr=='(') || any(mm.amAlignPpmStr==')') || ...
   any(mm.amAlignPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n')
    fprintf('(single) space separated list using the following format:\n')
    fprintf('example 1, 1..2.5ppm: 1:2.5\n')
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n')
    return
end

%--- ppm range handling ---
colonInd = findstr(mm.amAlignPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME)
    return
else
    mm.amAlignPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(mm.amAlignPpmStr,' ');
if length(spaceInd)+1~=mm.amAlignPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME)
    return
end

%--- ppm range assignment ---
mm.amAlignPpmMin = zeros(1,mm.amAlignPpmN);
mm.amAlignPpmMax = zeros(1,mm.amAlignPpmN);
bStr = mm.amAlignPpmStr;
for winCnt = 1:mm.amAlignPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    mm.amAlignPpmMin(winCnt) = str2double(minStr);
    mm.amAlignPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if mm.amAlignPpmMin(winCnt)>=mm.amAlignPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt)
        return
    end
end

%--- info printout ---
fprintf('Frequency selection for amplitude alignment:\n')
for winCnt = 1:mm.amAlignPpmN
    fprintf('window %.0f: [%.3f %.3f]ppm\n',winCnt,...
            mm.amAlignPpmMin(winCnt),mm.amAlignPpmMax(winCnt))
end
fprintf('\n')




