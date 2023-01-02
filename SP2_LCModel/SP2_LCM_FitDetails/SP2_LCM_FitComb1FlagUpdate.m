%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitComb1FlagUpdate
%% 
%%  Switching on/off the combination of metabolites for LCModel CRLB analysis.
%%
%%  05-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.lcmComb1 = get(fm.lcm.fit.comb1Flag,'Value');
set(fm.lcm.fit.comb1Flag,'Value',flag.lcmComb1)

%--- parameter update ---
lcm.combN   = flag.lcmComb1 + flag.lcmComb2 + flag.lcmComb3;        % number of combinations selected
lcm.combInd = find([flag.lcmComb1 flag.lcmComb2 flag.lcmComb3]);    % index vector of metabolite combinations selected

%--- window update ---
SP2_LCM_FitDetailsWinUpdate
SP2_LCM_LCModelWinUpdate



