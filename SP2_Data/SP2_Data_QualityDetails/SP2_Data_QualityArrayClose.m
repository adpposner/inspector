%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityArrayClose
%% 
%%  Close spectral array figure (properly).
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_Data_QualityArrayClose';


%--- figure handling ---
% remove existing figure if new figure is forced
if isfield(data,'fhQualityArray')
    if ishandle(data.fhQualityArray)
        delete(data.fhQualityArray)
    end
    data = rmfield(data,'fhQualityArray');
end

%--- force renewal of Rx summation and serial ordering ---
if isfield(data.spec1,'fidArrSerial')
    data.spec1 = rmfield(data.spec1,'fidArrSerial');
end

end
