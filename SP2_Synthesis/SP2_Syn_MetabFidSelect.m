%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_MetabFidSelect
%% 
%%  FID file selection for simulation of single metabolite spectrum.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn

FCTNAME = 'SP2_Syn_MetabFidSelect';


%--- check directory access ---
if isempty(syn.fidDir)
    if ispc
        syn.fidDir = 'C:\';
    elseif ismac
        syn.fidDir = '/Users/';
    else
        syn.fidDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(syn.fidDir);
    if ~f_succ
        syn.fidDir = maxPath;
    end
end

%--- browse the fid file ---
[filename, pathname] = uigetfile('*.par;*.mat;*.raw;*.RAW','Select metabolite FID(s) file for simulation',syn.fidDir);       % select data file
if ~ischar(filename)             % buffer select cancelation
    if ~filename            
        fprintf('%s aborted.\n',FCTNAME)
        return
    end
end

%--- update paths ---
syn.fidDir  = pathname;
syn.fidName = filename;
syn.fidPath = [syn.fidDir syn.fidName];
set(fm.syn.fidPath,'String',syn.fidPath)

%--- check file existence ---
if ~SP2_CheckFileExistenceR(syn.fidPath)
    fprintf('\nWARNING:\n%s\nMetabolite file has not been found!\n',syn.fidPath)
end
if ~SP2_CheckFileExistenceR(syn.fidPath)
    fprintf('\nWARNING:\n%s\nMetabolite parameter file has not been found!\n',syn.fidPathPar)
end

%--- update display ---
SP2_Syn_SynthesisWinUpdate

