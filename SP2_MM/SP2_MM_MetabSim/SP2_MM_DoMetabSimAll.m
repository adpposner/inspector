%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DoMetabSimAll
%%
%%  Simulate saturation-recovery data set of all STEAM metabolite spectra.
%%  for both 1) individual moeities and 2) the sum of all moeities. 
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_DoMetabSimAll';

parDir     = 'C:\Users\juchem\Analysis\LCModel\MetaboliteLibraryBrainInVivo_NMRWizard\';        % parameter directory
resultDir  = 'C:\Users\juchem\analysis\MRS_MacroMolecule\STEAM_Moieties\';                      % result directory, individual protons
satRecDir  = 'C:\Users\juchem\analysis\MRS_MacroMolecule\STEAM_SatRec\';                        % result directory, individual protons
metabCell  = {'Acetate','Alanine','Ascorbate','Aspartate','Choline_H1H2','Choline_singleH3',...
              'Creatine','Ethanol','EthAmine','GABA','Glutamate','Glutamine',...
              'Glycine','GPC_Glycerol','GPC_ChoH7H8','GPC_ChoSingleH9',...
              'GSH_Cys','GSH_Glu','GSH_Gly',...
              'Homocarn_AlphaBeta','Homocarn_GABA','Homocarn_Imidazole',...
              'Lactate','MyoInositol','NAA','NAAG_Acetyl','NAAG_Aspartate',...
              'NAAG_Glutamate','PCr_Upfield','PCr_Downfield',...
              'PCho_H1H2','PCho_singleH3','PE','ScylloInositol','Singlet4ppm',...
              'Taurine','Water','GlucoseA','GlucoseB'};
% metabCell  = {'NAAG_Glutamate'};

         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- init read flag ---
f_succ = 0;

%--- parameter assignment ---
mm.sim.fidDir   = resultDir;
% mm.sim.fidName  = 'NAA';      % metabolite file name
mm.sim.t1       = 1.5;          % metabolite T1 [s]
mm.sim.t2       = 0.025;         % metabolite T2 [s]

%--- assign simulation delays ---
mm.satRecDelays = mm.sim.delayVec;     
mm.satRecN      = mm.sim.delayN;

%--- basic init ---
if ~isfield(mm,'spec')
    if ~SP2_MM_DataLoad
        return
    end
end

%--- keep SPX parameters ---
mmMmStructPath = mm.mmStructPath;

%--- metabolite handling ---
metabN = length(metabCell);             % number of metabolite spin systems (incl. individual moeities)

%--- consistency checks ---
if ~SP2_CheckDirAccessR(resultDir)
    return
end

%--- saturation-recovery directory handling ---
% flag.OS = 0;
if ispc
    flag.OS = 0;
elseif ismac
    flag.OS = 2;
else
    flag.OS = 1;
end
if ~SP2_CheckDirAccessR(satRecDir)
    [f_succ,msg,msgId] = mkdir(satRecDir);
    if f_succ
        fprintf('Directory <%s> created.\n',satRecDir);
    else
        fprintf('Directory creation failed. Program aborted.\n%s\n\n',msg);
        return
    end
end  
    
%--- create log file ---
logId = fopen([satRecDir 'SingleMetabCreation.log'],'w');
fprintf(logId,'SIMULATION OF MOIETY-SPECIFIC SATURATION-RECOVERY SPECTRAL ARRAYS\n');
fprintf(logId,'%s\n\n',datestr(now));

%--- copy parameter files ---
baseCell  = intersect(strtok(metabCell,'_'),strtok(metabCell,'_'));  % strip off extensions and kick out dublicates
baseN     = length(baseCell);               % number of LCModel basis element, i.e. number of metabolites
for bCnt = 1:baseN
    %--- path handling ---
    parOrig = [resultDir baseCell{bCnt} '.par'];
    if ~SP2_CheckFileExistenceR(parOrig)
        return
    end
    parSingle = [satRecDir baseCell{bCnt} '.par'];

    %--- copy file ---
    [f_succ,msg,msgId] = copyfile(parOrig,parSingle);
    if f_succ
        fprintf('<%s> copied/created\n',parSingle);
        fprintf(logId,'<%s> copied/created\n',parSingle);
    else
        fprintf('\nCopying <%s>\nto <%s> failed.\nProgram aborted.\n%s\n\n',...
                parOrig,parSingle,msg)
        return
    end
end

%--- load (one) parameter file ---
if ~SP2_MM_LoadParFile(parSingle)
    return
end

%--- copy simulation parameters ---
if SP2_CheckFileExistenceR([resultDir 'BasisRFOffset.txt'])
    [f_succ,msg,msgId] = copyfile([resultDir 'BasisRFOffset.txt'],[satRecDir 'BasisRFOffset.txt']);
    if f_succ
        fprintf('<%s> copied/created\n',[satRecDir 'BasisRFOffset.txt']);
        fprintf(logId,'<%s> copied/created\n',[satRecDir 'BasisRFOffset.txt']);
    else
        fprintf('\nCopying <%s>\nto <%s> failed.\nProgram aborted.\n%s\n\n',...
                [resultDir 'BasisRFOffset.txt'],[satRecDir 'BasisRFOffset.txt'],msg)
        fprintf(logId,'\nCopying <%s>\nto <%s> failed.\nProgram aborted.\n%s\n\n',...
                [resultDir 'BasisRFOffset.txt'],[satRecDir 'BasisRFOffset.txt'],msg)
    end
