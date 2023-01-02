%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_read = SP2_Stab_DataAssignment
%% 
%%  Assignment of data to be analyzed
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data stab


FCTNAME = 'SP2_Stab_DataAssignment';


%--- init read flag ---
f_read = 0;

%--- data assignment ---
if isfield(data.spec1,'fid')
    stab.fid     = data.spec1.fid;
    stab.fidOrig = stab.fid;
else
    fprintf('%s -> raw data (Spec 1) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'nspecC')
    stab.nspecC = data.spec1.nspecC;       % number of complex data points (to be modified: cut, ZF)
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'nr')
    stab.nr     = data.spec1.nr;
    stab.nrOrig = stab.nr;
else
    fprintf('%s -> # of repetitions (nr) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sf')
    stab.sf = data.spec1.sf;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sw')
    stab.sw_h  = data.spec1.sw_h;       % sweep width in Hz
    stab.sw    = data.spec1.sw;         % sweep width in ppm
    stab.dwell = 1/stab.sw_h;           % dwell time
else
    fprintf('%s -> sweep width (sw) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'tr')
    stab.tr  = data.spec1.tr/1000;      % repetition time in [sec]
else
    fprintf('%s -> repetition time (tr) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sequence')
    stab.sequence  = data.spec1.sequence;       % MR sequence name
else
    fprintf('%s -> No MR sequence name found. Program aborted.\n\n',FCTNAME);
    return
end

%--- time handling ---
if isfield(data.spec1,'time_start')
    stab.time_start  = data.spec1.time_start;       % MR sequence name
else
    fprintf('%s -> No start time of scan found. Program aborted.\n\n',FCTNAME);
    return
end
stab.tNR_s     = (0:stab.nr-1)*stab.tr;         % vector of relative NR acquisition times, [sec]
stab.tNR_min   = stab.tNR_s/60;                 % vector of relative NR acquisition times, [min]
stab.tNR_h     = stab.tNR_s/60;                 % vector of relative NR acquisition times, [h]
stab.dur_s     = stab.tr*stab.nr;               % total duration [sec]
stab.dur_min   = stab.dur_s/60;                 % total duration [min]

%--- update read flag ---
f_read = 1;
