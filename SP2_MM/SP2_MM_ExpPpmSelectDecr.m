%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ExpPpmSelectDecr
%% 
%%  Scroll downwards through frequency positions [ppm].
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag


%--- parameter update ---
mm.expPpmSelect = mm.expPpmSelect - 0.1;

%--- update corresponding point index ---
SP2_MM_ExpPpmToPointConversion

%--- parameter update ---
if flag.mmExpPpmLink
    mm.ppmShowPos = mm.expPpmSelect;     % frequency update
end

%--- figure updates ---
SP2_MM_SatRecShowFidSingle(0);
SP2_MM_SatRecShowSpecSingle(0);
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_SatRecShowSpecArray(0);
SP2_MM_SatRecShowSpecSum(0);
SP2_MM_SatRecShowSpecSubtract(0);
SP2_MM_T1ShowFidSingle(0);
SP2_MM_T1ShowSpecSingle(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_T1ShowSpecArray(0);
SP2_MM_T1ShowSpecSum(0);
SP2_MM_T1ShowSpecSubtract(0);
SP2_MM_T1ShowSpec2D(0);

%--- figure update ---
SP2_MM_ExpFitAnalysis(0);

%--- window update ---
SP2_MM_MacroWinUpdate


