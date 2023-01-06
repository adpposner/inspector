%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_Dat2FidFileLoadButton
%% 
%%  Load single reference experiment from file.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_Data_Dat2FidFileLoadButton';


%--- init success flag ---
f_done = 0;

%--- load data from file ---
if ~SP2_Data_Dat2FidFileLoad
    return
end

%--- remove (old) Rx combination ---
if isfield(data.spec2,'fidArrRxComb')
    data.spec2 = rmfield(data.spec2,'fidArrRxComb');
end

%--- update success flag ---
f_done = 1;


end
