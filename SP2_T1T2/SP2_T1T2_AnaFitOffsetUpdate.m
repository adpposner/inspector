%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaFitOffsetUpdate
%% 
%%  Inclusion of offset in T1/T2 analysis.
%%
%%  08-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.t1t2AnaFitOffset = get(fm.t1t2.anaFitOffset,'Value');

%--- switch radiobutton ---
set(fm.t1t2.anaFitOffset,'Value',flag.t1t2AnaFitOffset)

%--- update window ---
SP2_T1T2_T1T2WinUpdate


end
