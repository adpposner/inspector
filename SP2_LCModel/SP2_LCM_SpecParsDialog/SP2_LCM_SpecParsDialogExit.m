%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecParsDialogExit
%% 
%%  Exit parameter assignment window.
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm

FCTNAME = 'SP2_LCM_SpecParsDialogExit';


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
if strcmp(fmFields{1},'lcm')                % analysis window
    if isfield(fm.lcm,'dialog1')                % visual analysis open
        if ishandle(fm.lcm.dialog1.fig)
            delete(fm.lcm.dialog1.fig)          % delete figure
        end
        fm.lcm = rmfield(fm.lcm,'dialog1');     % remove handles
    end
end


