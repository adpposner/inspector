%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_RcvrNumUpdate
%% 
%%  Updates receiver number to be analyzed / visualized
%%
%%  01-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data stab

FCTNAME = 'SP2_Stab_RcvrNumIncrease';


%--- check parameter existence ---
if ~isfield(data,'nRcvrs')
    fprintf('%s -> Number of receivers unknown. Load data set first.\n',FCTNAME);
    set(fm.stab.rcvrNum,'String',sprintf('%.0f',stab.rcvr))
    return
end

%--- display updated ---
stab.rcvr = max(min(str2double(get(fm.stab.rcvrNum,'String')),data.nRcvrs),1);
set(fm.stab.rcvrNum,'String',sprintf('%.0f',stab.rcvr))

end
