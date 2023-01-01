%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_FitClearWindow
%% 
%%  Remove all window content.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm

FCTNAME = 'SP2_LCM_FitClearWindow';


%--- init success flag ---
f_succ = 0;

%--- retrieve current window handles ---
if isfield(fm,'lcm')                                % LCM window
    if isfield(fm.lcm,'fit')                        % fit handling window
        %--- get handles ---
        sheetHandles = fieldnames(fm.lcm.fit);      % handle names
        nHandles     = length(sheetHandles);        % number of handles

        %--- delete all handles ---
        for icnt = 1:nHandles
            if ~strcmp('fig',sheetHandles{icnt})
                delete(eval(['fm.lcm.fit.' sheetHandles{icnt}]))
                fm.lcm.fit = rmfield(fm.lcm.fit,sheetHandles{icnt});
            end
        end
    end
end

%--- update success flag ---
f_succ = 1;



