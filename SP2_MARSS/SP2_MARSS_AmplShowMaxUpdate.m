%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_AmplShowMaxUpdate
%% 
%%  Update function of display amplitude maximum.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss


%--- maximum amplitude ---
marss.amplShowMax = str2num(get(fm.marss.amplShowMax,'String'));
if isempty(marss.amplShowMax)
    marss.amplShowMax = 10000;
end
marss.amplShowMax = max(marss.amplShowMin,marss.amplShowMax);
set(fm.marss.amplShowMax,'String',num2str(marss.amplShowMax))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate



end
