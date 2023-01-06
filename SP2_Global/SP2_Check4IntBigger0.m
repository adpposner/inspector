%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Check4IntBigger0(pars,varargin)
%%
%%  function SP2_Check4IntBigger0(pars)
%%  Checks if variable 'pars' has been assigned an numeric integer value. If not an error message
%%  is return, if it is, nothing is returned. The function is used to check function
%%  arguments for correct parameter format. Doing so, the user gets to know, what the
%%  problem is instead of a noninformative error message, when programs crash at a later
%%  stage. In addition the numeric value is checked to be bigger than zero.
%%  A second argument can be used to assign an accuracy limit. If e.g. varargin{1}=10, values
%%  are considered to be integers, if the deviation to the next integer value is below 1e-10.
%%  This is an resonable approach in cases, where 'integer' value are not assigned, but the
%%  result of earlier calculation. One example is 1e3^(1/3) which doesn't result to 10, but
%%  to 10 - 1.8e-15. Therefore pars = SP2_Check4IntR(1e3^(1/3),13) and no error message is returned
%% 
%%  Christoph Juchem, 08-2005
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FCTNAME = 'SP2_Check4IntBigger0';


%--- init success flag ---
f_succ = 0;

%--- parameter assessment ---
if ~isnumeric(pars)
    if iscell(pars)
        fprintf('%s -> parameter is cell array and not a number!',FCTNAME);
        return
    end
    if iscellstr(pars)
        fprintf('%s -> parameter is cell array of strings and not a number!',FCTNAME);
        return
    end
    if isempty(pars)
        fprintf('%s -> parameter is empty and not a number!',FCTNAME);
        return
    end
    if ischar(pars)
        fprintf('%s -> parameter is not a number, but a string!',FCTNAME);
        return
    end
    if isobject(pars)
        fprintf('%s -> parameter is not a number, but an object!',FCTNAME);
        return
    end
    if isstruct(pars)
        fprintf('%s -> parameter is not a number, but a structure!',FCTNAME);
        return
    end
end

narg = nargin;
if narg==2
    nOrder = SP2_Check4NumR(varargin{1});
elseif narg~=1
    fprintf('%s -> only one or two function arguments are supported...',FCTNAME);
    return
end

roundPars = round(pars);
if narg==1
    if pars-roundPars~=0
        fprintf('%s -> parameter is numeric but hasn''t been assigned an integer value (%.3f)',FCTNAME,pars);
        return
    end
else    % narg==2
    if abs(pars-roundPars)>10^(-nOrder)
        fprintf('%s -> parameter is numeric but hasn''t been assigned an integer value (%.3f)',FCTNAME,pars);
        return
    end
end
pars = round(pars);             % for integers, rounding has no effect. Deviations below 1e-nOrder are removed by this procedure
if pars<=0
    fprintf('%s -> parameter value %.1f is not bigger zero...',FCTNAME,pars);
    return
end

%--- update success flag ---
f_succ = 1;



end
