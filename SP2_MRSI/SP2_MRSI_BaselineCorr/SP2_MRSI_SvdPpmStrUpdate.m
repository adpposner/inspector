%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SvdPpmStrUpdate
%% 
%%  Update function for frequency string assignment for SVD-based removal
%%  of spectral peaks.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_MRSI_SvdPpmStrUpdate';


%--- initial string assignment ---
mrsi.baseSvdPpmStr = get(fm.mrsi.base.svdPpmStr,'String');

%--- consistency check ---
if any(mrsi.baseSvdPpmStr==',') || any(mrsi.baseSvdPpmStr==';') || ...
   any(mrsi.baseSvdPpmStr=='[') || any(mrsi.baseSvdPpmStr==']') || ...
   any(mrsi.baseSvdPpmStr=='(') || any(mrsi.baseSvdPpmStr==')') || ...
   any(mrsi.baseSvdPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(mrsi.baseSvdPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    mrsi.baseSvdPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(mrsi.baseSvdPpmStr,' ');
if length(spaceInd)+1~=mrsi.baseSvdPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
mrsi.baseSvdPpmMin = zeros(1,mrsi.baseSvdPpmN);
mrsi.baseSvdPpmMax = zeros(1,mrsi.baseSvdPpmN);
bStr = mrsi.baseSvdPpmStr;
for winCnt = 1:mrsi.baseSvdPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    mrsi.baseSvdPpmMin(winCnt) = str2double(minStr);
    mrsi.baseSvdPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if mrsi.baseSvdPpmMin(winCnt)>=mrsi.baseSvdPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end




