%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Syn_FigureUpdate
%% 
%%  Figure update function.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

%--- init success flag ---
f_succ = 0;

%--- update existing figures ---
if isfield(syn,'fhSynFidOrig') 
    if ishandle(syn.fhSynFidOrig)
        SP2_Syn_PlotFidOrig(0);
    end
end
if isfield(syn,'fhSynFid')
    if ishandle(syn.fhSynFid)
        SP2_Syn_PlotFid(0);
    end
end
if isfield(syn,'fhSynSpec')
    if ishandle(syn.fhSynSpec)
        SP2_Syn_PlotSpec(0);
    end
end

%--- update success flag ---
f_succ = 1;

