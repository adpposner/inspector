%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisPpmCalibUpdate
%% 
%%  Update frequency calibration of LCM basis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- update percentage value ---
lcm.basis.ppmCalib = str2num(get(fm.lcm.basis.ppmCalib,'String'));
set(fm.lcm.basis.ppmCalib,'String',num2str(lcm.basis.ppmCalib))


end
