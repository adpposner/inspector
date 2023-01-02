%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ExpPointSelectUpdate
%% 
%%  Selection of frequency position [point] to be displayed.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mm flag


%--- parameter update ---
mm.expPointSelect = str2num(get(fm.mm.expPointSelect,'String'));
mm.expPointSelect = max(min(mm.expPointSelect,mm.nspecC),1);
set(fm.mm.expPointSelect,'String',num2str(mm.expPointSelect))

%--- update corresponding point index ---
SP2_MM_ExpPointToPpmConversion

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
