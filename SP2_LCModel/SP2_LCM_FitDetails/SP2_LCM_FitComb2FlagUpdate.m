%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitComb2FlagUpdate
%% 
%%  Switching on/off the combination of metabolites for LCModel CRLB analysis.
%%
%%  05-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmComb2 = get(fm.lcm.fit.comb2Flag,'Value');
set(fm.lcm.fit.comb2Flag,'Value',flag.lcmComb2)

%--- parameter update ---
lcm.combN   = flag.lcmComb1 + flag.lcmComb2 + flag.lcmComb3;        % number of combinations selected
lcm.combInd = find([flag.lcmComb1 flag.lcmComb2 flag.lcmComb3]);    % index vector of metabolite combinations selected

%--- window update ---
SP2_LCM_FitDetailsWinUpdate
SP2_LCM_LCModelWinUpdate




end
