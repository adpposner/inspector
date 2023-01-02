%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_BasisSave
%% 
%%  Save basis to file.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm

FCTNAME = 'SP2_LCM_BasisSave';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(lcm,'basis')
    fprintf('\n%s ->\nBasis structure does not exist. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(lcm.basis,'data') || lcm.basis.n==0
    fprintf('\n%s ->\nNo basis set found. Program aborted.\n',FCTNAME);
    return
end

%--- derive/update lcm.basisDir from lcm.basisPath ---
if ~SP2_LCM_LcmBasisPathUpdate
    return
end

%--- check directory access ---
[f_YesNo, maxPath, f_done] = SP2_CheckDirAccessR(lcm.basisDir);
if ~f_YesNo || ~f_done
    fprintf('%s ->\nBasis directory is not accessible. Program aborted.\n',FCTNAME);
    return
end

%--- open yes/no dialog ---
choice = questdlg('Are you sure you want to save the current set of basis functions to file?','Saving Dialog', ...
                  'Yes','No','No');

%--- combination of GlucoseA/B ---
if strcmp(choice,'Yes')
    %--- extract relevant fields ---
    lcmBasis.data     = lcm.basis.data;
    lcmBasis.sw_h     = lcm.basis.sw_h;
    lcmBasis.sf       = lcm.basis.sf;
    lcmBasis.ppmCalib = lcm.basis.ppmCalib;

    %--- save basis to file ---
    save(lcm.basisPath,'lcmBasis')
    fprintf('\nBasis set written to <%s>\n%s\n',lcm.basisFile,lcm.basisPath);
    clear lcmBasis
end

%--- update success flag ---
f_succ = 1;
