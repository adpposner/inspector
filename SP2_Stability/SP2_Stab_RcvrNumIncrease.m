%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_RcvrNumIncrease
%% 
%%  Decreases the receiver number to be visualized
%%
%%  01-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm data stab

FCTNAME = 'SP2_Stab_RcvrNumIncrease';


%--- check parameter existence ---
if ~isfield(data,'nRcvrs')
    fprintf('%s -> Number of receivers unknown. Load data set first.\n',FCTNAME);
    return
end

%--- slice number handling ---
if stab.rcvr<data.nRcvrs
    stab.rcvr = stab.rcvr + 1;
    set(fm.stab.rcvrNum,'String',num2str(stab.rcvr))
    stab.rcvr = str2double(get(fm.stab.rcvrNum,'String'));
end
