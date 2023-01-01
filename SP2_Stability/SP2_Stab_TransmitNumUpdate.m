%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_TransmitNumUpdate
%% 
%%  Updates transmit channel number to be analyzed / visualized
%%
%%  01-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data stab

FCTNAME = 'SP2_Stab_TransmitNumIncrease';


%--- check parameter existence ---
if ~isfield(data,'nRcvrs')
    fprintf('%s -> Number of receivers unknown. Load data set first.\n',FCTNAME)
    set(fm.stab.transNum,'String',sprintf('%.0f',stab.trans))
    return
end

%--- display updated ---
stab.trans = max(min(str2double(get(fm.stab.transNum,'String')),data.nRcvrs),1);
set(fm.stab.transNum,'String',sprintf('%.0f',stab.trans))
