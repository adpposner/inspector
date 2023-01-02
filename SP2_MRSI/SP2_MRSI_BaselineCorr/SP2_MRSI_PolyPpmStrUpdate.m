%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PolyPpmStrUpdate
%% 
%%  Update function for frequency string assignment for polynomial baseline
%%  correction.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_MRSI_PolyPpmStrUpdate';


%--- initial string assignment ---
mrsi.basePolyPpmStr = get(fm.mrsi.base.polyPpmStr,'String');

%--- consistency check ---
if any(mrsi.basePolyPpmStr==',') || any(mrsi.basePolyPpmStr==';') || ...
   any(mrsi.basePolyPpmStr=='[') || any(mrsi.basePolyPpmStr==']') || ...
   any(mrsi.basePolyPpmStr=='(') || any(mrsi.basePolyPpmStr==')') || ...
   any(mrsi.basePolyPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(mrsi.basePolyPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    mrsi.basePolyPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(mrsi.basePolyPpmStr,' ');
if length(spaceInd)+1~=mrsi.basePolyPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
mrsi.basePolyPpmMin = zeros(1,mrsi.basePolyPpmN);
mrsi.basePolyPpmMax = zeros(1,mrsi.basePolyPpmN);
bStr = mrsi.basePolyPpmStr;
for winCnt = 1:mrsi.basePolyPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    mrsi.basePolyPpmMin(winCnt) = str2double(minStr);
    mrsi.basePolyPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if mrsi.basePolyPpmMin(winCnt)>=mrsi.basePolyPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end




