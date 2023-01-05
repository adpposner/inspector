%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MRSI_ExptDataSave
%% 
%%  Export function (temporal) spectral data.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_ExptDataSave';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(mrsi,'expt')
    fprintf('\n%s ->\nExport data do not exist. Data export aborted.\n',FCTNAME);
    return
end
if ~isfield(mrsi.expt,'fid')
    fprintf('\n%s ->\nExport FID does not exist. Data export aborted.\n',FCTNAME);
    return
end
if ~isfield(mrsi.expt,'sf')
    fprintf('\n%s ->\nExport parameter <sf> does not exist. Data export aborted.\n',FCTNAME);
    return
end
if ~isfield(mrsi.expt,'sw_h')
    fprintf('\n%s ->\nExport parameter <sw_h> does not exist. Data export aborted.\n',FCTNAME);
    return
end
if ~isfield(mrsi.expt,'nspecC')
    fprintf('\n%s ->\nExport parameter <nspecC> does not exist. Data export aborted.\n',FCTNAME);
    return
end
   
%--- save data to file ---
if flag.mrsiDatFormat       % matlab format
    %--- data export ---
    exptDat.fid    = mrsi.expt.fid;
    exptDat.sf     = mrsi.expt.sf;
    exptDat.sw_h   = mrsi.expt.sw_h;
    exptDat.nspecC = mrsi.expt.nspecC;

    %--- data export to file ---
    save(mrsi.expt.dataPathMat,'exptDat')
    fprintf('Data (& basic parameters) written to\n%s\n',mrsi.expt.dataPathMat);
else                        % RAG text format
    %--- data export to file ---
    data2write = [real(mrsi.expt.fid)'; imag(mrsi.expt.fid)'];
    [unit,msg] = fopen(mrsi.expt.dataPathTxt,'w');
    if unit==-1
        fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
                FCTNAME,msg)
        return
    end
    fprintf(unit,'%9.5f		%9.5f\n',data2write);
    fclose(unit);

    %--- parameter export ---
    dotInd = find(mrsi.expt.dataPathTxt=='.');
    if isempty(dotInd)
        parFilePath = [mrsi.expt.dataPathTxt '.spx'];
    else
        parFilePath = [mrsi.expt.dataPathTxt(1:(dotInd(end)-1)) '.spx'];
    end
    [unit,msg] = fopen(parFilePath,'w');
    if unit==-1
        fprintf('%s ->\nOpening parameter file failed.\nMessage: %s\nProgram aborted.\n',...
                FCTNAME,msg)
        return
    end
    fprintf(unit,'date %s\n',datestr(now));
    fprintf(unit,'sf %.5f\n',mrsi.expt.sf);
    fprintf(unit,'sw_h %.3f\n',mrsi.expt.sw_h);
    fprintf(unit,'nspecC %.0f\n\n',mrsi.expt.nspecC);
    fclose(unit);
    
    %--- info printout ---
    fprintf('Data (only) written to\n%s\n',mrsi.expt.dataPathTxt);
    fprintf('Basic parameters written to\n%s\n',parFilePath);
end
    
%--- update success flag ---
f_succ = 1;
