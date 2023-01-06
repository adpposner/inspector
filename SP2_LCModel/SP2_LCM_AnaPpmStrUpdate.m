%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaPpmStrUpdate
%% 
%%  Update function for frequency string assignment for LCM.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_LCM_AnaPpmStrUpdate';


%--- initial string assignment ---
lcm.anaPpmStr = get(fm.lcm.anaPpmStr,'String');

%--- consistency check ---
if any(lcm.anaPpmStr==',') || any(lcm.anaPpmStr==';') || ...
   any(lcm.anaPpmStr=='[') || any(lcm.anaPpmStr==']') || ...
   any(lcm.anaPpmStr=='(') || any(lcm.anaPpmStr==')') || ...
   any(lcm.anaPpmStr=='''')
    fprintf('\nFrequency ranges in [ppm] have to be assigned as\n');
    fprintf('(single) space separated list using the following format:\n');
    fprintf('example 1, 1..2.5ppm: 1:2.5\n');
    fprintf('example 2, 0.1..0.9ppm and 7..8.5ppm: 0.1:0.9 7:8.5\n\n');
    return
end

%--- ppm range handling ---
colonInd = findstr(lcm.anaPpmStr,':');
if isempty(colonInd)
    fprintf('%s ->\nAt least one frequency range must be selected.\n',FCTNAME);
    return
else
    lcm.anaPpmN = length(colonInd);                    % number of ppm windows
end

%--- consistency check ---
spaceInd = findstr(lcm.anaPpmStr,' ');
if length(spaceInd)+1~=lcm.anaPpmN
    fprintf('%s -> Inconsistent string format.\nRemove leading/trailing/double spaces.\n',FCTNAME);
    return
end

%--- ppm range assignment ---
lcm.anaPpmMin = zeros(1,lcm.anaPpmN);
lcm.anaPpmMax = zeros(1,lcm.anaPpmN);
bStr = lcm.anaPpmStr;
for winCnt = 1:lcm.anaPpmN
    %--- data extraction ---
    [aStr,bStr] = strtok(bStr,' ');
    [minStr,maxStr] = strtok(aStr,':');
    lcm.anaPpmMin(winCnt) = str2double(minStr);
    lcm.anaPpmMax(winCnt) = str2double(maxStr(2:end));
    
    %--- consistency check min:max ---
    if lcm.anaPpmMin(winCnt)>=lcm.anaPpmMax(winCnt)
        fprintf('%s ->\nFrequency range #%.0f is not valid. Chose min<max.\n',FCTNAME,winCnt);
        return
    end
end

%--- info printout ---
fprintf('Frequency selection for LCModel analysis:\n');
for winCnt = 1:lcm.anaPpmN
    fprintf('window %.0f: [%.3f %.3f]ppm\n',winCnt,...
            lcm.anaPpmMin(winCnt),lcm.anaPpmMax(winCnt))
end
fprintf('\n');

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate






end
