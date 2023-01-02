%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualitySeriesClose
%% 
%%  Close figure of spectral series (properly).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data

FCTNAME = 'SP2_Data_QualitySeriesClose';


%--- figure handling ---
% remove existing figure if new figure is forced
if isfield(data,'fhQualitySeries')
    if ishandle(data.fhQualitySeries)
        delete(data.fhQualitySeries)
    end
    data = rmfield(data,'fhQualitySeries');
end

%--- force renewal of Rx summation and serial ordering ---
if isfield(data.spec1,'fidArrSerial')
    data.spec1 = rmfield(data.spec1,'fidArrSerial');
end