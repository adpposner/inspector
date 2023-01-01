%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignFrequPpmStrUpdate
%% 
%%  Update function for frequency string assignment for spectrum
%%  frequency alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_MM_AlignFrequPpmStrUpdate';


%--- initial string assignment ---
mm.frAlignPpmStr = get(fm.mm.align.frPpmStr,'String');

%--- consistency check ---
if any(mm.frAlignPpmStr==',') || any(mm.frAlignPpmStr==';') || ...
   any(mm.frAlignPpmStr=='[') || any(mm.frAlignPpmStr==']') || ...
   any(mm.frAlignPpmStr=='(') || any(mm.frAlignPpmStr==')') || ...
   any(mm.frAlignPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n')
    fprintf('(single) space separated list using the following format:\n')
    fprintf('example 1, 1..2.5ppm: 1:2.5\n')
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n')
    return
end

%--- ppm range handling ---
colonInd = findstr(mm.frAlignPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME)
    return
else
    mm.frAlignPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(mm.frAlignPpmStr,' ');
if length(spaceInd)+1~=mm.frAlignPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME)
    return
end

%--- ppm range assignment ---
mm.frAlignPpmMin = zeros(1,mm.frAlignPpmN);
mm.frAlignPpmMax = zeros(1,mm.frAlignPpmN);
bStr = mm.frAlignPpmStr;
for winCnt = 1:mm.frAlignPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    mm.frAlignPpmMin(winCnt) = str2double(minStr);
    mm.frAlignPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if mm.frAlignPpmMin(winCnt)>=mm.frAlignPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt)
        return
    end
end

%--- info printout ---
fprintf('Frequency selection for frequency alignment:\n')
for winCnt = 1:mm.frAlignPpmN
    fprintf('window %.0f: [%.3f %.3f]ppm\n',winCnt,...
            mm.frAlignPpmMin(winCnt),mm.frAlignPpmMax(winCnt))
end
fprintf('\n')




