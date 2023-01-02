%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_SatRecSelectIncr
%% 
%%  Scroll downwards through saturation-recovery experiments (delays).
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mm


%--- parameter update ---
mm.satRecSelect = mm.satRecSelect + 1;
if isfield(mm,'satRecN')
    mm.satRecSelect = min(mm.satRecSelect,mm.satRecN);
end
set(fm.mm.satRecSelect,'String',num2str(mm.satRecSelect))

%--- figure update ---
SP2_MM_SatRecShowFidSingle(0);
SP2_MM_SatRecShowSpecSingle(0);
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_SatRecShowSpecArray(0);
SP2_MM_SatRecShowSpecSum(0);

%--- window update ---
SP2_MM_MacroWinUpdate


