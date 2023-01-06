%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitComb2StrUpdate
%% 
%%  Update function for selection of metabolite combination for joint CRLB analysis.
%%
%%  05-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm flag

FCTNAME = 'SP2_LCM_FitComb2StrUpdate';


%--- initial string assignment ---
lcmComb2Str = get(fm.lcm.fit.comb2Str,'String');

%--- consistency check ---
if any(lcmComb2Str==',') || any(lcmComb2Str==';') || ...
   any(lcmComb2Str=='[') || any(lcmComb2Str==']') || ...
   any(lcmComb2Str=='(') || any(lcmComb2Str==')') || ...
   any(lcmComb2Str=='''') || any(lcmComb2Str=='.') || ...
   any(lcmComb2Str==':') || isempty(lcmComb2Str)
    fprintf('\nMetabolites for combined CRLB analysis\n');
    fprintf('need to be assigned as simple space-separated list\n');
    fprintf('example: 1 5\n');
    set(fm.lcm.fit.comb2Str,'String',lcm.comb2Str)
    return
end

%--- calibration vector assignment ---
lcmComb2Ind = sort(eval(['[' lcmComb2Str ']']));         % temporary selection vector assignment
% lcmComb2IndN = length(lcmComb2Ind);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(lcmComb2Ind)==0)
    fprintf('%s ->\nMultiple assignments of the same metabolite detected...\n',FCTNAME);
    set(fm.lcm.fit.comb2Str,'String',lcm.comb2Str)
    return
end
if ~isnumeric(lcmComb2Ind)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    set(fm.lcm.fit.comb2Str,'String',lcm.comb2Str)
    return
end
if any(lcmComb2Ind<1)
    fprintf('%s ->\nMinimum metabolite number is 1!\n',FCTNAME);
    set(fm.lcm.fit.comb2Str,'String',lcm.comb2Str)
    return
end
if length(lcmComb2Ind)<2
    fprintf('%s ->\nMinimum number of metabolites to be linked is 2!\n',FCTNAME);
    set(fm.lcm.fit.comb2Str,'String',lcm.comb2Str)
    return
end
% if isfield(data.spec1,'nRcvrs')
%     if any(lcmComb2Ind>data.spec1.nRcvrs)
%         fprintf('%s ->\nMaximum receiver number exceeds number of available data set (rcvr max: %.0f)!\n',FCTNAME,data.spec1.nRcvrs);
%         set(fm.lcm.fit.comb2Str,'String',lcm.comb2Str)
%         return
%     end
% end
if isempty(lcmComb2Ind)
    fprintf('%s ->\nEmpty vector detected.\nMinimum: 1 receiver!\n',FCTNAME);
    set(fm.lcm.fit.comb2Str,'String',lcm.comb2Str)
    return
end

%--- current receiver assignment ---
lcm.comb2Ind  = lcmComb2Ind;                        % selection vector assignment
lcm.comb2N    = length(lcm.comb2Ind);               % number of selected receivers
lcm.comb2Str  = num2str(lcm.comb2Ind);              % convert back to string

%--- window update ---
set(fm.lcm.fit.comb2Str,'String',lcm.comb2Str);

%--- info printout ---
if flag.verbose
    fprintf('Metabolite combination 2: %s\n',SP2_Vec2PrintStr(lcm.comb2Ind,0));
end

%--- figure update ---
SP2_LCM_FitDetailsWinUpdate;




end
