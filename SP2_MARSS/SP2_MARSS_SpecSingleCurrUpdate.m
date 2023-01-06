%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SpecSingleCurrUpdate
%% 
%%  Update of current metabolite selection.
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss


%--- update current metabolite ---
marss.currShow = max(min(str2double(get(fm.marss.singleCurr,'String')),max(marss.basis.n,1)),1);

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- figure update ---
if ~SP2_MARSS_PlotSpecSingle( 1 )
    fprintf('Figure update of single spectrum failed.\n');
    return
end

end
