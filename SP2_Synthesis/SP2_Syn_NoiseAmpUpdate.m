%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_NoiseAmpUpdate
%% 
%%  Update noise amplitude.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn flag


%--- keep original noise amplitude for reference ---
if flag.synNoiseKeep
    syn.noiseAmpOrig = syn.noiseAmp;
end

%--- update amplitude window ---
syn.noiseAmp = str2double(get(fm.syn.noiseAmp,'String'));

%--- rescale original noise pattern ---
if flag.synNoiseKeep
    syn.noise = syn.noiseAmp/syn.noiseAmpOrig * syn.noise;
end

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

end
