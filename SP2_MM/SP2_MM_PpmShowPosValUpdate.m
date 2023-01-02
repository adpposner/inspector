%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_PpmShowPosValUpdate
%% 
%%  Update value for frequency visualization.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mm flag

%--- update percentage value ---
mm.ppmShowPos = str2num(get(fm.mm.ppmShowPosVal,'String'));     % frequency update

%--- info printout ---
if isfield(mm,'spec')
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

