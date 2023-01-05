%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Stab_DoBinMaxFFT
%%
%%  Frequency bin-specific spectral analysis of maximum vector.
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global stab

FCTNAME = 'SP2_Stab_DoBinMaxFFT';


%--- check data existence ---
if ~isfield(stab,'rangeMax')
    fprintf('stab.rangeMax does not exist. Program aborted.\n');
    return
end
if ~isfield(stab,'tr')
    fprintf('stab.tr does not exist. Program aborted.\n');
    return
end


stab.rangeMax
