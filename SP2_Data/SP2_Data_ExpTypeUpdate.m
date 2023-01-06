%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ExpTypeUpdate
%% 
%%  Update experiment type (in popup menue).
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

FCTNAME = 'SP2_Data_ExpTypeUpdate';


%--- retrieve parameter ---
data.expTypeDisplay = get(fm.data.expType,'Value');
SP2_Data_ExpTypeDisplay2Pars;

%--- update spectra alignment window ---
if isfield(fm.data,'align')
    if isfield(fm.data.align,'fig')
        fm.data.align.fig
    end
end
fmFields = fieldnames(fm);
if strcmp(fmFields{1},'data')                       % data window
    if isfield(fm.data,'align')                     % align window open
        if ishandle(fm.data.align.fig)
            delete(fm.data.align.fig)               % delete figure
        end
        fm.data = rmfield(fm.data,'align');         % remove handles
        SP2_Data_AlignDetailsMain
    end
end






end
