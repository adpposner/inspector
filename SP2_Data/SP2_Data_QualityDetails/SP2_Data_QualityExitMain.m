%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityExitMain(varargin)
%% 
%%  Exit quality assessment tool.
%%  (varargin) not used
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

FCTNAME = 'SP2_Data_QualityExitMain';


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

%--- remove quality assessment tool ---
if strcmp(fmFields{1},'data')               % analysis window
    if isfield(fm.data,'qualityDet')                % visual analysis open
        if ishandle(fm.data.qualityDet.fig)
            delete(fm.data.qualityDet.fig)          % delete figure
        end
        fm.data = rmfield(fm.data,'qualityDet');     % remove handles
    end
end

%--- close superposition figure ---
SP2_Data_QualitySuperposClose

%--- close superposition figure ---
SP2_Data_QualitySeriesClose

%--- close array figure ---
SP2_Data_QualityArrayClose

%--- force renewal of Rx summation and serial ordering ---
if isfield(data.spec1,'fidArrSerial')
    data.spec1 = rmfield(data.spec1,'fidArrSerial');
end

end
