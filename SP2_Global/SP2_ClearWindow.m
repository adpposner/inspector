%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_ClearWindow
%% 
%%  Remove all window content (before switching to different sheet)
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm


FCTNAME = 'SP2_ClearWindow';


%--- init success flag ---
f_succ = 0;

%--- retrieve current window handles ---
% should be exactly 1, since there is only one window at the time
fmFields = fieldnames(fm);
if isempty(fmFields)        
    fprintf('%s -> No field name found for <fm>...',FCTNAME);
    return
elseif length(fmFields)~=1
    if ~SP2_PrintCell(fmFields)
        return
    end
    fprintf('%s -> %i field names detected for <fm>...(>1)',...
            FCTNAME,length(fmFields))
    return
end

%--- remove local window: spectra alignment ---
if strcmp(fmFields{1},'data')                       % data window
    if isfield(fm.data,'align')                     % basis set creation open
        if ishandle(fm.data.align.fig)
            delete(fm.data.align.fig)               % delete figure
        end
        fm.data = rmfield(fm.data,'align');         % remove handles
    end
end

%--- remove local window: quality assessment ---
if strcmp(fmFields{1},'data')                       % data window
    if isfield(fm.data,'qualityDet')                % basis set creation open
        if ishandle(fm.data.qualityDet.fig)
            delete(fm.data.qualityDet.fig)          % delete figure
        end
        fm.data = rmfield(fm.data,'qualityDet');    % remove handles
    end
end

%--- remove local window: spectra alignment ---
if strcmp(fmFields{1},'mm')                         % mm window
    if isfield(fm.mm,'align')                       % basis set creation open
        if ishandle(fm.mm.align.fig)
            delete(fm.mm.align.fig)                 % delete figure
        end
        fm.mm = rmfield(fm.mm,'align');             % remove handles
    end
end

%--- remove local window: JDE efficiency analysis ---
if strcmp(fmFields{1},'proc')                       % processing window
    if isfield(fm.proc,'jdeEff')                    % basis set creation open
        if ishandle(fm.proc.jdeEff.fig)
            delete(fm.proc.jdeEff.fig)              % delete figure
        end
        fm.proc = rmfield(fm.proc,'jdeEff');        % remove handles
    end
end

%--- remove local window: Baseline manipulation (proc) ---
if strcmp(fmFields{1},'proc')                       % processing window
    if isfield(fm.proc,'base')                      % basis set creation open
        if ishandle(fm.proc.base.fig)
            delete(fm.proc.base.fig)                % delete figure
        end
        fm.proc = rmfield(fm.proc,'base');          % remove handles
    end
end

%--- remove local window: Dialog for parameter assignment FID 1 ---
if strcmp(fmFields{1},'proc')                       % processing window
    if isfield(fm.proc,'dialog1')                   % basis set creation open
        if ishandle(fm.proc.dialog1.fig)
            delete(fm.proc.dialog1.fig)             % delete figure
        end
        fm.proc = rmfield(fm.proc,'dialog1');       % remove handles
    end
end

%--- remove local window: Dialog for parameter assignment FID 2 ---
if strcmp(fmFields{1},'proc')                       % processing window
    if isfield(fm.proc,'dialog2')                   % basis set creation open
        if ishandle(fm.proc.dialog2.fig)
            delete(fm.proc.dialog2.fig)             % delete figure
        end
        fm.proc = rmfield(fm.proc,'dialog2');       % remove handles
    end
end

%--- remove local window: Baseline manipulation (MRSI) ---
if strcmp(fmFields{1},'mrsi')                       % MRSI window
    if isfield(fm.mrsi,'base')                      % basis set creation open
        if ishandle(fm.mrsi.base.fig)
            delete(fm.mrsi.base.fig)                % delete figure
        end
        fm.mrsi = rmfield(fm.mrsi,'base');          % remove handles
    end
end

%--- remove local window: Basis handling (LCM) ---
if strcmp(fmFields{1},'lcm')                        % LCM window
    if isfield(fm.lcm,'basis')                      % basis set creation open
        if ishandle(fm.lcm.basis.fig)
            delete(fm.lcm.basis.fig)                % delete figure
        end
        fm.lcm = rmfield(fm.lcm,'basis');           % remove handles
    end
end

%--- remove local window: Basis handling (LCM) ---
if strcmp(fmFields{1},'lcm')                        % LCM window
    if isfield(fm.lcm,'base')                       % basis set creation open
        if ishandle(fm.lcm.base.fig)
            delete(fm.lcm.base.fig)                 % delete figure
        end
        fm.lcm = rmfield(fm.lcm,'base');            % remove handles
    end
end

%--- remove local window: Fit details (LCM) ---
if strcmp(fmFields{1},'lcm')                        % LCM window
    if isfield(fm.lcm,'fit')                        % basis set creation open
        if ishandle(fm.lcm.fit.fig)
            delete(fm.lcm.fit.fig)                  % delete figure
        end
        fm.lcm = rmfield(fm.lcm,'fit');             % remove handles
    end
end

%--- get handles ---
sheetHandles = fieldnames(eval(['fm.' fmFields{1}]));     % handle name
nHandles     = length(sheetHandles);                % number of handles

%--- delete all handles ---
for icnt = 1:nHandles
    delete(eval(['fm.' fmFields{1} '.' sheetHandles{icnt}]))
end

fm = rmfield(fm,fmFields{1});                       % remove sheet field from fm struct
clear fmFields sheetHandles nHandles

%--- update success flag ---
f_succ = 1;


