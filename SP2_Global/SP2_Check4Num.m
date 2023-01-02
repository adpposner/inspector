%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Check4Num(varargin)
%%
%%  function SP2_Check4Num(varargin)
%%  Checks if variable 'pars' has been assigned an numeric value. If not an error message
%%  is return, if it is, nothing is returned. The function is used to check function
%%  arguments for correct parameter format. Doing so, the user gets to know, what the
%%  problem is instead of a noninformative error message, when programs crash at a later
%%  stage.
%%
%%  Christoph Juchem, 08-2005
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FCTNAME = 'SP2_Check4Num';

%--- init success flag ---
f_succ = 0;

%--- parameter assessment ---
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
    varName = SP2_Check4StrR(varargin{2});
else
    fprintf('%s -> more than 2 input arguments are not allowed ...',FCTNAME);
    return
end

if ~isnumeric(pars)
    if iscell(pars)
        fprintf('%s -> parameter <%s> is cell array and not a number!',FCTNAME,varName);
        return
    end
    if iscellstr(pars)
        fprintf('%s -> parameter <%s> is cell array of strings and not a number!',FCTNAME,varName);
        return
    end
    if isempty(pars)
        fprintf('%s -> parameter <%s> is empty and not a number!',FCTNAME,varName);
        return
    end
    if ischar(pars)
        fprintf('%s -> parameter <%s> is not a number, but a string!',FCTNAME,varName);
        return
    end
    if isobject(pars)
        fprintf('%s -> parameter <%s> is not a number, but an object!',FCTNAME,varName);
        return
    end
    if isstruct(pars)
        fprintf('%s -> parameter <%s> is not a number, but a structure!',FCTNAME,varName);
        return
    end
end

%--- update success flag ---
f_succ = 1;


