%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SpecSingleCurrIncr
%% 
%%  Lower number of metabolite to be displayed.
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss


%--- update display value ---
marss.currShow = min(marss.currShow+1,max(marss.basis.n,1));        % current metabolite

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- figure update ---
if ~SP2_MARSS_PlotSpecSingle( 1 )
    fprintf('Figure update of single spectrum failed.\n');
    return
end

end
