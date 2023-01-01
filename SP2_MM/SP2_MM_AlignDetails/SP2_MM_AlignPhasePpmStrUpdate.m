%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignPhasePpmStrUpdate
%% 
%%  Update function for frequency string assignment for spectrum
%%  phase alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_MM_AlignPhasePpmStrUpdate';


%--- initial string assignment ---
mm.phAlignPpmStr = get(fm.mm.align.phPpmStr,'String');

%--- consistency check ---
if any(mm.phAlignPpmStr==',') || any(mm.phAlignPpmStr==';') || ...
   any(mm.phAlignPpmStr=='[') || any(mm.phAlignPpmStr==']') || ...
   any(mm.phAlignPpmStr=='(') || any(mm.phAlignPpmStr==')') || ...
   any(mm.phAlignPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n')
    fprintf('(single) space separated list using the following format:\n')
    fprintf('example 1, 1..2.5ppm: 1:2.5\n')
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n')
    return
end

%--- ppm range handling ---
colonInd = findstr(mm.phAlignPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME)
    return
else
    mm.phAlignPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(mm.phAlignPpmStr,' ');
if length(spaceInd)+1~=mm.phAlignPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME)
    return
end

%--- ppm range assignment ---
mm.phAlignPpmMin = zeros(1,mm.phAlignPpmN);
mm.phAlignPpmMax = zeros(1,mm.phAlignPpmN);
bStr = mm.phAlignPpmStr;
for winCnt = 1:mm.phAlignPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    mm.phAlignPpmMin(winCnt) = str2double(minStr);
    mm.phAlignPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if mm.phAlignPpmMin(winCnt)>=mm.phAlignPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt)
        return
    end
end

%--- info printout ---
fprintf('Frequency selection for phase alignment:\n')
for winCnt = 1:mm.phAlignPpmN
    fprintf('window %.0f: [%.3f %.3f]ppm\n',winCnt,...
            mm.phAlignPpmMin(winCnt),mm.phAlignPpmMax(winCnt))
end
fprintf('\n')




