%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PolyAmpUpdate
%% 
%%  Polynomial parameter update for spectral simulation.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn


%--- parameter update ---
syn.polyAmpVec(1) = str2num(get(fm.syn.polyAmp0,'String'));
syn.polyAmpVec(2) = str2num(get(fm.syn.polyAmp1,'String'));
syn.polyAmpVec(3) = str2num(get(fm.syn.polyAmp2,'String'));
syn.polyAmpVec(4) = str2num(get(fm.syn.polyAmp3,'String'));
syn.polyAmpVec(5) = str2num(get(fm.syn.polyAmp4,'String'));
syn.polyAmpVec(6) = str2num(get(fm.syn.polyAmp5,'String'));

%--- window update ---
set(fm.syn.polyAmp0,'String',num2str(syn.polyAmpVec(1)))
set(fm.syn.polyAmp1,'String',num2str(syn.polyAmpVec(2)))
set(fm.syn.polyAmp2,'String',num2str(syn.polyAmpVec(3)))
set(fm.syn.polyAmp3,'String',num2str(syn.polyAmpVec(4)))
set(fm.syn.polyAmp4,'String',num2str(syn.polyAmpVec(5)))
set(fm.syn.polyAmp5,'String',num2str(syn.polyAmpVec(6)))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

end
