%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [acqp, f_succ] = SP2_Data_PvReadAcqp(varargin)
%%
%%  Function to read ParaVision 'acqp' parameter files. Parameters are
%%  returned in a struct called 'acqp'.
%%
%%  01-2003 / 02-2008, Ch. Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile pars

FCTNAME = 'SP2_Data_PvReadAcqp';

%--- init success flag ---
f_succ = 0;

%--- file path assignment ---
% as:
% 1) the full path of the parameter file (1 function argument)
% 2) assign 'study' and 'expNo' to use the pars.stdpath handling for path composition (2 args)
narg = nargin;
if narg==1
    file = SP2_Check4StrR( varargin{1} );
elseif narg==2
    study = SP2_Check4StrR( varargin{1} );
    expNo = SP2_Check4NumR( varargin{2} );
    file  = [pars.stdpath study '\' num2str(expNo) '\acqp'];
else
    fprintf('%s -> more than 2 input arguments are not allowed!...',FCTNAME);
    return    
end

%--- acqp structure init ---
acqp.PULPROG = '';
acqp.ACQ_experiment_mode = '';
acqp.ACQ_ReceiverSelect = {};
acqp.ACQ_user_filter = '';
acqp.ACQ_DS_enabled = '';
acqp.ACQ_dim = 0;
acqp.ACQ_dim_desc = '';
acqp.ACQ_size = 0;
acqp.ACQ_ns_list_size = 0;
acqp.ACQ_ns = 0;
acqp.ACQ_phase_factor = 0;
acqp.ACQ_scan_size = '';
acqp.NI = 0;
acqp.NA = 0;
acqp.NAE = 0;
acqp.NR = 0;
acqp.DS = 0;
acqp.D = 0;
acqp.P = 0;
acqp.PL = 0;
acqp.TPQQ = {};
acqp.DPQQ = {};
acqp.SW_h = 0;
acqp.SW = 0;
acqp.FW = 0;
acqp.RG = 0;
acqp.AQ_mod = '';
acqp.DR = 0;
acqp.PAPS = '';
acqp.PH_ref = 0;
acqp.ACQ_BF_enable = '';
acqp.BF1 = 0;
acqp.SFO1 = 0;
acqp.O1 = 0;
acqp.ACQ_O1_list_size = 0;
acqp.ACQ_O1_list = 0;
acqp.ACQ_O1B_list_size = 0;
acqp.ACQ_O1B_list = 0;
acqp.BF2 = 0;
acqp.SFO2 = 0;
acqp.O2 = 0;
acqp.ACQ_O2_list_size = 0;
acqp.ACQ_O2_list = 0;
acqp.BF3 = 0;
acqp.SFO3 = 0;
acqp.O3 = 0;
acqp.ACQ_O3_list_size = 0;
acqp.ACQ_O3_list = 0;
acqp.BF4 = 0;
acqp.SFO4 = 0;
acqp.O4 = 0;
acqp.BF5 = 0;
acqp.SFO5 = 0;
acqp.O5 = 0;
acqp.BF6 = 0;
acqp.SFO6 = 0;
acqp.O6 = 0;
acqp.BF7 = 0;
acqp.SFO7 = 0;
acqp.O7 = 0;
acqp.BF8 = 0;
acqp.SFO8 = 0;
acqp.O8 = 0;
acqp.NUC1 = '';
acqp.NUC2 = '';
acqp.NUC3 = '';
acqp.NUC4 = '';
acqp.NUC5 = '';
acqp.NUC6 = '';
acqp.NUC7 = '';
acqp.NUC8 = '';
acqp.NUCLEUS = '';
acqp.ACQ_Routing = '';
acqp.ACQ_vd_list_size = 0;
acqp.ACQ_vp_list_size = 0;
acqp.ACQ_status = '';
acqp.ACQ_Routing_base = '';
acqp.ACQ_protocol_location = '';
acqp.ACQ_protocol_name = '';
acqp.ACQ_scan_name = '';
acqp.ACQ_method = '';
acqp.ACQ_completed = '';
acqp.ACQ_scans_completed = 0;
acqp.ACQ_nr_completed = 0;
acqp.ACQ_total_completed = 0;
acqp.ACQ_word_size = '';
acqp.ACQ_n_echo_images = 0;
acqp.ACQ_n_movie_frames = 0;
acqp.ACQ_echo_descr = '';
acqp.ACQ_movie_descr = '';
acqp.ACQ_fov = 0;
acqp.ACQ_read_ext = 0;
acqp.ACQ_slice_angle = 0;
acqp.ACQ_slice_orient = '';
acqp.ACQ_patient_pos = '';
acqp.ACQ_slice_sepn_mode = '';
acqp.ACQ_slice_thick = 0;
acqp.ACQ_slice_offset = 0;
acqp.ACQ_obj_order = 0;
acqp.ACQ_flip_angle = 0;
acqp.ACQ_flipback = '';
acqp.ACQ_echo_time = 0;
acqp.ACQ_inter_echo_time = 0;
acqp.ACQ_recov_time = 0;
acqp.ACQ_repetition_time = 0;
acqp.ACQ_scan_time = 0;
acqp.ACQ_inversion_time = 0;
acqp.ACQ_time = '';
acqp.ACQ_abs_time = 0;
acqp.ACQ_operator = '';
acqp.ACQ_comment = '';
acqp.ACQ_RF_power = 0;
acqp.ACQ_transmitter_coil = '';
acqp.ACQ_trigger_enable = '';
acqp.ACQ_trigger_delay = 0;
acqp.ACQ_institution = '';
acqp.ACQ_station = '';
acqp.ACQ_sw_version = '';
acqp.ACQ_calib_date = '';
acqp.Coil_operation = '';
acqp.BYTORDA = '';
acqp.INSTRUM = '';
acqp.FQ1LIST = '';
acqp.FQ2LIST = '';
acqp.FQ3LIST = '';
acqp.FQ8LIST = '';
acqp.SP = 0;
acqp.SPOFFS = 0;
acqp.SPNAM0 = '';
acqp.SPNAM1 = '';
acqp.SPNAM2 = '';
acqp.SPNAM3 = '';
acqp.SPNAM4 = '';
acqp.SPNAM5 = '';
acqp.SPNAM6 = '';
acqp.SPNAM7 = '';
acqp.SPNAM8 = '';
acqp.SPNAM9 = '';
acqp.SPNAM10 = '';
acqp.SPNAM11 = '';
acqp.SPNAM12 = '';
acqp.SPNAM13 = '';
acqp.SPNAM14 = '';
acqp.SPNAM15 = '';
acqp.HPPRGN = '';
acqp.LOCNUC = '';
acqp.SOLVENT = '';
acqp.DIGMOD = '';
acqp.DIGTYP = '';
acqp.DQDMODE = '';
acqp.DSPFIRM = '';
acqp.DECIM = 0;
acqp.DSPFVS = 0;
acqp.AQ_mod;
acqp.ACQ_scan_shift = 0;
acqp.DEOSC = 0;
acqp.DE = 0;
acqp.FCUCHAN = 0;
acqp.RSEL = 0;
acqp.SWIBOX = 0;
acqp.HPMOD = 0;
acqp.PRECHAN = 0;
acqp.OBSCHAN = 0;
acqp.ACQ_2nd_preamp = '';
acqp.ACQ_n_trim = 0;
acqp.ACQ_trim = 0;
acqp.ACQ_scaling_read = 0;
acqp.ACQ_scaling_phase = 0;
acqp.ACQ_scaling_slice = 0;
acqp.ACQ_grad_matrix = 0;
acqp.NSLICES = 0;
acqp.ACQ_rare_factor = 0;


%--- generation of acqp struct field tags ---
acqpNames = fieldnames(acqp);
acqpNtags = length(acqpNames);

%--- acqp file reading and parameter extraction ---
fid        = fopen(file,'r');
parKeyStr  = '##$';
parKeyStrN = length(parKeyStr);
if fid>0
    %--- info printout ---
    fprintf('%s -> reading <%s>\n',FCTNAME,file);
   
    %--- go through file ---
    while (~feof(fid))
        %--- next line ---
        tline = fgetl(fid);
        
        %--- check for parameter ---
        if ~isempty(strfind(tline,parKeyStr))
            %--- extract field name ---
            equInd = find(tline=='=');
            fName = tline(parKeyStrN+1:equInd-1);
            
            %--- check parameter validity ---  
            if isfield(acqp,fName)
                %--- two-line parameter assignment ---
                if ~isempty(tline=='=') && ~isempty(strfind(tline,'(')) && ~isempty(strfind(tline,')'))         % next line
                    % get number of elements
                    [fake,parDimStr] = strtok(tline,'(');
                    parDimStr = SP2_ConvertList2Product(parDimStr);     % e.g. ( 1, 3 ) -> ( 3 ), ( 60, 3 ) -> ( 180 )
                    [parDimStr,fake] = strtok(parDimStr,'(');
                    [parDimStr,fake] = strtok(parDimStr,')');
                    parDim = str2num(parDimStr);

                    % get parameter value
                    tline = fgetl(fid);
                    if isnumeric(eval(['acqp.' fName]))                 % numeric
                        eval(['acqp.' fName ' = str2num(tline);'])
                    elseif ischar(eval(['acqp.' fName]))                % string
                        eval(['acqp.' fName ' = StrStripBracket(tline);'])
                    else                                                % cell
                        cellTmp = textscan(tline,'%s');
                        eval(['acqp.' fName ' = cellTmp{1};'])
                    end
                    
                %--- single-line parameter assignment ---    
                elseif ~isempty(tline=='=') && isempty(strfind(tline,'(')) && isempty(strfind(tline,')'))         % same line
                    if isnumeric(eval(['acqp.' fName]))                 % numeric
                        eval(['acqp.' fName ' = str2num(tline(equInd(end)+1:end));'])
                    elseif ischar(eval(['acqp.' fName]))                % string
                        eval(['acqp.' fName ' = StrStripBracket(tline(equInd(end)+1:end));'])
                    else                                                % cell
                        cellTmp = textscan(tline(equInd(end)+1:end),'%s');
                        eval(['acqp.' fName ' = cellTmp{1};'])
                    end
                end        
            end
        end
    end
    fclose(fid);
    f_succ = 1;
    
    %--- reshaping of trim/gradient vector ---
    % acqp.ACQ_trim = reshape(acqp.ACQ_trim,3,acqp.ACQ_n_trim)';
else
   fprintf('%s -> Opening file failed:\n<%s>\n',FCTNAME,file);
   return
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    L O C A L     F U N C T I O N                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strClean = StrStripBracket(strRaw)

braInd = find(strRaw=='<');
if ~isempty(braInd)
    if braInd(1)<length(strRaw)
        strRaw = strRaw(braInd(1)+1:end);
    end
end

ketInd = find(strRaw=='>');
if ~isempty(ketInd)
    if ketInd(end)<=length(strRaw)
        strRaw = strRaw(1:ketInd(end)-1);
    end
end

strClean = strRaw;













