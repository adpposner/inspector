%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_BasisFigureUpdate
%% 
%%  Figure update function.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm

%--- init success flag ---
f_succ = 0;

%--- update existing figures ---
if isfield(lcm,'fhBasisSpec')
    if ishandle(lcm.fhBasisSpec)
        if ~SP2_LCM_BasisPlotSpecSingle(lcm.basis.currShow,0)
            return
        end
    end
end

%--- update success flag ---
f_succ = 1;


end
