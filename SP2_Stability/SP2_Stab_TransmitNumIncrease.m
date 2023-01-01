%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_TransmitNumIncrease
%% 
%%  Decreases the transmit channel number to be visualized
%%
%%  01-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data stab

FCTNAME = 'SP2_Stab_TransmitNumIncrease';


%--- check parameter existence ---
if ~isfield(data,'nRcvrs')
    fprintf('%s -> Number of receivers unknown. Load data set first.\n',FCTNAME)
    return
end

%--- slice number handling ---
if stab.trans<data.nRcvrs
    stab.trans = stab.trans + 1;
    set(fm.stab.transNum,'String',num2str(stab.trans))
    stab.trans = str2double(get(fm.stab.transNum,'String'));
end
