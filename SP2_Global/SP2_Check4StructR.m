%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [pars, f_succ] = SP2_Check4StructR(varargin)
%%
%%  function pars = SP2_Check4StructR(varargin)
%%  Checks if variable 'pars' has been assigned a string value. If not an error message
%%  is return, if it is, nothing is returned. The function is used to check function
%%  arguments for correct parameter format. Doing so, the user gets to know, what the
%%  problem is instead of a noninformative error message, when programs crash at a later
%%  stage.
%%  The only difference to SP2_Check4Str.m is that the string is return. So, when strings are
%%  passed to other variables (e.g. name = SP2_Check4StrR(varargin{1}) ), no additional step 
%%  is required to perform the check.
%%
%%  Christoph Juchem, 02-2013
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FCTNAME = 'SP2_Check4StructR';

%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
narg = nargin;
if narg==1
    pars    = varargin{1};
    varName = inputname(1);
    if isempty(varName)
        % fprintf('%s -> variable name can not be displayed (inputname.m does not work) ...',FCTNAME);
        varName = '...';
    end
elseif narg==2
    pars    = varargin{1};
    varName = varargin{2};
else
    fprintf('%s -> more than 2 input arguments are not allowed ...',FCTNAME);
    return
end

%--- parameter assessment ---
if ~isstruct(pars)
    if iscell(pars)
        fprintf('%s -> parameter <%s> is cell array and not a structure!',FCTNAME,varName);
        return
    end
    if iscellstr(pars)
        fprintf('%s -> parameter <%s> is cell array of strings and not a structure!',FCTNAME,varName);
        return
    end
    if isempty(pars)
        fprintf('%s -> parameter <%s> is empty and not a structure!',FCTNAME,varName);
        return
    end
    if isnumeric(pars)
        fprintf('%s -> parameter <%s> is not a structure, but numeric!',FCTNAME,varName);
        return
    end
    if isobject(pars)
        fprintf('%s -> parameter <%s> is not a structure, but an object!',FCTNAME,varName);
        return
    end
    if ischar(pars)
        fprintf('%s -> parameter <%s> is not a structure, but char!',FCTNAME,varName);
        return
    end
end

%--- update success flag ---
f_succ = 1;




end
