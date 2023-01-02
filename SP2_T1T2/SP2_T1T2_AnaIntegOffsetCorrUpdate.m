%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaIntegOffsetCorrUpdate
%% 
%%  Spectrum offset correction based on 8-10 ppm reference window.
%%
%%  10-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.t1t2OffsetCorr = get(fm.t1t2.anaIntOffCorr,'Value');

%--- switch radiobutton ---
set(fm.t1t2.anaIntOffCorr,'Value',flag.t1t2OffsetCorr)

%--- update window ---
SP2_T1T2_T1T2WinUpdate

