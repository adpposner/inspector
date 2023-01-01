%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_CloseMarssFigures
%% 
%%  Close all spectral MARSS figures.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MARSS_CloseMarssFigures';


%--- init success flag ---
f_succ = 0;

%--- find alignment QA figures ---
figVec = findobj(0,'Tag','MARSS');
nFig   = length(figVec);

%--- delete figures ---
if nFig>0
    for figCnt = 1:nFig
        if ishandle(figVec(figCnt))
            delete(figVec(figCnt))
        end
    end
else
    fprintf('No open MARSS figures found.\n')
end

%--- update success flag ---
f_succ = 1;