end
if SP2_CheckFileExistenceR([resultDir 'BasisSetParameters.txt'])
    [f_succ,msg,msgId] = copyfile([resultDir 'BasisSetParameters.txt'],[satRecDir 'BasisSetParameters.txt']);
    if f_succ
        fprintf('<%s> copied/created\n',[satRecDir 'BasisSetParameters.txt']);
        fprintf(logId,'<%s> copied/created\n',[satRecDir 'BasisSetParameters.txt']);
    else
        fprintf('\nCopying <%s>\nto <%s> failed.\nProgram aborted.\n%s\n\n',...
                [resultDir 'BasisSetParameters.txt'],[satRecDir 'BasisSetParameters.txt'],msg)
        fprintf(logId,'\nCopying <%s>\nto <%s> failed.\nProgram aborted.\n%s\n\n',...
                [resultDir 'BasisSetParameters.txt'],[satRecDir 'BasisSetParameters.txt'],msg)
    end
end

%--- combine FID files ---
% extract FID files
dirStruct = dir(resultDir);                 % all directory content
fileCell  = {};
fCnt      = 0;
for dCnt = 1:length(dirStruct)
   if isempty(findstr('.',dirStruct(dCnt).name)) && ~isdir(dirStruct(dCnt).name)
       fCnt = fCnt + 1;
       fileCell{fCnt} = dirStruct(dCnt).name;
   end    
end

%--- strip off unnecessary fields ---
if ~SP2_LOC_StripOffFields
    return
end

%--- combine all FIDs from the same metabolite and save to file ---
for bCnt = 1:baseN
    %--- init/reset FID vector ---
    fid = 0;
    
    %--- find relevant files ---
    fileInd = strmatch(baseCell{bCnt},fileCell);
    if strcmp(baseCell{bCnt},'NAA')
        naagInd = strmatch('NAAG',fileCell);
        fileInd = fileInd(~ismember(fileInd,naagInd));  % i.e. naaInd
    end
    
    %--- data handling ---
    fprintf('\nMETABOLITE: %s\n',baseCell{bCnt});
    fprintf(logId,'\nMETABOLITE: %s\n',baseCell{bCnt});
    for fCnt = 1:length(fileInd)
        %--- info printout ---
        fprintf('%.0f) %s\n',fCnt,fileCell{fileInd(fCnt)});
        fprintf(logId,'%.0f) %s\n',fCnt,fileCell{fileInd(fCnt)});
    
        %--- load FID of individual moiety ---
        fidMoiety = SP2_RagLoadFid([resultDir fileCell{fileInd(fCnt)}]);
        
        %--- creation of saturation-recovery array ---
        mm.sim.fid = fidMoiety;
        if ~SP2_MM_CreateSatRecArray
            return
        end

        %--- save SR array to file ---
        mm.mmStructPath = [satRecDir fileCell{fileInd(fCnt)}];
        save(mm.mmStructPath,'mm')
        
        %--- data handling ---
        fid = fid + fidMoiety;
    end
    
    %--- creation of saturation-recovery array ---
    mm.sim.fid = fid;
    if ~SP2_MM_CreateSatRecArray
        return
    end
    
    %--- save SR array to file ---
    mm.mmStructPath = [satRecDir baseCell{bCnt}];
    save(mm.mmStructPath,'mm')
      
    
    fprintf('All %s signals combined in single file\n',baseCell{bCnt});
    fprintf(logId,'All %s signals combined in single file\n',baseCell{bCnt});
end

%--- close log file ---
fprintf(logId,'\n');
fclose(logId);

%--- restore parameters ---
mm.mmStructPath = mmMmStructPath;

%--- info printout ---
fprintf('%s completed.\n',FCTNAME);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   L O C A L    F U N C T I O N S                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f_succ = SP2_LOC_StripOffFields
global mm

f_succ = 0;

if isfield(mm,'fidOrig')
    mm = rmfield(mm,'fidOrig');
end
if isfield(mm,'t1spec')
    mm = rmfield(mm,'t1spec');
end
if isfield(mm,'t1specFit')
    mm = rmfield(mm,'t1specFit');
end
if isfield(mm,'res2norm')
    mm = rmfield(mm,'res2norm');
end
if isfield(mm,'satRecSpecFit')
    mm = rmfield(mm,'satRecSpecFit');
end
if isfield(mm,'satRecSpecFine')
    mm = rmfield(mm,'satRecSpecFine');
end
if isfield(mm,'anaOptApplInd')
    mm = rmfield(mm,'anaOptApplInd');
end
if isfield(mm,'t1fit')
    mm = rmfield(mm,'t1fit');
end
if isfield(mm,'satRecSpec')
    mm = rmfield(mm,'satRecSpec');
end
if isfield(mm,'t1fid')
    mm = rmfield(mm,'t1fid');
end
    
f_succ = 1;







