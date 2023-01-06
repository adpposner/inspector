%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ExitBaseMain(varargin)
%% 
%%  Exit baseline tool.
%%  (varargin) not used.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm

FCTNAME = 'SP2_Proc_ExitBaseMain';


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
if strcmp(fmFields{1},'proc')                % analysis window
    if isfield(fm.proc,'base')                % visual analysis open
        if ishandle(fm.proc.base.fig)
            delete(fm.proc.base.fig)          % delete figure
        end
        fm.proc = rmfield(fm.proc,'base');     % remove handles
    end
end



end
