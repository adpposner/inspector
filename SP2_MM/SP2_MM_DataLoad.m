%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DataLoad
%%
%%  Load parameters and data of saturation-recovery experiment from 'Data'
%%  page.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data mm


FCTNAME = 'SP2_MM_DataLoad';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if isfield(data,'spec1')
    if isfield(data.spec1,'fid')
        %--- format handling ---
        mm.fidOrig = data.spec1.fid;
        
        %--- consistency check ---
        if ndims(mm.fidOrig)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(mm.fidOrig),0));
        end
    else
        fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME);
        return
    end
else
    fprintf('%s ->\nNo data structure for FID 1 found (''data.spec2''). Program aborted.\n',FCTNAME);
    return
end

%--- assignment of further parameters ---
if isfield(data.spec1,'nspecC')
    mm.nspecCOrig = data.spec1.nspecC;      % number of complex data points (to be modified: cut, ZF)
    mm.nspecC     = data.spec1.nspecC;      % tmp init
else
    fprintf('%s ->\nData set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'na')
    mm.na = data.spec1.na;
else
    fprintf('%s ->\n# of averages (na) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'nr')
    mm.nr = data.spec1.nr;
else
    fprintf('%s ->\n# of repetitions (nr) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sf')
    mm.sf = data.spec1.sf;
else
    fprintf('%s ->\nSynthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'nRcvrs')
    mm.nRcvrs = data.spec1.nRcvrs;
else
    fprintf('%s ->\nNumber of receivers (nRcvrs) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sw')
    mm.sw_h  = data.spec1.sw_h;         % sweep width in Hz
    mm.dwell = 1/mm.sw_h;               % dwell time
    mm.sw    = mm.sw_h/mm.sf;           % sweep width in ppm
else
    fprintf('%s ->\nSweep width (sw) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'inv')
    if isfield(data.spec1.inv,'ti')
        if iscell(data.spec1.inv.ti)
            mm.satRecDelays = cell2mat(data.spec1.inv.ti);
            mm.satRecN      = length(mm.satRecDelays);
        else
            fprintf('%s ->\nInversion/saturation field is not a cell. Program aborted.\n\n',FCTNAME);
            return
        end
    else
        fprintf('%s ->\nNo inversion/saturation time (ti) not found. Program aborted.\n\n',FCTNAME);
        return
    end
else
    fprintf('%s ->\nNo inversion(/saturation) parameter not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'ni')
    mm.phCycleN = data.spec1.nv;        % number of phase cycling steps
else
    fprintf('%s ->\nSweep width (sw) not found. Program aborted.\n\n',FCTNAME);
    return
end

%--- consistency check ---
if mm.phCycleN*mm.satRecN~=mm.nr
    fprintf('%s ->\nNumber of phase enc. and saturation-recovery experiments\n',FCTNAME);
    fprintf('does not match the total number of scans NR (%.0f*%.0f~=%.0f). Program aborted.\n\n',mm.phCycleN,mm.satRecN,mm.nr);
    return
end   

%--- info string ---
fprintf('\nSpectral data set 1 loaded from data sheet:\n');
fprintf('larmor frequency: %.1f MHz\n',mm.sf);
fprintf('sweep width:      %.1f Hz\n',mm.sw_h);
fprintf('Complex points:   %.0f\n',mm.nspecC);
fprintf('Phase cycle:      %.0f steps\n',mm.phCycleN);
fprintf('Sat. Rec. (%.0f):   %ss\n\n',mm.satRecN,SP2_Vec2PrintStr(mm.satRecDelays,3));

%--- FID combination ---
% mm.fid = squeeze(sum(sum(reshape(mm.fidOrig,[mm.nspecC,mm.nRcvrs,mm.phCycleN,mm.satRecN]),2),3));
%--- consistency checks ---
if mm.satRecN~=data.spec1.nSatRec
    fprintf('%s ->\nNumber of saturation-recovery experiments does match original data size.\n',FCTNAME);
    return
end
mm.fid = data.spec1.fid;

%--- info printout ---
fprintf('Data loaded from ''Data'' page.\n');

%--- parameter update (for box car width) ---                           
SP2_MM_ParsUpdate

% %--- data export ---
% mm.expt     = mm;
% if isfield(mm.expt,'spec')
%     mm.expt = rmfield(mm.expt,'spec');
% end
% mm.expt.fid = mm.fidOrig;

%--- update read flag ---
f_succ = 1;
