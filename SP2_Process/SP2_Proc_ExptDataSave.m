%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ExptDataSave
%% 
%%  Export function (temporal) spectral data.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_ExptDataSave';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(proc,'expt')
    fprintf('\n%s ->\nExport data do not exist. Data export aborted.\n',FCTNAME)
    return
end
if ~isfield(proc.expt,'fid')
    fprintf('\n%s ->\nExport FID does not exist. Data export aborted.\n',FCTNAME)
    return
end
if ~isfield(proc.expt,'sf')
    fprintf('\n%s ->\nExport parameter <sf> does not exist. Data export aborted.\n',FCTNAME)
    return
end
if ~isfield(proc.expt,'sw_h')
    fprintf('\n%s ->\nExport parameter <sw_h> does not exist. Data export aborted.\n',FCTNAME)
    return
end
if ~isfield(proc.expt,'nspecC')
    fprintf('\n%s ->\nExport parameter <nspecC> does not exist. Data export aborted.\n',FCTNAME)
    return
end

%--- check directory access ---
if ~SP2_Proc_ExptDataPathUpdate
    return
end
if ~SP2_CheckDirAccessR(proc.expt.dataDir)
    fprintf('Assigned export directory is not accessible. Program aborted.\n')
    return
end

%--- check write permissions ---
if ~SP2_CheckDirWritePermR(proc.expt.dataDir)
    fprintf('%s ->\nDesignated export directory does not have write permissions.\nPlease choose a different one.\n',FCTNAME)
    return
end

%--- save data to file ---
if flag.procDataFormat==1 || flag.procDataFormat==3         % matlab or .par format
    %--- data export ---
    exptDat.fid    = proc.expt.fid;
    exptDat.sf     = proc.expt.sf;
    exptDat.sw_h   = proc.expt.sw_h;
    exptDat.nspecC = proc.expt.nspecC;
    
    %--- data export to file ---
    save(proc.expt.dataPathMat,'exptDat')
    fprintf('Data (& basic parameters) written to\n%s\n',proc.expt.dataPathMat);
elseif flag.procDataFormat==2                               % RAG text format
    %--- data export to file ---
    data2write = [real(proc.expt.fid)'; imag(proc.expt.fid)'];
    [unit,msg] = fopen(proc.expt.dataPathTxt,'w');
    if unit==-1
        fprintf('%s ->\nOpening data file failed:\n%s\nMessage: %s\nProgram aborted.\n',...
                FCTNAME,proc.expt.dataPathTxt,msg)
        return
    end
    fprintf(unit,'%9.5f		%9.5f\n',data2write);
    fclose(unit);

    %--- parameter export ---
    dotInd = find(proc.expt.dataPathTxt=='.');
    if isempty(dotInd)
        parFilePath = [proc.expt.dataPathTxt '.spx'];
    else
        parFilePath = [proc.expt.dataPathTxt(1:(dotInd(end)-1)) '.spx'];
    end
    [unit,msg] = fopen(parFilePath,'w');
    if unit==-1
        fprintf('%s ->\nOpening parameter file failed.\nMessage: %s\nProgram aborted.\n',...
                FCTNAME,msg)
        return
    end
    fprintf(unit,'date %s\n',datestr(now));
    fprintf(unit,'sf %.5f\n',proc.expt.sf);
    fprintf(unit,'sw_h %.3f\n',proc.expt.sw_h);
    fprintf(unit,'nspecC %.0f\n\n',proc.expt.nspecC);
    fclose(unit);
    
    %--- info printout ---
    fprintf('Data (only) written to\n%s\n',proc.expt.dataPathTxt);
    fprintf('Basic parameters written to\n%s\n',parFilePath);
else                                                        % Provencher LCModel .raw format
    %--- header creation ---
    if ~SP2_Proc_LcmSetHeader
        return
    end
                                                           
    %--- write FID ---
    if ~SP2_Proc_LcmWriteRaw
        return
    end
                                                            
    %--- write parameter file ---
    if flag.verbose
        if ~SP2_Proc_LcmWritePars
            return
        end
    end
end
    
%--- update success flag ---
f_succ = 1;
