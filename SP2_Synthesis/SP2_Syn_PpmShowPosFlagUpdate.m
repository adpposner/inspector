%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmShowPosFlagUpdate
%% 
%%  Enable/disable visualization of frequency position as vertical line.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag syn


%--- parameter update ---
flag.synPpmShowPos = get(fm.syn.ppmShowPos,'Value');

%--- window update ---
set(fm.syn.ppmShowPos,'Value',flag.synPpmShowPos)

%--- info printout ---
if flag.synPpmShowPos && isfield(syn,'spec')
    fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',syn.ppmShowPos,...
            syn.ppmCalib,syn.ppmShowPos-syn.ppmCalib,syn.sf*(syn.ppmShowPos-syn.ppmCalib))
end

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
