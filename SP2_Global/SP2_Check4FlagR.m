%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [pars, f_succ] = SP2_Check4FlagR(pars)
%%
%%  Checks if variable 'pars' has been assigned a numeric value 0 or 1. If
%%  not an error message is return. The function is used to check function
%%  arguments for correct parameter assignment. Doing so, the user gets to 
%%  know, what the problem is instead of a noninformative error message,
%%  when programs crash at a later stage.
%%
%%  Christoph Juchem, 06-2004
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FCTNAME = 'SP2_Check4FlagR';


%--- init success flag ---
f_succ = 0;

%--- parameter check ---
if ~isnumeric(pars)
    if iscell(pars)
        fprintf('%s ->\nParameter is cell array and not a number!\n\n',FCTNAME);
        return
    end
    if iscellstr(pars)
        fprintf('%s ->\nParameter is cell array of strings and not a number!\n\n',FCTNAME);
        return
    end
    if isempty(pars)
        fprintf('%s ->\nParameter is empty and not a number!\n\n',FCTNAME);
        return
    end
    if ischar(pars)
        fprintf('%s ->\nParameter is not a number, but a string!\n\n',FCTNAME);
        return
    end
    if isobject(pars)
        fprintf('%s ->\nParameter is not a number, but an object!\n\n',FCTNAME);
        return
    end
    if isstruct(pars)
        fprintf('%s ->\nParameter is not a number, but a structure!\n\n',FCTNAME);
        return
    end
end
if pars~=0 && pars~=1
    fprintf('%s ->\nParameter is numeric but its value is %d\n\n',FCTNAME);
    return
end

%--- update success flag ---
f_succ = 1;



