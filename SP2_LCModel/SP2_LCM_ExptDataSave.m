%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ExptDataSave
%% 
%%  Export function (temporal) spectral data.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_ExptDataSave';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(lcm,'expt')
    fprintf('\n%s ->\nExport data do not exist. Data export aborted.\n',FCTNAME);
    return
end
if ~isfield(lcm.expt,'fid')
    fprintf('\n%s ->\nExport FID does not exist. Data export aborted.\n',FCTNAME);
    return
end
if ~isfield(lcm.expt,'sf')
    fprintf('\n%s ->\nExport parameter <sf> does not exist. Data export aborted.\n',FCTNAME);
    return
end
if ~isfield(lcm.expt,'sw_h')
    fprintf('\n%s ->\nExport parameter <sw_h> does not exist. Data export aborted.\n',FCTNAME);
    return
end
if ~isfield(lcm.expt,'nspecC')
    fprintf('\n%s ->\nExport parameter <nspecC> does not exist. Data export aborted.\n',FCTNAME);
    return
end
   
%--- save data to file ---
if flag.lcmDataFormat==1 || flag.lcmDataFormat==3 || flag.lcmDataFormat==5        % matlab format for .mat, .par or .mrui selection
    %--- data export ---
    exptDat.fid    = lcm.expt.fid;
    exptDat.sf     = lcm.expt.sf;
    exptDat.sw_h   = lcm.expt.sw_h;
    exptDat.nspecC = lcm.expt.nspecC;

    %--- check write permissions ---
    if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
        fprintf('Assigned export directory is not accessible. Program aborted.\n');
        return
    end
    
    %--- check write permissions ---
    if ~SP2_CheckDirWritePermR(lcm.expt.dataDir)
        fprintf('%s ->\nDesignated export directory does not have write permissions.\nPlease choose a different one.\n',FCTNAME);
        return
    end
    
    %--- data export to file ---
    save(lcm.expt.dataPathMat,'exptDat')
    fprintf('Data (& basic parameters) written to\n%s\n',lcm.expt.dataPathMat);
    if flag.lcmDataFormat==5
        fprintf('Writing to jMRUI not supported. INSPECTOR'' matlab format (.mat) was used instead.\n');
    end
    
elseif flag.lcmDataFormat==2                               % RAG text format
    %--- data export to file ---
    data2write = [real(lcm.expt.fid)'; imag(lcm.expt.fid)'];
    [unit,msg] = fopen(lcm.expt.dataPathTxt,'w');
    if unit==-1
        fprintf('%s ->\nOpening data file failed:\n%s\nMessage: %s\nProgram aborted.\n',...
                FCTNAME,lcm.expt.dataPathTxt,msg)
        return
    end
    fprintf(unit,'%9.5f		%9.5f\n',data2write);
    fclose(unit);

    %--- parameter export ---
    dotInd = find(lcm.expt.dataPathTxt=='.');
    if isempty(dotInd)
        parFilePath = [lcm.expt.dataPathTxt '.spx'];
    else
        parFilePath = [lcm.expt.dataPathTxt(1:(dotInd(end)-1)) '.spx'];
    end
    [unit,msg] = fopen(parFilePath,'w');
    if unit==-1
        fprintf('%s ->\nOpening parameter file failed.\nMessage: %s\nProgram aborted.\n',...
                FCTNAME,msg)
        return
    end
    fprintf(unit,'date %s\n',datestr(now));
    fprintf(unit,'sf %.5f\n',lcm.expt.sf);
    fprintf(unit,'sw_h %.3f\n',lcm.expt.sw_h);
    fprintf(unit,'nspecC %.0f\n\n',lcm.expt.nspecC);
    fclose(unit);
    
    %--- info printout ---
    fprintf('Data (only) written to\n%s\n',lcm.expt.dataPathTxt);
    fprintf('Basic parameters written to\n%s\n',parFilePath);
else                                                        % Provencher LCModel format
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
