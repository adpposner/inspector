%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ExitBaseMain
%% 
%%  Exit baseline tool.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm

FCTNAME = 'SP2_MRSI_ExitBaseMain';


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

%--- remove baseline tool ---
if strcmp(fmFields{1},'mrsi')                % analysis window
    if isfield(fm.mrsi,'base')                % visual analysis open
        if ishandle(fm.mrsi.base.fig)
            delete(fm.mrsi.base.fig)          % delete figure
        end
        fm.mrsi = rmfield(fm.mrsi,'base');     % remove handles
    end
end



end
