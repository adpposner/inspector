%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DoMetabSimulation
%%
%%  Simulate saturation-recovery data set of metabolite spectrum.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm

FCTNAME = 'SP2_MM_DoMetabSimulation';


%--- init read flag ---
f_succ = 0;

%--- parameter assignment ---
% mm.sim.fidDir   = 'C:\Users\juchem\Analysis\MRS_MacroMolecule\STEAM_Combined\';
% mm.sim.fidName  = 'NAA';      % metabolite file name
mm.sim.t1       = 1.5;          % metabolite T1 [s]
mm.sim.t2       = 0.025;         % metabolite T2 [s]

%--- assign simulation delays ---
mm.satRecDelays = mm.sim.delayVec;     
mm.satRecN      = mm.sim.delayN;

% %--- basic init ---
% if ~isfield(mm,'spec')
%     if ~SP2_MM_DataLoad
%         return
%     end
% end

%--- load metabolite FID ---
mm.sim.fidPath = [mm.sim.fidDir mm.sim.fidName];
if ~SP2_CheckFileExistenceR(mm.sim.fidPath)
    return
end
unit = fopen(mm.sim.fidPath,'r');
if unit==-1
    fprintf('%s ->\nOpening FID file failed. Program aborted.\n',FCTNAME);
    return
end
dataTmp = fscanf(unit,'%g		%g',[2 inf]);
fclose(unit);
mm.sim.fid = dataTmp(1,:)' + 1i*dataTmp(2,:)';          % (original) single FID of spin

%--- load parameter file ---
if ~SP2_MM_LoadParFile([mm.sim.fidPath '.par'])
    return
end
if mm.nspecC~=size(mm.sim.fid,1)
    fprintf('%s ->\nIncosistent data dimension detected:\n(parameter file) %i ~= %i (FID dimension)\nProgram aborted.\n',...
            FCTNAME,mm.nspecC,size(mm.sim.fid,1))
    return
end

%--- creation of saturation-recovery array ---
if ~SP2_MM_CreateSatRecArray
    return
end

%--- update read flag ---
f_succ = 1;

end
