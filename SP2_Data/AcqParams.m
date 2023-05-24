classdef AcqParams < handle & matlab.mixin.SetGet
properties

    PULPROG = '';
    ACQ_experiment_mode = '';
    ACQ_ReceiverSelect = {};
    ACQ_user_filter = '';
    ACQ_DS_enabled = '';
    ACQ_dim = 0;
    ACQ_dim_desc = '';
    ACQ_size = 0;
    ACQ_ns_list_size = 0;
    ACQ_ns = 0;
    ACQ_phase_factor = 0;
    ACQ_scan_size = '';
    NI = 0;
    NA = 0;
    NAE = 0;
    NR = 0;
    DS = 0;
    D = 0;
    P = 0;
    PL = 0;
    TPQQ = {};
    DPQQ = {};
    SW_h = 0;
    SW = 0;
    FW = 0;
    RG = 0;
    AQ_mod = '';
    DR = 0;
    PAPS = '';
    PH_ref = 0;
    ACQ_BF_enable = '';
    BF1 = 0;
    SFO1 = 0;
    O1 = 0;
    ACQ_O1_list_size = 0;
    ACQ_O1_list = 0;
    ACQ_O1B_list_size = 0;
    ACQ_O1B_list = 0;
    BF2 = 0;
    SFO2 = 0;
    O2 = 0;
    ACQ_O2_list_size = 0;
    ACQ_O2_list = 0;
    BF3 = 0;
    SFO3 = 0;
    O3 = 0;
    ACQ_O3_list_size = 0;
    ACQ_O3_list = 0;
    BF4 = 0;
    SFO4 = 0;
    O4 = 0;
    BF5 = 0;
    SFO5 = 0;
    O5 = 0;
    BF6 = 0;
    SFO6 = 0;
    O6 = 0;
    BF7 = 0;
    SFO7 = 0;
    O7 = 0;
    BF8 = 0;
    SFO8 = 0;
    O8 = 0;
    NUC1 = '';
    NUC2 = '';
    NUC3 = '';
    NUC4 = '';
    NUC5 = '';
    NUC6 = '';
    NUC7 = '';
    NUC8 = '';
    NUCLEUS = '';
    ACQ_Routing = '';
    ACQ_vd_list_size = 0;
    ACQ_vp_list_size = 0;
    ACQ_status = '';
    ACQ_Routing_base = '';
    ACQ_protocol_location = '';
    ACQ_protocol_name = '';
    ACQ_scan_name = '';
    ACQ_method = '';
    ACQ_completed = '';
    ACQ_scans_completed = 0;
    ACQ_nr_completed = 0;
    ACQ_total_completed = 0;
    ACQ_word_size = '';
    ACQ_n_echo_images = 0;
    ACQ_n_movie_frames = 0;
    ACQ_echo_descr = '';
    ACQ_movie_descr = '';
    ACQ_fov = 0;
    ACQ_read_ext = 0;
    ACQ_slice_angle = 0;
    ACQ_slice_orient = '';
    ACQ_patient_pos = '';
    ACQ_slice_sepn_mode = '';
    ACQ_slice_thick = 0;
    ACQ_slice_offset = 0;
    ACQ_obj_order = 0;
    ACQ_flip_angle = 0;
    ACQ_flipback = '';
    ACQ_echo_time = 0;
    ACQ_inter_echo_time = 0;
    ACQ_recov_time = 0;
    ACQ_repetition_time = 0;
    ACQ_scan_time = 0;
    ACQ_inversion_time = 0;
    ACQ_time = '';
    ACQ_abs_time = 0;
    ACQ_operator = '';
    ACQ_comment = '';
    ACQ_RF_power = 0;
    ACQ_transmitter_coil = '';
    ACQ_trigger_enable = '';
    ACQ_trigger_delay = 0;
    ACQ_institution = '';
    ACQ_station = '';
    ACQ_sw_version = '';
    ACQ_calib_date = '';
    Coil_operation = '';
    BYTORDA = '';
    INSTRUM = '';
    FQ1LIST = '';
    FQ2LIST = '';
    FQ3LIST = '';
    FQ8LIST = '';
    SP = 0;
    SPOFFS = 0;
    SPNAM0 = '';
    SPNAM1 = '';
    SPNAM2 = '';
    SPNAM3 = '';
    SPNAM4 = '';
    SPNAM5 = '';
    SPNAM6 = '';
    SPNAM7 = '';
    SPNAM8 = '';
    SPNAM9 = '';
    SPNAM10 = '';
    SPNAM11 = '';
    SPNAM12 = '';
    SPNAM13 = '';
    SPNAM14 = '';
    SPNAM15 = '';
    HPPRGN = '';
    LOCNUC = '';
    SOLVENT = '';
    DIGMOD = '';
    DIGTYP = '';
    DQDMODE = '';
    DSPFIRM = '';
    DECIM = 0;
    DSPFVS = 0;
    ACQ_scan_shift = 0;
    DEOSC = 0;
    DE = 0;
    FCUCHAN = 0;
    RSEL = 0;
    SWIBOX = 0;
    HPMOD = 0;
    PRECHAN = 0;
    OBSCHAN = 0;
    ACQ_2nd_preamp = '';
    ACQ_n_trim = 0;
    ACQ_trim = 0;
    ACQ_scaling_read = 0;
    ACQ_scaling_phase = 0;
    ACQ_scaling_slice = 0;
    ACQ_grad_matrix = 0;
    NSLICES = 0;
    ACQ_rare_factor = 0;

end

    methods 
        function obj = AcqParams()

        end
        function tokens = loadFromFileData(obj,fileName)
            text = fileread(fileName);
            texttokens = regexp(text,'##\$','split');
            params=cellfun(@(str)regexp(str,'([^=]+)\=(.+)','tokens'),texttokens);
            for i=1:numel(params)
                k=params{i}{1};v=params{i}{2};
                if isprop(obj,k)
                    value = parseParam(v);
                    set(obj,k,v);
                end
                
            end
        end
    end
    
end


function s=parseParam(data)
    if isnumeric(data)
        s=str2num(data)
    else
        data
    a = regexp(data,'\((.+)\)','tokens')
    numel(a)
    if numel(a)>1
        s=strsplit(a{1}{1},',');
    end
    end
end

