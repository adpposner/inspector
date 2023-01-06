%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [pars, f_succ] = SP2_Check4Bigger0R(varargin)
%%
%%  function SP2_Check4Bigger0R(varargin)
%%  Checks if variable 'pars' has been assigned an numeric value >1. If not an error message
%%  is returned, if it is, nothing is returned. The function is used to check function
%%  arguments for correct parameter format. Doing so, the user gets to know, what the
%%  problem is instead of a noninformative error message, when programs crash at a later
%%  stage.
%%
%%  Christoph Juchem, 01-2006
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FCTNAME = 'SP2_Check4Bigger0R';

%--- init success flag ---
f_succ = 0;

%--- parameter check ---
narg = nargin;
if narg==1
    varName = inputname(1);
    pars    = SP2_Check4NumR(varargin{1},varName);
    if isempty(varName)
        % fprintf('%s -> variable name can not be displayed (inputname.m does not work) ...',FCTNAME);
        varName = '...';
    end
elseif narg==2
    varName = SP2_Check4StrR(varargin{2});
    pars    = SP2_Check4NumR(varargin{1},varName);
else
    fprintf('%s -> more than 2 input arguments are not allowed ...',FCTNAME);
    return
end

if ~isempty(find(pars<=0))
    fprintf('%s -> the value of <%s> is %s which is not >0 ...',FCTNAME,varName,SP2_Vec2PrintStr(pars));
    return
end

%--- update success flag ---
f_succ = 1;





end
