%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_PpmShowPosFlagUpdate
%% 
%%  Enable/disable visualization of frequency position as vertical line.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag mm


%--- parameter update ---
flag.mmPpmShowPos = get(fm.mm.ppmShowPos,'Value');

%--- window update ---
set(fm.mm.ppmShowPos,'Value',flag.mmPpmShowPos)

%--- info printout ---
if flag.mmPpmShowPos && isfield(mm,'spec')
    fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',mm.ppmShowPos,...
            mm.ppmCalib,mm.ppmShowPos-mm.ppmCalib,mm.sf*(mm.ppmShowPos-mm.ppmCalib))
end

%--- parameter update ---
if flag.mmExpPpmLink
    mm.expPpmSelect = mm.ppmShowPos;     % frequency update
end

%--- figure update ---
SP2_MM_SatRecShowFidSingle(0);
SP2_MM_SatRecShowSpecSingle(0);
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_SatRecShowSpecArray(0);
SP2_MM_SatRecShowSpecSum(0);
SP2_MM_T1ShowFidSingle(0);
SP2_MM_T1ShowSpecSingle(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_T1ShowSpecArray(0);
SP2_MM_T1ShowSpecSum(0);

%--- window update ---
SP2_MM_MacroWinUpdate
