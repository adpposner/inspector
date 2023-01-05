%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_SimDelayStrUpdate
%% 
%%  Update function for selection of vector of saturation-recovery delays
%%  used for simulation of FID array.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm

FCTNAME = 'SP2_MM_SimDelayStrUpdate';


%--- initial string assignment ---
mm.sim.delayStr = get(fm.mm.simDelayStr,'String');

%--- consistency check ---
if any(mm.sim.delayStr==',') || any(mm.sim.delayStr==';') || ...
   any(mm.sim.delayStr=='[') || any(mm.sim.delayStr==']') || ...
   any(mm.sim.delayStr=='(') || any(mm.sim.delayStr==')') || ...
   any(mm.sim.delayStr=='''')
    fprintf('\nSaturation-recovery delays have to be assigned as space-\n');
    fprintf('separated list using the following format:\n');
    fprintf('example 1: 1:2:5\n');
    fprintf('example 2: 0.1:0.2:10 15:20 12\n\n');
    return
end

%--- calibration vector assignment ---
mm.sim.delayVec = eval(['[' mm.sim.delayStr ']']);       % vector assignment
mm.sim.delayN   = length(mm.sim.delayVec);               % total number

%--- check for vector consistency ---
if any(diff(mm.sim.delayVec)==0)
    fprintf('%s ->\nMultiple assignments of the same experiment detected...\n',FCTNAME);
    return
end
if ~isnumeric(mm.sim.delayVec)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if isempty(mm.sim.delayVec)
    fprintf('%s ->\nEmpty calibration vector detected.\nMinimum: 1 calibration experiment!\n',FCTNAME);
    mm.sim.delayStr = '1:10';
    mm.sim.delayVec = str2num(mm.sim.delayStr);
    mm.sim.delayN   = length(mm.sim.delayVec);
    return
end

%--- transfer to sat-rec. setup ---
mm.satRecDelays = mm.sim.delayVec;
mm.satRecN      = mm.sim.delayN;

%--- display update ---
set(fm.mm.simDelayStr,'String',mm.sim.delayStr)

%--- info printout ---
fprintf('\nAssigned saturation-recovery delays (total %.0f):\n',mm.satRecN);
fprintf('%ss\n',SP2_Vec2PrintStr(mm.satRecDelays,3));
fprintf('REMEMBER TO REDO SIMULATION (if necessary).\n');

%--- window update ---
SP2_MM_MacroWinUpdate



