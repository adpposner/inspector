%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_Proc_Spec1DataLoadFromData
%% 
%%  Assignment of specral data set 1
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data proc


FCTNAME = 'SP2_Proc_Spec1DataLoadFromData';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if data.expTypeDisplay==1 || data.expTypeDisplay==2 || ...      % regular MRS || JDE 1st&Last || ...
   data.expTypeDisplay==3 || data.expTypeDisplay==4             % JDE 2nd&Last || JDE array
    if isfield(data,'spec1')
        if isfield(data.spec1,'fid')
            %--- format handling ---
            proc.spec1.fidOrig = data.spec1.fid;

            %--- consistency check ---
            if ndims(proc.spec1.fidOrig)~=2
                fprintf('%s ->\nIncompatible FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec1.fidOrig),0));
                return
            elseif size(proc.spec1.fidOrig,2)~=1
                fprintf('%s ->\nIncompatible FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec1.fidOrig),0));
                return
            end
        else
            fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME);
            return
        end
    else
        fprintf('%s ->\nNo data structure for FID 1 found (''data.spec1''). Program aborted.\n',FCTNAME);
        return
    end
else
   fprintf('%s ->\nSelected data format is not supported.\nMake sure the data to be loaded is meaningful. \n',FCTNAME);
   return
end

%--- assignment of further parameters ---
if isfield(data.spec1,'nspecC')
    proc.spec1.nspecCOrig = data.spec1.nspecC;       % number of complex data points (to be modified: cut, ZF)
    proc.spec1.nspecC     = data.spec1.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'na')
    proc.spec1.na = data.spec1.na;
else
    fprintf('%s -> # of averages (na) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'nr')
    proc.spec1.nr = data.spec1.nr;
else
    fprintf('%s -> # of repetitions (nr) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sf')
    proc.spec1.sf = data.spec1.sf;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sw_h')
    proc.spec1.sw_h  = data.spec1.sw_h;                 % sweep width in Hz
    proc.spec1.dwell = 1/proc.spec1.sw_h;               % dwell time
    proc.spec1.sw    = proc.spec1.sw_h/proc.spec1.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw_h) not found. Program aborted.\n\n',FCTNAME);
    return
end

%--- info string ---
fprintf('\nSpectral data set 1 loaded from data sheet:\n');
fprintf('larmor frequency: %.1f MHz\n',proc.spec1.sf);
fprintf('sweep width:      %.1f Hz\n',proc.spec1.sw_h);
fprintf('Complex points:   %.0f\n\n',proc.spec1.nspecC);

%--- data export ---
proc.expt.sf     = proc.spec1.sf;
proc.expt.sw_h   = proc.spec1.sw_h;
proc.expt.nspecC = proc.spec1.nspecC;
if isfield(proc.expt,'spec')
    proc.expt = rmfield(proc.expt,'spec');
end
proc.expt.fid = proc.spec1.fidOrig;

%--- update read flag ---
f_succ = 1;
