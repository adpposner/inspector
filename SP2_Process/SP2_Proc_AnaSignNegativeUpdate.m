%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AnaSignNegativeUpdate
%% 
%%  Perform SNR/FWHM/integration analysis for peak of positive polarity.
%%
%%  01-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.procAnaSign = ~get(fm.proc.anaSignNeg,'Value');

%--- window update ---
set(fm.proc.anaSignPos,'Value',flag.procAnaSign)
set(fm.proc.anaSignNeg,'Value',~flag.procAnaSign)

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
