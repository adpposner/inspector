%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_AmplShowMinUpdate
%% 
%%  Update function of display amplitude minimum.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss


%--- minimum amplitude ---
marss.amplShowMin = str2num(get(fm.marss.amplShowMin,'String'));
if isempty(marss.amplShowMin)
    marss.amplShowMin = -10000;
end
marss.amplShowMin = min(marss.amplShowMin,marss.amplShowMax);
set(fm.marss.amplShowMin,'String',num2str(marss.amplShowMin))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate



end
