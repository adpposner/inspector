%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_MmStructSave
%% 
%%  Save full mm data structure to file.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm

FCTNAME = 'SP2_MM_MmStructSave';


%--- check directory access ---
if ~SP2_CheckDirAccessR(mm.mmStructDir)
    return
end

%--- info printout ---
fprintf('%s started...\n',FCTNAME);

%--- save mm structure to file ---
save(mm.mmStructPath,'mm')

%--- info printout ---
fprintf('Full ''mm'' data structure written to file\n%s\n',mm.mmStructPath);



