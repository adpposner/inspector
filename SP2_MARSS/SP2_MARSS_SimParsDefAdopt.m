%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_SimParsDefAdopt
%% 
%%  Adopt, i.e. transfer, all relevant spectral characteristics from other
%%  INSPECTOR pages to the MARSS page for simulation.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss flag

FCTNAME = 'SP2_MARSS_SimParsDefAdopt';


%--- init success flag ---
f_succ = 0;

%--- parameter assignment ---
switch flag.marssSimParsDef
    case 1          % Data
        %--- experimental data ---
        if ~SP2_MARSS_SimParsLoadFromData
            fprintf('%s ->\nParameter assignment from experiment page failed. Program aborted.\n\n',FCTNAME)
            return
        end

        %--- info printout ---
        fprintf('%s ->\nExperimental parameters assigned\n',FCTNAME)
    case 2          % Processing
        %--- processing sheet ---
        if ~SP2_MARSS_SimParsLoadFromProc
            fprintf('%s ->\nParameter assignemt from processing page failed. Program aborted.\n\n',FCTNAME)
            return
        end

        %--- info printout ---
        fprintf('%s ->\nProcessing parameters assigned\n',FCTNAME)
    case 4          % MRSI
        %--- MRSI sheet ---
        if ~SP2_MARSS_SimParsLoadFromMrsi
            fprintf('%s ->\nParameter assignment from MRSI page failed. Program aborted.\n\n',FCTNAME)
            return
        end

        %--- info printout ---
        fprintf('%s ->\nMRSI parameters assigned\n',FCTNAME)
    case 5          % LCM
        %--- import FID from LCM sheet ---
        if ~SP2_MARSS_SimParsLoadFromLcm
            fprintf('%s ->\nParameter assignment from LCM page failed. Program aborted.\n\n',FCTNAME)
            return
        end

        %--- info printout ---
        fprintf('%s ->\nLCM parameters assigned\n',FCTNAME)
    case 6          % Simulation
        %--- import FID from simulation sheet ---
        if ~SP2_MARSS_SimParsLoadFromSim
            fprintf('%s ->\nParameter assignment from simulation page failed. Program aborted.\n\n',FCTNAME)
            return
        end

        %--- info printout ---
        fprintf('%s ->\nSimulation parameters assigned\n',FCTNAME)
    otherwise     
        %--- info printout ---
        fprintf('%s ->\nInvalid parameter flag value flag.marssSimParsDef=%.0f\n',FCTNAME,flag.marssSimParsDef)
        return
end

%--- window update ---
% Larmor frequency in [Hertz]
set(fm.marss.sf,'String',sprintf('%.2f',marss.sf))
% Larmor frequency in [Tesla]
set(fm.marss.b0,'String',sprintf('%.3f',marss.b0))
% bandwidth in [Hertz]
set(fm.marss.sw_h,'String',sprintf('%.1f',marss.sw_h))
% bandwidth in [ppm]
set(fm.marss.sw,'String',sprintf('%.3f',marss.sw))
% frequency calibration
set(fm.marss.ppmCalib,'String',num2str(marss.ppmCalib))
% basic number of points
set(fm.marss.nspecCBasic,'String',num2str(marss.nspecCBasic))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;

