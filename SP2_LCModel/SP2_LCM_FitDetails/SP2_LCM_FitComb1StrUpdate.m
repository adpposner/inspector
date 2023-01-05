%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitComb1StrUpdate
%% 
%%  Update function for selection of metabolite combination for joint CRLB analysis.
%%
%%  05-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm flag

FCTNAME = 'SP2_LCM_FitComb1StrUpdate';


%--- initial string assignment ---
lcmComb1Str = get(fm.lcm.fit.comb1Str,'String');

%--- consistency check ---
if any(lcmComb1Str==',') || any(lcmComb1Str==';') || ...
   any(lcmComb1Str=='[') || any(lcmComb1Str==']') || ...
   any(lcmComb1Str=='(') || any(lcmComb1Str==')') || ...
   any(lcmComb1Str=='''') || any(lcmComb1Str=='.') || ...
   any(lcmComb1Str==':') || isempty(lcmComb1Str)
    fprintf('\nMetabolites for combined CRLB analysis\n');
    fprintf('need to be assigned as simple space-separated list\n');
    fprintf('example: 1 5\n');
    set(fm.lcm.fit.comb1Str,'String',lcm.comb1Str)
    return
end

%--- calibration vector assignment ---
lcmComb1Ind = sort(eval(['[' lcmComb1Str ']']));         % temporary selection vector assignment
% lcmComb1IndN = length(lcmComb1Ind);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(lcmComb1Ind)==0)
    fprintf('%s ->\nMultiple assignments of the same metabolite detected...\n',FCTNAME);
    set(fm.lcm.fit.comb1Str,'String',lcm.comb1Str)
    return
end
if ~isnumeric(lcmComb1Ind)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    set(fm.lcm.fit.comb1Str,'String',lcm.comb1Str)
    return
end
if any(lcmComb1Ind<1)
    fprintf('%s ->\nMinimum metabolite number is 1!\n',FCTNAME);
    set(fm.lcm.fit.comb1Str,'String',lcm.comb1Str)
    return
end
if length(lcmComb1Ind)<2
    fprintf('%s ->\nMinimum number of metabolites to be linked is 2!\n',FCTNAME);
    set(fm.lcm.fit.comb1Str,'String',lcm.comb1Str)
    return
end
% if isfield(data.spec1,'nRcvrs')
%     if any(lcmComb1Ind>data.spec1.nRcvrs)
%         fprintf('%s ->\nMaximum receiver number exceeds number of available data set (rcvr max: %.0f)!\n',FCTNAME,data.spec1.nRcvrs);
%         set(fm.lcm.fit.comb1Str,'String',lcm.comb1Str)
%         return
%     end
% end
if isempty(lcmComb1Ind)
    fprintf('%s ->\nEmpty vector detected.\nMinimum: 1 receiver!\n',FCTNAME);
    set(fm.lcm.fit.comb1Str,'String',lcm.comb1Str)
    return
end

%--- current receiver assignment ---
lcm.comb1Ind  = lcmComb1Ind;                        % selection vector assignment
lcm.comb1N    = length(lcm.comb1Ind);               % number of selected receivers
lcm.comb1Str  = num2str(lcm.comb1Ind);              % convert back to string

%--- window update ---
set(fm.lcm.fit.comb1Str,'String',lcm.comb1Str);

%--- info printout ---
if flag.verbose
    fprintf('Metabolite combination 1: %s\n',SP2_Vec2PrintStr(lcm.comb1Ind,0));
end

%--- figure update ---
SP2_LCM_FitDetailsWinUpdate;



