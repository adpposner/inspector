%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignDetailsExit
%% 
%%  Exit alignment details tool.
%%
%%  11-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm

FCTNAME = 'SP2_MM_AlignDetailsExit';


%--- retrieve current window handles ---
% should be exactly 1, since there is only one window at the time
fmFields = fieldnames(fm);
if isempty(fmFields)
    fprintf('%s -> no field name found for <fm>...\n\n',FCTNAME);
    return
elseif length(fmFields)~=1
    SP2_PrintCell(fmFields)
    fprintf('%s -> %i field names detected for <fm>...(>1)\n\n',...
            FCTNAME,length(fmFields))
    return
end

%--- remove alignment tool ---
if strcmp(fmFields{1},'mm')                 % MM window
    if isfield(fm.mm,'align')               % visual analysis open
        if ishandle(fm.mm.align.fig)
            delete(fm.mm.align.fig)         % delete figure
        end
        fm.mm = rmfield(fm.mm,'align');     % remove handles
    end
end


