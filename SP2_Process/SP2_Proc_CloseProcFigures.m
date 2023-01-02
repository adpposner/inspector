%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_CloseProcFigures
%% 
%%  Close all spectral processing figures.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Proc_CloseProcFigures';


%--- init success flag ---
f_done = 0;

%--- find alignment QA figures ---
figVec = findobj(0,'Tag','Proc');
nFig   = length(figVec);

%--- delete figures ---
for figCnt = 1:nFig
    if ishandle(figVec(figCnt))
        delete(figVec(figCnt))
    end
end

%--- update success flag ---
f_done = 1;

