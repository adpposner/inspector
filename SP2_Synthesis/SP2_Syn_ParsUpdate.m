%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_ParsUpdate
%% 
%%  Parameter update for quality assessment page.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn


%--- Larmor frequency ---
syn.sf = max(str2num(get(fm.syn.sf,'String')),1);
set(fm.syn.sf,'String',num2str(syn.sf))

%--- frequency calibration ---
syn.ppmCalib = str2num(get(fm.syn.ppmCalib,'String'));
set(fm.syn.ppmCalib,'String',num2str(syn.ppmCalib))

%--- bandwidth ---
syn.sw_h = max(str2num(get(fm.syn.sw_h,'String')),100);
set(fm.syn.sw_h,'String',num2str(syn.sw_h))

%--- basic number of points ---
syn.nspecCBasic = max(str2num(get(fm.syn.nspecCBasic,'String')),16);
set(fm.syn.nspecCBasic,'String',num2str(syn.nspecCBasic))

%--- minimum amplitude ---
syn.amplShowMin = str2num(get(fm.syn.amplShowMin,'String'));
if isempty(syn.amplShowMin)
    syn.amplShowMin = -10000;
end
syn.amplShowMin = min(syn.amplShowMin,syn.amplShowMax);
set(fm.syn.amplShowMin,'String',num2str(syn.amplShowMin))

%--- maximum amplitude ---
syn.amplShowMax = str2num(get(fm.syn.amplShowMax,'String'));
if isempty(syn.amplShowMax)
    syn.amplShowMax = 10000;
end
syn.amplShowMax = max(syn.amplShowMin,syn.amplShowMax);
set(fm.syn.amplShowMax,'String',num2str(syn.amplShowMax))

%--- minimum amplitude ---
syn.ppmShowMin = str2num(get(fm.syn.ppmShowMin,'String'));
if isempty(syn.ppmShowMin)
    syn.ppmShowMin = 0;
end
syn.ppmShowMin = min(syn.ppmShowMin,syn.ppmShowMax(1));
set(fm.syn.ppmShowMin,'String',sprintf('%.2f',syn.ppmShowMin))

%--- maximum amplitude ---
syn.ppmShowMax = str2num(get(fm.syn.ppmShowMax,'String'));
if isempty(syn.ppmShowMax)
    syn.ppmShowMax = 5;
end
syn.ppmShowMax = max(syn.ppmShowMin(1),syn.ppmShowMax);
set(fm.syn.ppmShowMax,'String',sprintf('%.2f',syn.ppmShowMax))

%--- derive secondary parameters ---
syn.sw         = syn.sw_h/syn.sf;        % sweep width in [ppm]
syn.dwell      = 1/syn.sw_h;             % dwell time

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
