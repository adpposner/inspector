%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualitySuperposClose
%% 
%%  Close spectral superposition figure (properly).
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_Data_QualitySuperposClose';


%--- figure handling ---
% remove existing figure if new figure is forced
if isfield(data,'fhQualitySuperpos')
    if ishandle(data.fhQualitySuperpos)
        delete(data.fhQualitySuperpos)
    end
    data = rmfield(data,'fhQualitySuperpos');
end

%--- force renewal of Rx summation and serial ordering ---
if isfield(data.spec1,'fidArrSerial')
    data.spec1 = rmfield(data.spec1,'fidArrSerial');
end