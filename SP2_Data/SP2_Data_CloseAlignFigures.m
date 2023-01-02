%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_CloseAlignFigures
%% 
%%  Close all alignment QA figures.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_CloseAlignFigures';


%--- init success flag ---
f_done = 0;

%--- find alignment QA figures ---
figVec = findobj(0,'Tag','AlignQA');
nFig   = length(figVec);

%--- delete figures ---
for figCnt = 1:nFig
    if ishandle(figVec(figCnt))
        delete(figVec(figCnt))
    end
end

%--- update success flag ---
f_done = 1;

