%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_LCM_CloseLcmFigures
%% 
%%  Close all spectral LCM figures.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_LCM_CloseLcmFigures';


%--- init success flag ---
f_done = 0;

%--- find alignment QA figures ---
figVec = findobj(0,'Tag','LCM');
nFig   = length(figVec);

%--- delete figures ---
for figCnt = 1:nFig
    if ishandle(figVec(figCnt))
        delete(figVec(figCnt))
    end
end

%--- update success flag ---
f_done = 1;


end
