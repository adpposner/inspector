%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitComb3StrUpdate
%% 
%%  Update function for selection of metabolite combination for joint CRLB analysis.
%%
%%  05-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm flag

FCTNAME = 'SP2_LCM_FitComb3StrUpdate';


%--- initial string assignment ---
lcmComb3Str = get(fm.lcm.fit.comb3Str,'String');

%--- consistency check ---
if any(lcmComb3Str==',') || any(lcmComb3Str==';') || ...
   any(lcmComb3Str=='[') || any(lcmComb3Str==']') || ...
   any(lcmComb3Str=='(') || any(lcmComb3Str==')') || ...
   any(lcmComb3Str=='''') || any(lcmComb3Str=='.') || ...
   any(lcmComb3Str==':') || isempty(lcmComb3Str)
    fprintf('\nMetabolites for combined CRLB analysis\n');
    fprintf('need to be assigned as simple space-separated list\n');
    fprintf('example: 1 5\n');
    set(fm.lcm.fit.comb3Str,'String',lcm.comb3Str)
    return
end

%--- calibration vector assignment ---
lcmComb3Ind = sort(eval(['[' lcmComb3Str ']']));         % temporary selection vector assignment
% lcmComb3IndN = length(lcmComb3Ind);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(lcmComb3Ind)==0)
    fprintf('%s ->\nMultiple assignments of the same metabolite detected...\n',FCTNAME);
    set(fm.lcm.fit.comb3Str,'String',lcm.comb3Str)
    return
end
if ~isnumeric(lcmComb3Ind)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    set(fm.lcm.fit.comb3Str,'String',lcm.comb3Str)
    return
end
if any(lcmComb3Ind<1)
    fprintf('%s ->\nMinimum metabolite number is 1!\n',FCTNAME);
    set(fm.lcm.fit.comb3Str,'String',lcm.comb3Str)
    return
end
if length(lcmComb3Ind)<2
    fprintf('%s ->\nMinimum number of metabolites to be linked is 2!\n',FCTNAME);
    set(fm.lcm.fit.comb3Str,'String',lcm.comb3Str)
    return
end
% if isfield(data.spec1,'nRcvrs')
%     if any(lcmComb3Ind>data.spec1.nRcvrs)
%         fprintf('%s ->\nMaximum receiver number exceeds number of available data set (rcvr max: %.0f)!\n',FCTNAME,data.spec1.nRcvrs);
%         set(fm.lcm.fit.comb3Str,'String',lcm.comb3Str)
%         return
%     end
% end
if isempty(lcmComb3Ind)
    fprintf('%s ->\nEmpty vector detected.\nMinimum: 1 receiver!\n',FCTNAME);
    set(fm.lcm.fit.comb3Str,'String',lcm.comb3Str)
    return
end

%--- current receiver assignment ---
lcm.comb3Ind  = lcmComb3Ind;                        % selection vector assignment
lcm.comb3N    = length(lcm.comb3Ind);               % number of selected receivers
lcm.comb3Str  = num2str(lcm.comb3Ind);              % convert back to string

%--- window update ---
set(fm.lcm.fit.comb3Str,'String',lcm.comb3Str);

%--- info printout ---
if flag.verbose
    fprintf('Metabolite combination 2: %s\n',SP2_Vec2PrintStr(lcm.comb3Ind,0));
end

%--- figure update ---
SP2_LCM_FitDetailsWinUpdate;



