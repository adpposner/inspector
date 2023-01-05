%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitExitMain(varargin)
%% 
%%  Exit analysis details page.
%%  (varargin) not used
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm

FCTNAME = 'SP2_LCM_FitExitMain';


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

%--- remove analysis detail page ---
if strcmp(fmFields{1},'lcm')                % analysis window
    if isfield(fm.lcm,'fit')                % visual analysis open
        if ishandle(fm.lcm.fit.fig)
            delete(fm.lcm.fit.fig)          % delete figure
        end
        fm.lcm = rmfield(fm.lcm,'fit');     % remove handles
    end
end


