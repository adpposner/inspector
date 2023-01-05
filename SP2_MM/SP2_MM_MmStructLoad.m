%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_MmStructLoad
%% 
%%  Load full mm data structure from file.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_MmStructLoad';


%--- check directory access ---
if ~SP2_CheckFileExistenceR(mm.mmStructPath)
    return
end

%--- info printout ---
fprintf('%s started...\n',FCTNAME);

%--- save mm structure to file ---
load(mm.mmStructPath)

%--- assure backward compatibility ---
if ~isfield(mm,'sim')
    mm.sim.delayN = 10;
end
if isfield(mm,'simDelayMin')
    mm.sim.delayMin = mm.simDelayMin;
    mm = rmfield(mm,'simDelayMin');
end
if isfield(mm,'simDelayMax')
    mm.sim.delayMax = mm.simDelayMax;
    mm = rmfield(mm,'simDelayMax');
end
if isfield(mm,'simDelayN')
    mm.sim.delayN = mm.simDelayN;
    mm = rmfield(mm,'simDelayN');
end
if ~isfield(mm.sim,'delayN')
    mm.sim.delayN = 10;
end
if ~isfield(mm.sim,'delayMin')
    mm.sim.delayMin = 0.1;
end
if ~isfield(mm.sim,'delayMax')
    mm.sim.delayMax = 10;
elseif mm.sim.delayMax<=mm.sim.delayMin
    mm.sim.delayMax = 10;
end
if ~isfield(mm,'delayVec')
    mm.sim.delayVec = mm.sim.delayMin:(mm.sim.delayMax-mm.sim.delayMin)/(mm.sim.delayN-1):mm.sim.delayMax;
end
if ~isfield(mm,'delayStr')
    mm.sim.delayStr = SP2_Vec2PrintStr(mm.sim.delayVec,3,0);          % 1 ms accuracy
end

%--- assure backward compatibility ---
if ~isfield(flag,'mmMetabRef')
    flag.mmMetabRef = 1;      
    fprintf('%s -> Note: Parameter flag.mmMetabRef added.\n',FCTNAME);
end
if ~isfield(mm,'boxCar')
    mm.boxCar = 1;
    fprintf('%s -> Note: Parameter mm.boxCar added.\n',FCTNAME);
end
if ~isfield(mm,'boxCarHz')
    mm.boxCarHz = mm.boxCar * mm.sw_h/mm.zf;      % frequency width of filter
    fprintf('%s -> Note: Parameter mm.boxCarHz added.\n',FCTNAME);
end
if ~isfield(flag,'mmTOneSpline')
    flag.mmTOneSpline = 0;     
    fprintf('%s -> Note: Parameter flag.mmTOneSpline added.\n',FCTNAME);
end

%--- info printout ---
fprintf('Full ''mm'' data structure loaded from file\n%s\n',mm.mmStructPath);

%--- window update ---
SP2_MM_MacroMain



