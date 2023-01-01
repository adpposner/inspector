%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmCalibUpdate
%% 
%%  Update frequency calibration
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn flag


%--- update percentage value ---
syn.ppmCalib = str2num(get(fm.syn.ppmCalib,'String'));
set(fm.syn.ppmCalib,'String',num2str(syn.ppmCalib))

%--- ppm position update ---
if flag.synPpmShowPos
    SP2_Syn_PpmShowPosValUpdate
end

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate


