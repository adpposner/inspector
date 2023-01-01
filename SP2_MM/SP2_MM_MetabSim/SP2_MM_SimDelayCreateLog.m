%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  SP2_MM_SimDelayCreateLog
%%
%%  Generation of delay vector of simulated saturation-recovery experiment.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm fm

FCTNAME = 'SP2_MM_SimDelayCreateLog';


%--- delay calculation ---
srLogMin = log10(mm.sim.delayMin);
srLogMax = log10(mm.sim.delayMax);
mm.sim.delayVec = 10.^(srLogMin:(srLogMax-srLogMin)/(mm.sim.delayN-1):srLogMax);
mm.sim.delayStr = SP2_Vec2PrintStr(mm.sim.delayVec,3,0);          % 1 ms accuracy
mm.sim.delayN   = length(mm.sim.delayVec);

%--- transfer to sat-rec. setup ---
mm.satRecDelays = mm.sim.delayVec;
mm.satRecN      = mm.sim.delayN;

%--- display update ---
set(fm.mm.simDelayStr,'String',mm.sim.delayStr)

%--- info printout ---
fprintf('\nAssigned saturation-recovery delays (total %.0f):\n',mm.satRecN)
fprintf('%ss\n',SP2_Vec2PrintStr(mm.satRecDelays,3))
fprintf('REMEMBER TO REDO SIMULATION (if necessary).\n')

