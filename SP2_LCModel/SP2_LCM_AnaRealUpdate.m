%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaRealUpdate
%% 
%%  Updates radiobutton setting: Analyze real (part of) FID.
%%
%%  05-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


flag.lcmRealComplex = get(fm.lcm.anaReal,'Value');

%--- switch radiobutton ---
set(fm.lcm.anaReal,'Value',flag.lcmRealComplex)
set(fm.lcm.anaComplex,'Value',~flag.lcmRealComplex)

%--- update window ---
SP2_LCM_LCModelWinUpdate

