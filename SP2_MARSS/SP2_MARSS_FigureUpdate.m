%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_FigureUpdate
%% 
%%  Figure update function.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss

%--- init success flag ---
f_succ = 0;

%--- update existing figures ---
if isfield(marss,'fhMarssSpecSuperpos')
    if ishandle(marss.fhMarssSpecSuperpos)
        if ~SP2_MARSS_PlotSpecSuperpos(0)
            return
        end
    end
end
if isfield(marss,'fhMarssSpecSum')
    if ishandle(marss.fhMarssSpecSum)
        if ~SP2_MARSS_PlotSpecSum(0)
            return
        end
    end
end
if isfield(marss,'fhMarssSpecSingle')
    if ishandle(marss.fhMarssSpecSingle)
        if ~SP2_MARSS_PlotSpecSingle(0)
            return
        end
    end
end

%--- update success flag ---
f_succ = 1;

