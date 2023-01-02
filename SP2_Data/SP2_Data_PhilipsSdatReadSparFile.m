%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [procpar, f_succ] = SP2_Data_PhilipsSdatReadSparFile(file)
%%
%%  Function to read file headers of Philips .dat files.
%%
%%  05-2017, Ch. Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_PhilipsSdatReadSparFile';


%--- init success flag ---
f_succ = 0;

%--- consistency check ---
if ~SP2_CheckFileExistenceR(file)
    return
end

%--- procpar structure init ---
procpar  = {};
procpar.examination_name        = '';
procpar.scan_id                 = '';
procpar.scan_date               = '';
procpar.patient_name            = '';
procpar.patient_birth_date      = '';
procpar.patient_position        = '';
procpar.patient_orientation     = '';
procpar.samples                 = 0;
procpar.rows                    = 0;
procpar.synthesizer_frequency   = 0;
procpar.offset_frequency        = 0;
procpar.sample_frequency        = 0;
procpar.echo_nr                 = 0;
procpar.mix_number              = 0;
procpar.nucleus                 = '';
procpar.t0_mu1_direction        = 0;
procpar.echo_time               = 0;
procpar.repetition_time         = 0;
procpar.averages                = 0;    
procpar.volume_selection_enable = '';
procpar.volumes                 = 0;
procpar.ap_size                 = 0;
procpar.lr_size                 = 0;
procpar.cc_size                 = 0;
procpar.ap_off_center           = 0;
procpar.lr_off_center           = 0;
procpar.cc_off_center           = 0;
procpar.ap_angulation           = 0;
procpar.lr_angulation           = 0;
procpar.cc_angulation           = 0;
procpar.volume_selection_method = 0;
procpar.phase_encoding_enable   = '';
procpar.t1_measurement_enable   = '';
procpar.t2_measurement_enable   = '';
procpar.time_series_enable      = '';
procpar.image_plane_slice_thickness = 0;
procpar.slice_distance          = 0;
procpar.nr_of_slices_for_multislice = 0;
procpar.spec_data_type          = '';
procpar.spec_sample_extension   = '';
procpar.spec_num_col            = 0;
procpar.spec_col_lower_val      = 0;
procpar.spec_col_upper_val      = 0;
procpar.spec_col_extension      = '';
procpar.spec_num_row            = 0;
procpar.spec_row_lower_val      = 0;
procpar.spec_row_upper_val      = 0;
procpar.spec_row_extension      = '';
procpar.dim1_ext                = '';
procpar.dim1_pnts               = 0;
procpar.dim1_low_val            = 0;
procpar.dim1_step               = 0;
procpar.dim1_direction          = '';
procpar.dim1_t0_point           = 0;
procpar.dim2_ext                = '';
procpar.dim2_pnts               = 0;
procpar.dim2_low_val            = 0;
procpar.dim2_step               = 0;
procpar.dim2_direction          = '';
procpar.dim2_t0_point           = 0;
procpar.dim3_ext                = '';
procpar.dim3_pnts               = 0;
procpar.dim3_low_val            = 0;
procpar.dim3_step               = 0;
procpar.dim3_direction          = '';
procpar.dim3_t0_point           = 0;
procpar.echo_acquisition        = '';
procpar.TSI_factor              = 0;
procpar.spectrum_echo_time      = 0;
procpar.spectrum_inversion_time = 0;
procpar.image_chemical_shift    = 0;
procpar.resp_motion_comp_technique = '';
procpar.de_coupling             = '';
procpar.equipment_sw_verions    = '';
procpar.placeholder1            = 0;
procpar.placeholder2            = 0;


%--- generation of method struct field tags ---
procparNames = fieldnames(procpar);
procparNtags = length(procparNames);

%--- procpar file reading and extraction of the above parameter values ---
% note: both, the 1st and 2nd line per parameter are extracted here
[fid,msg] = fopen(file,'r');
if fid>0
    %--- info printout ---
    fprintf('%s ->\nReading <%s>\n',FCTNAME,file);
    
    %--- parameter extraction ---
    while ~feof(fid)
        tline = fgetl(fid);
                
        %--- extraction of parameter name ---
        if any(find(tline==':'))
            %--- parameter name extraction ---
            parName = SP2_SubstStrPart(strtok(tline,':'),' ','');
            
            %--- check for parameter existence ---
            if isfield(procpar,parName)
                [fake,valStr] = strtok(tline,':');
                [valStr,fake] = strtok(valStr,':');
                valStr = SP2_SubstStrPart(valStr,' ','');
                valStr = SP2_SubstStrPart(valStr,'"','');
                if isnumeric(eval(['procpar.' parName])) && ~isempty(valStr)    % numeric
                    eval(['procpar.' parName ' = str2double(valStr);'])
                elseif ischar(eval(['procpar.' parName])) && ~isempty(valStr)   % string
                    eval(['procpar.' parName ' = valStr;'])
                end    
            end
        end
    end
    fclose(fid);
else
    fprintf('%s ->\nOpening <%s> not successful.\n%s\n\n',FCTNAME,file,msg);
    return
end

%--- consistency check ---
if isempty(procpar)
    fprintf('%s ->\nParameter reading failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- update success flag ---
f_succ = 1;

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%    L O C A L     F U N C T I O N                                    %%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function strClean = StrStripQuotes(strRaw)
% 
% quotesInd = find(strRaw=='"');
% if ~isempty(quotesInd)
%     if braInd(1)<length(strRaw)
%         strRaw = strRaw(braInd(1)+1:end);
%     end
% end
% 
% ketInd = find(strRaw=='>');
% if ~isempty(ketInd)
%     if ketInd(end)<=length(strRaw)
%         strRaw = strRaw(1:ketInd(end)-1);
%     end
% end
% 
% strClean = strRaw;






