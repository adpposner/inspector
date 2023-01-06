%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ExpPpmLinkFlagUpdate
%% 
%%  Enable/disable visualization of frequency position as vertical line.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag mm


%--- parameter update ---
flag.mmExpPpmLink = get(fm.mm.expPpmLink,'Value');

%--- window update ---
set(fm.mm.expPpmLink,'Value',flag.mmExpPpmLink)

%--- parameter update ---
if flag.mmExpPpmLink
    set(fm.mm.expPpmSelect,'String',num2str(mm.ppmShowPos))
    SP2_MM_ExpPpmSelectUpdate
end

%--- figure update ---
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

%--- window update ---
SP2_MM_MacroWinUpdate

end
