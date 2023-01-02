%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ExpFitAnalysis( f_new )
%%
%%  Analysis of multi-exponential fitting result.
%% 
%%  10-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_MM_ExpFitAnalysis';


%--- fitting mode selection ---
if flag.mmAnaTOneMode
    SP2_MM_ExpFitAnalysisFixed( f_new )
else
    SP2_MM_ExpFitAnalysisFlexible( f_new )
end

