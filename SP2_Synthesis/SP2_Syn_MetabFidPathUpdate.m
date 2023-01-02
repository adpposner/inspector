%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_MetabFidPathUpdate
%% 
%%  Update file path of FID used for simulation.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm syn flag


FCTNAME = 'SP2_Syn_MetabFidPathUpdate';


%--- fid file assignment ---
synFidPathTmp = get(fm.syn.fidPath,'String');
synFidPathTmp = SP2_SlashWinLin(synFidPathTmp);
if isempty(synFidPathTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.syn.fidPath,'String',syn.fidPath)
    return
end
if ~any(strfind(synFidPathTmp,'.'))
    fprintf('%s ->\nAssigned file is not a text file without extension. Please try again...\n',FCTNAME);
    set(fm.syn.fidPath,'String',syn.fidPath)
    return
end
if ~strcmp(synFidPathTmp(end-3:end),'.par') && ...
   ~strcmp(synFidPathTmp(end-3:end),'.mat') && ...
   ~strcmp(synFidPathTmp(end-3:end),'.raw') && ...
   ~strcmp(synFidPathTmp(end-3:end),'.RAW')
    fprintf('\n%s ->\nInvalid file format detected. Metabolite file assignment failed.\n',FCTNAME);
    set(fm.syn.fidPath,'String',syn.fidPath)
    return
end
if ~SP2_CheckFileExistenceR(synFidPathTmp)
    fprintf('\n*** WARNING ***\n%s ->\nAssigned file can''t be opened...\n',FCTNAME);
    set(fm.syn.fidPath,'String',syn.fidPath)
end
set(fm.syn.fidPath,'String',synFidPathTmp)
syn.fidPath = get(fm.syn.fidPath,'String');
clear synFidPathTmp

%--- update file parameters ---
if flag.OS==1            % Linux
    slashInd = find(syn.fidPath=='/');
elseif flag.OS==2        % Mac
    slashInd = find(syn.fidPath=='/');
else                     % PC
    slashInd = find(syn.fidPath=='\');
end
syn.fidDir     = syn.fidPath(1:slashInd(end));
syn.fidName    = syn.fidPath(slashInd(end)+1:end);

%--- update flag display ---
SP2_Syn_SynthesisWinUpdate


