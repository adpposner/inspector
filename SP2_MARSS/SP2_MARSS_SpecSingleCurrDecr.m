%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SpecSingleCurrDecr
%% 
%%  Lower number of metabolite to be displayed.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss


%--- update display value ---
marss.currShow = max(marss.currShow-1,1);       % current metabolite

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- figure update ---
if ~SP2_MARSS_PlotSpecSingle( 1 )
    fprintf('Figure update of single spectrum failed.\n');
    return
end

end
