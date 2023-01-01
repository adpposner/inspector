%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat1FidFileLoadButton
%% 
%%  Load single experiment from file.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_Data_Dat1FidFileLoadButton';


%--- init success flag ---
f_succ = 0;

%--- load data from file ---
if ~SP2_Data_Dat1FidFileLoad
    return
end

%--- remove (old) Rx combination ---
if isfield(data.spec1,'fidArrRxComb')
    data.spec1 = rmfield(data.spec1,'fidArrRxComb');
end

%--- update success flag ---
f_succ = 1;

