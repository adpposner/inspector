%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Check4Cell(varargin)
%%
%%  function SP2_Check4Cell(pars)
%%  Checks if variable 'pars' has been assigned a cell array. If not an error message
%%  is return. If it is, nothing is returned. The function is used to check function
%%  arguments for correct parameter format. Doing so, the user gets to know, what the
%%  problem is instead of a noninformative error message, when programs crash at a later
%%  stage.
%%  The only difference to SP2_Check4CellR.m is that the cell is not returned.
%%
%%  Christoph Juchem, 03-2005
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FCTNAME = 'SP2_Check4Cell';


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
narg = nargin;
if narg==1
    pars    = varargin{1};
    varName = inputname(1);
    if isempty(varName)
        % fprintf('%s -> variable name can not be displayed (inputname.m does not work) ...',FCTNAME)
        varName = '...';
    end
elseif narg==2
    pars    = varargin{1};
    varName = SP2_Check4StrR(varargin{2});
else
    fprintf('%s -> more than 2 input arguments are not allowed ...',FCTNAME)
    return
end

%--- parameter assessment ---
if ~iscell(pars)
    if isnumeric(pars)
        fprintf('%s -> parameter <%s> is numeric and not a cell array!',FCTNAME,varName)
        return
    end
    if iscellstr(pars)
        fprintf('%s -> parameter <%s> is cell array of strings and not a cell array!',FCTNAME,varName)
        return
    end
    if isempty(pars)
        fprintf('%s -> parameter <%s> is empty and not a cell array!',FCTNAME,varName)
        return
    end
    if ischar(pars)
        fprintf('%s -> parameter <%s> is not a cell array, but a string!',FCTNAME,varName)
        return
    end
    if isobject(pars)
        fprintf('%s -> parameter <%s> is not a cell array, but an object!',FCTNAME,varName)
        return
    end
    if isstruct(pars)
        fprintf('%s -> parameter <%s> is not a cell array, but a structure!',FCTNAME,varName)
        return
    end
end

%--- success flag update ---
f_succ = 1;


