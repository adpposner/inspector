%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_T1T2_DataLoad
%%
%%  Load parameters and data of T1/T2 experiment from 'Data' page.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data t1t2


FCTNAME = 'SP2_T1T2_DataLoad';


%--- init read flag ---
f_succ = 0;

%--- init/reset experiment type (T1 vs. T2) ---
t1t2.expType = 0;

%--- data assignment ---
if isfield(data,'spec1')
    %--- check data existence ---
    if ~isfield(data.spec1,'teUsed')
        fprintf('%s ->\nNo data structure found. Load and reconstructe first.\nProgram aborted.\n',FCTNAME)
        return
    end
    
    %--- data assignment ---
    if isfield(data.spec1,'fid')
        %--- format handling ---
        t1t2.fidOrig = data.spec1.fid;
        
        %--- consistency check ---
        if ndims(t1t2.fidOrig)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(t1t2.fidOrig),0))
        end
    else
        fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME)
        return
    end
else
    fprintf('%s ->\nNo data structure for FID 1 found (''data.spec2''). Program aborted.\n',FCTNAME)
    return
end

%--- assignment of further parameters ---
if isfield(data.spec1,'nspecC')
    t1t2.nspecCOrig = data.spec1.nspecC;      % number of complex data points (to be modified: cut, ZF)
    t1t2.nspecC     = data.spec1.nspecC;      % tmp init
else
    fprintf('%s ->\nData set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec1,'na')
    t1t2.na = data.spec1.na;
else
    fprintf('%s ->\n# of averages (na) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec1,'nr')
%     t1t2.nr = data.spec1.nr;
    t1t2.nr = length(data.spec1.teUsed);
else
    fprintf('%s ->\n# of repetitions (nr) not found. Program aborted.\n\n',FCTNAME)
    return
end

if isfield(data.spec1,'sf')
    t1t2.sf = data.spec1.sf;
else
    fprintf('%s ->\nSynthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME)
    return
end

if isfield(data.spec1,'nRcvrs')
    t1t2.nRcvrs = data.spec1.nRcvrs;
else
    fprintf('%s ->\nNumber of receivers (nRcvrs) not found. Program aborted.\n\n',FCTNAME)
    return
end

if isfield(data.spec1,'sw')
    t1t2.sw_h  = data.spec1.sw_h;         % sweep width in Hz
    t1t2.dwell = 1/t1t2.sw_h;               % dwell time
    t1t2.sw    = t1t2.sw_h/t1t2.sf;           % sweep width in ppm
else
    fprintf('%s ->\nSweep width (sw) not found. Program aborted.\n\n',FCTNAME)
    return
end

%--- inversion time -> T1 ---
if isfield(data.spec1,'inv')
    if isfield(data.spec1.inv,'ti')
        if iscell(data.spec1.inv.ti)
            t1t2.delays  = cell2mat(data.spec1.inv.ti);
            t1t2.delaysN = length(t1t2.delays);
            t1t2.expType = 1;       % T1 experiment
        else
            fprintf('%s ->\nInversion field is not a cell. Program aborted.\n\n',FCTNAME)
        end
    else
        fprintf('%s ->\nNo inversion time (ti) not found. Program aborted.\n\n',FCTNAME)
    end
else
    fprintf('%s ->\nNo inversion parameter found. Program aborted.\n\n',FCTNAME)
end

if isfield(data.spec1,'ni')
    t1t2.phCycleN = data.spec1.nv;        % number of phase cycling steps
else
    fprintf('%s ->\nSweep width (sw) not found. Program aborted.\n\n',FCTNAME)
    return
end

%--- TE -> T2 ---
if isfield(data.spec1,'teUsed')
    if length(data.spec1.teUsed)>1
        %--- consistency check ---
        if t1t2.expType==1
            fprintf('Unknown data type: Both TI and TE are arrayed.\nProgram aborted.\n')
            return
        end
        t1t2.delays  = data.spec1.teUsed;
        t1t2.delaysN = length(t1t2.delays);
        t1t2.expType = 2;       % T2 experiment
    else
        fprintf('%s ->\nOnly one TE found. Experiment is neither T1 nor T2.\nProgram aborted.\n\n',FCTNAME)
    end
else
    fprintf('%s ->\nNo echo time parameter found. Experiment is neither T1 nor T2.\nProgram aborted.\n\n',FCTNAME)
end

%--- consistency check ---
if t1t2.delaysN~=t1t2.nr
    fprintf('%s ->\nNumber of arrayed experiments\n',FCTNAME)
    fprintf('does not match the total number of scans NR (%.0f~=%.0f). Program aborted.\n\n',t1t2.delaysN,t1t2.nr)
    return
end   

%--- info string ---
if t1t2.expType==1
    fprintf('\nT1 series loaded from data sheet:\n')
else
    fprintf('\nT2 series loaded from data sheet:\n')
end
fprintf('larmor frequency: %.1f MHz\n',t1t2.sf)
fprintf('sweep width:      %.1f Hz\n',t1t2.sw_h)
fprintf('Complex points:   %.0f\n',t1t2.nspecC)
fprintf('Delays (%.0f): %ss\n\n',t1t2.delaysN,SP2_Vec2PrintStr(t1t2.delays,3))

%--- FID assignment ---
t1t2.fid = data.spec1.fid;

%--- update read flag ---
f_succ = 1;
