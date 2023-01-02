%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisExitMain(varargin)
%% 
%%  Exit basis tool.
%%  (varargin) not used.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm

FCTNAME = 'SP2_LCM_ExitBasisMain';


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

%--- remove basisline tool ---
if strcmp(fmFields{1},'lcm')                % analysis window
    if isfield(fm.lcm,'basis')                % visual analysis open
        if ishandle(fm.lcm.basis.fig)
            delete(fm.lcm.basis.fig)          % delete figure
        end
        fm.lcm = rmfield(fm.lcm,'basis');     % remove handles
    end
end


