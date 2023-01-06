%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmShowPosValUpdate
%% 
%%  Update value for frequency visualization.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn flag

%--- update percentage value ---
syn.ppmShowPos = str2num(get(fm.syn.ppmShowPosVal,'String'));     % frequency update

%--- info printout ---
if isfield(mm,'spec')
    fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',syn.ppmShowPos,...
            syn.ppmCalib,syn.ppmShowPos-syn.ppmCalib,syn.sf*(syn.ppmShowPos-syn.ppmCalib))
end

%--- parameter update ---
if flag.synExpPpmLink
    syn.expPpmSelect = syn.ppmShowPos;     % frequency update
end

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

end
