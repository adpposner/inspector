%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ShowSelStrUpdate
%% 
%%  Update function for metabolites selection for superposition / summation.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm flag

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_LCM_ShowSelStrUpdate';


%--- initial string assignment ---
lcm.showSelStr = get(fm.lcm.showSelStr,'String');

%--- consistency check ---
if any(lcm.showSelStr==',') || any(lcm.showSelStr==';') || ...
   any(lcm.showSelStr=='[') || any(lcm.showSelStr==']') || ...
   any(lcm.showSelStr=='(') || any(lcm.showSelStr==')') || ...
   any(lcm.showSelStr=='''') || any(lcm.showSelStr=='.')
    fprintf('\nMetabolite index selection has to be assigned as\n');
    fprintf('space separated list of integers without further formating\n');
    fprintf('Note that the colon operator is supported.\n');
    return
end

%--- calibration vector assignment ---
lcm.showSel  = eval(['[' lcm.showSelStr ']']);      % selection vector assignment
lcm.showSelN = length(lcm.showSel);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(lcm.showSel)==0)
    fprintf('%s ->\nMultiple assignments of the same metabolite detected...\n',FCTNAME);
    return
end
if ~isnumeric(lcm.showSel)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if any(lcm.showSel<1)
    fprintf('%s ->\nMinimum metabolite number <1 detected!\n',FCTNAME);
    return
end
if flag.lcmAnaPoly              % baseline included
    if any(lcm.showSel>lcm.fit.appliedN+1)
        fprintf('%s ->\nAt least one metabolite number exceeds number of fitted\nspectral components\n(%.0f metabs + baseline = %.0f)\n',...
                FCTNAME,lcm.fit.appliedN,lcm.fit.appliedN+1)
        return
    end
else                            % baseline not fitted
    if any(lcm.showSel>lcm.fit.appliedN)
        fprintf('%s ->\nAt least one metabolite number exceeds number of\nfitted spectral components (%.0f metabs)\n',...
                FCTNAME,lcm.fit.appliedN)
        return
    end
end
if isempty(lcm.showSel)
    fprintf('%s ->\nEmpty metabolite selection detected.\nMinimum: 1 metabolite!\n',FCTNAME);
    return
end

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate





end
