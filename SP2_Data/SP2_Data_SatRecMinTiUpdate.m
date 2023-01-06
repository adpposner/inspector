%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_SatRecMinTiUpdate
%% 
%%  Minimum saturation-recovery delay (scan) to be used for frequency and
%%  phase alignment.
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- update points ---
data.satRec.minTI = max(str2num(get(fm.data.satRecMinTI,'String')),0);

%--- window update ---
set(fm.data.satRecMinTI,'String',sprintf('%.3f',data.satRec.minTI))

%--- parameter calc/display ---
if ~SP2_Data_SatRecMinTiIndexCalc(1)
    return
end

%--- window update ---
SP2_Data_DataWinUpdate

end
