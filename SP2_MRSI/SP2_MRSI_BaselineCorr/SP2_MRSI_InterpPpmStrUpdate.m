%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_InterpPpmStrUpdate
%% 
%%  Update function for frequency string assignment for interpolation
%%  baseline correction.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_MRSI_InterpPpmStrUpdate';


%--- initial string assignment ---
mrsi.baseInterpPpmStr = get(fm.mrsi.base.interpPpmStr,'String');

%--- consistency check ---
if any(mrsi.baseInterpPpmStr==',') || any(mrsi.baseInterpPpmStr==';') || ...
   any(mrsi.baseInterpPpmStr=='[') || any(mrsi.baseInterpPpmStr==']') || ...
   any(mrsi.baseInterpPpmStr=='(') || any(mrsi.baseInterpPpmStr==')') || ...
   any(mrsi.baseInterpPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(mrsi.baseInterpPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    mrsi.baseInterpPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(mrsi.baseInterpPpmStr,' ');
if length(spaceInd)+1~=mrsi.baseInterpPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
mrsi.baseInterpPpmMin = zeros(1,mrsi.baseInterpPpmN);
mrsi.baseInterpPpmMax = zeros(1,mrsi.baseInterpPpmN);
bStr = mrsi.baseInterpPpmStr;
for winCnt = 1:mrsi.baseInterpPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    mrsi.baseInterpPpmMin(winCnt) = str2double(minStr);
    mrsi.baseInterpPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if mrsi.baseInterpPpmMin(winCnt)>=mrsi.baseInterpPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end




