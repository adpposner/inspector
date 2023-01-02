%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignDetailsExit(varargin)
%% 
%%  Exit alignment details tool.
%%
%%  11-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm

FCTNAME = 'SP2_Data_AlignDetailsExit';


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
if strcmp(fmFields{1},'data')                   % analysis window
    if isfield(fm.data,'align')                 % visual analysis open
        if ishandle(fm.data.align.fig)
            delete(fm.data.align.fig)           % delete figure
        end
        fm.data = rmfield(fm.data,'align');     % remove handles
    end
end


