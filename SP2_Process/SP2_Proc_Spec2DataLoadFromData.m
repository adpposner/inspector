%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_read = SP2_Proc_Spec2DataLoadFromData
%% 
%%  Assignment of specral data set 2
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data proc


FCTNAME = 'SP2_Proc_Spec2DataLoadFromData';


%--- init read flag ---
f_read = 0;

% %--- data assignment ---
% if data.expTypeDisplay==1 || data.expTypeDisplay==2 || ...      % regular MRS || JDE 1st&Last || ...
%    data.expTypeDisplay==3 || data.expTypeDisplay==4             % JDE 2nd&Last || JDE array
%     if isfield(data,'spec2')
%         if isfield(data.spec2,'fid')
%             %--- format handling ---
%             proc.spec2.fidOrig = data.spec2.fid;
% 
%             %--- consistency check ---
%             if ndims(proc.spec2.fidOrig)>1
%                 fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec2.fidOrig),0))
%             end
%         else
%             fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME)
%             return
%         end
%     else
%         fprintf('%s ->\nNo data structure for FID 1 found (''data.spec2''). Program aborted.\n',FCTNAME)
%         return
%     end
% else
%    fprintf('%s ->\nSelected data format is not supported.\nMake sure the data to be loaded is meaningful. \n',FCTNAME)
%    return
% end

%--- data assignment ---
if data.expTypeDisplay==1               % regular MRS
    if isfield(data,'spec2')
        if isfield(data.spec2,'fid')
            %--- format handling ---
            proc.spec2.fidOrig = data.spec1.fid;

            %--- consistency check ---
            if ndims(proc.spec2.fidOrig)~=2
                fprintf('%s ->\nIncompatible FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec2.fidOrig),0))
                return
            elseif size(proc.spec2.fidOrig,2)~=1
                fprintf('%s ->\nIncompatible FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec2.fidOrig),0))
                return
            end
        else
            fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME)
            return
        end
    else
        fprintf('%s ->\nNo data structure for FID 1 found (''data.spec1''). Program aborted.\n',FCTNAME)
        return
    end
elseif data.expTypeDisplay==2 || data.expTypeDisplay==3 || ...
       data.expTypeDisplay==4           % JDE 1st&Last OR JDE 2nd&Last OR JDE array
    if isfield(data,'spec2')
        if isfield(data.spec2,'fid')
            %--- format handling ---
            proc.spec2.fidOrig = data.spec2.fid;    

            %--- consistency check ---
            if ndims(proc.spec2.fidOrig)~=2
                fprintf('%s ->\nIncompatible FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec2.fidOrig),0))
                return
            elseif size(proc.spec2.fidOrig,2)~=1
                fprintf('%s ->\nIncompatible FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(proc.spec2.fidOrig),0))
                return
            end
        else
            fprintf('%s ->\nRaw data (FID 2) not found. Program aborted.\n\n',FCTNAME)
            return
        end
    else
        fprintf('%s ->\nNo data structure for FID 2 found (''data.spec2''). Program aborted.\n',FCTNAME)
        return
    end
else
   fprintf('%s ->\nSelected data format is not supported.\nMake sure the data to be loaded is meaningful. \n',FCTNAME)
   return
end
       
%--- assignment of further parameters ---
if isfield(data.spec2,'nspecC')
    proc.spec2.nspecCOrig = data.spec2.nspecC;       % number of complex data points (to be modified: cut, ZF)
    proc.spec2.nspecC     = data.spec2.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec2,'na')
    proc.spec2.na = data.spec2.na;
else
    fprintf('%s -> # of averages (na) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec2,'nr')
    proc.spec2.nr = data.spec2.nr;
else
    fprintf('%s -> # of repetitions (nr) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec2,'sf')
    proc.spec2.sf = data.spec2.sf;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec2,'sw_h')
    proc.spec2.sw_h  = data.spec2.sw_h;            % sweep width in Hz
    proc.spec2.dwell = 1/proc.spec2.sw_h;         % dwell time
    proc.spec2.sw    = proc.spec2.sw_h/proc.spec2.sf;    % sweep width in ppm
else
    fprintf('%s -> sweep width (sw_h) not found. Program aborted.\n\n',FCTNAME)
    return
end

%--- info string ---
fprintf('\nSpectral data set 2 loaded from data sheet:\n')
fprintf('larmor frequency: %.1f MHz\n',proc.spec2.sf)
fprintf('sweep width:      %.1f Hz\n',proc.spec2.sw_h)
fprintf('Complex points:   %.0f\n\n',proc.spec2.nspecC)

%--- data export ---
proc.expt.sf     = proc.spec2.sf;
proc.expt.sw_h   = proc.spec2.sw_h;
proc.expt.nspecC = proc.spec2.nspecC;
if isfield(proc.expt,'spec')
    proc.expt = rmfield(proc.expt,'spec');
end
proc.expt.fid = proc.spec2.fidOrig;

%--- update read flag ---
f_read = 1;
