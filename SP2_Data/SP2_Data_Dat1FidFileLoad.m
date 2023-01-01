%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat1FidFileLoad(varargin)
%% 
%%  Function to load 
%%  1) data set parameters for parameter files
%%     (method/acqp for Bruker, procpar/text for Varian)
%%  2) the data sets themselves
%%  (parameter consistency checks are also done here...)
%%
%%  arg: flag to enable/disable a trailing window update (default: update)
%%
%%  10-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data procpar fm

FCTNAME = 'SP2_Data_Dat1FidFileLoad';


%--- init success flag ---
f_succ = 0;

%--- argument handling ---
nArg = nargin;
if nArg==0
    f_winUpdate   = 1;        % default: window update
    f_LoadMsgFlag = 1;
elseif nArg==1
    f_winUpdate   = SP2_Check4FlagR(varargin{1});
    f_LoadMsgFlag = 1;
elseif nArg==2
    f_winUpdate   = SP2_Check4FlagR(varargin{1});
    f_LoadMsgFlag = SP2_Check4FlagR(varargin{2});
end

%--- retrieve/update data format ---
if f_LoadMsgFlag
    fprintf('\nLoading metabolite scan (Data 1):\n')
end
if strcmp(data.spec1.fidDir(end-4:end-1),'.fid')                % Varian
    fprintf('Data format: Varian\n')
    flag.dataManu = 1;        
elseif strcmp(data.spec1.fidName,'fid') || strcmp(data.spec1.fidName,'fid.refscan') || ...   % Bruker
       strcmp(data.spec1.fidName,'rawdata.job0') || strcmp(data.spec1.fidName,'rawdata.job1') 
    fprintf('Data format: Bruker\n')
    flag.dataManu = 2;     
elseif strcmp(data.spec1.fidFile(end-1:end),'.7')               % GE
    fprintf('Data format: General Electric\n')
    flag.dataManu = 3;
elseif strcmp(data.spec1.fidFile(end-3:end),'.rda')             % Siemens / rda
    fprintf('Data format: Siemens (.rda)\n')
    flag.dataManu = 4;
elseif strcmp(data.spec1.fidFile(end-3:end),'.dcm')             % DICOM / dcm
    fprintf('Data format: DICOM\n')
    flag.dataManu = 5;
elseif strcmp(data.spec1.fidFile(end-3:end),'.dat')             % Siemens / dat
    fprintf('Data format: Siemens (.dat)\n')
    flag.dataManu = 6;
elseif strcmp(data.spec1.fidFile(end-3:end),'.raw')             % Philips raw
    fprintf('Data format: Philips (.raw)\n')
    flag.dataManu = 7;
elseif strcmp(data.spec1.fidFile(end-4:end),'.SDAT')            % Philips collapsed
    fprintf('Data format: Philips (.SDAT)\n')
    flag.dataManu = 8;
elseif strcmp(data.spec1.fidFile(end-3:end),'.IMA')             % DICOM / IMA
    fprintf('Data format: DICOM (.IMA)\n')
    flag.dataManu = 9;
end

%--- warning if no scan numbering (XXX_) ---
% SP2_Data_CheckScanIndexFormat(data.spec1)

%--- check file existence ---
if ~SP2_CheckFileExistenceR(data.spec1.fidFile)
    return
end

%--- load parameters and data ---
if flag.dataManu==1                                             % Varian
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(data.spec1.methFile)
        return
    end
        
    %--- read acqp/method parameter files ---
    [procpar,f_done] = SP2_Data_VnmrReadProcpar(data.spec1.methFile,1);
    if ~f_done
        fprintf('%s ->\nData reading failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- read headers ---
    [procpar.dHeader,procpar.bHeader,f_read] = SP2_Data_VnmrReadHeaders(data.spec1.fidFile);
    if ~f_read
        return
    end
    
    %--- convert procpar to method structure ---
    if ~SP2_Data_ProcparConversion(procpar,1);
        fprintf('%s ->\nProcpar conversion failed. Program aborted.\n',FCTNAME)
        return
    end
        
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        [data.spec1,f_done] = SP2_Data_VnmrReadFidStability(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
            return
        end
    elseif flag.dataExpType==3              % JDE
        %--- consistency check ---
        if ~isfield(data.spec1,'njde')
            fprintf('%s ->\nParameter field ''njde'' missing.\nProgram aborted.\n',FCTNAME)
            return
        end
        if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
            fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
            return
        end
        
        %--- read data ---
        [data.spec1,f_done] = SP2_Data_VnmrReadFidJDE(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading JDE data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- info printout: sequence timing for JDE sLASER ---
        if flag.verbose
            if isfield(procpar,'sequTimingDur1Min')
                fprintf('\n********   semi-LASER JDE TIMING   ********\n')
                fprintf('Minimum durations (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
                        procpar.sequTimingDur1Min,procpar.sequTimingDur2Min,procpar.sequTimingDur3Min,...
                        procpar.sequTimingDur4Min,procpar.sequTimingDur5Min,procpar.sequTimingDur6Min,...
                        procpar.sequTimingDur7Min,procpar.sequTimingDur8Min)
            end
            if isfield(procpar,'sequTimingBal2')
                fprintf('Balance delays (2,6,7,8):\n%.3f / %.3f / %.3f / %.3f ms\n',...
                        procpar.sequTimingBal2,procpar.sequTimingBal6,...
                        procpar.sequTimingBal7,procpar.sequTimingBal8)
            end
            if isfield(procpar,'sequTimingDur1')
                fprintf('Sequence timing (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
                        procpar.sequTimingDur1,procpar.sequTimingDur2,procpar.sequTimingDur3,...
                        procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
                        procpar.sequTimingDur7,procpar.sequTimingDur8)
                fprintf('Sum %.3f ms (TE)\n',...
                        procpar.sequTimingDur1+procpar.sequTimingDur2+procpar.sequTimingDur3+...
                        procpar.sequTimingDur4+procpar.sequTimingDur5+procpar.sequTimingDur6+...
                        procpar.sequTimingDur7+procpar.sequTimingDur8)
                fprintf('SpinWizard timings (2&3 combined):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n\n',...
                        procpar.sequTimingDur1,procpar.sequTimingDur2+procpar.sequTimingDur3,...
                        procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
                        procpar.sequTimingDur7,procpar.sequTimingDur8)
            end
        end
    elseif flag.dataExpType==2                          % saturation-recovery series
        [data.spec1,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
    elseif flag.dataExpType==5                          % T1/T2 series    
        [data.spec1,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- T2 (TE) series ---
        if data.spec1.t2Series
            fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec1.t2TeExtra))
        elseif length(data.spec1.te)>1      % array
            fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec1.te))
        end        
    elseif flag.dataExpType==6                          % MRSI    
        [data.spec1,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- info printout ---
        fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec1.mrsi.fov),...
                SP2_Vec2PrintStr(data.spec1.mrsi.mat,0),data.spec1.mrsi.nEnc)   
            
        %--- read encoding tables from file ---
        [data.spec1.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec1.mrsi);
        if ~f_done
            fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
            return
        end 
    elseif flag.dataExpType==7              % JDE - array
        %--- consistency check ---
        if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
            fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
            return
        end
        
        %--- read data ---
        [data.spec1,f_done] = SP2_Data_VnmrReadFidJDE(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading JDE data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- info printout: sequence timing for JDE sLASER ---
        if flag.verbose
            if isfield(procpar,'sequTimingDur1Min')
                fprintf('\n********   semi-LASER JDE TIMING   ********\n')
                fprintf('Minimum durations (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
                        procpar.sequTimingDur1Min,procpar.sequTimingDur2Min,procpar.sequTimingDur3Min,...
                        procpar.sequTimingDur4Min,procpar.sequTimingDur5Min,procpar.sequTimingDur6Min,...
                        procpar.sequTimingDur7Min,procpar.sequTimingDur8Min)
            end
            if isfield(procpar,'sequTimingBal2')
                fprintf('Balance delays (2,6,7,8):\n%.3f / %.3f / %.3f / %.3f ms\n',...
                        procpar.sequTimingBal2,procpar.sequTimingBal6,...
                        procpar.sequTimingBal7,procpar.sequTimingBal8)
            end
            if isfield(procpar,'sequTimingDur1')
                fprintf('Sequence timing (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
                        procpar.sequTimingDur1,procpar.sequTimingDur2,procpar.sequTimingDur3,...
                        procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
                        procpar.sequTimingDur7,procpar.sequTimingDur8)
                fprintf('Sum %.3f ms (TE)\n',...
                        procpar.sequTimingDur1+procpar.sequTimingDur2+procpar.sequTimingDur3+...
                        procpar.sequTimingDur4+procpar.sequTimingDur5+procpar.sequTimingDur6+...
                        procpar.sequTimingDur7+procpar.sequTimingDur8)
                fprintf('SpinWizard timings (2&3 combined):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n\n',...
                        procpar.sequTimingDur1,procpar.sequTimingDur2+procpar.sequTimingDur3,...
                        procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
                        procpar.sequTimingDur7,procpar.sequTimingDur8)
            end
        end
    else                                                % regular data format
        [data.spec1,f_done] = SP2_Data_VnmrReadFid(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
    end
    
    % 20151230_05, cccnn: wrong, individual block headers
    % 20151231_01, cccnn: right, only one block header
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    
    % end of Varian
elseif flag.dataManu==2                                                         % Bruker
    %--- check file existence ---
    if ~SP2_CheckFileExistence(data.spec1.acqpFile)
        return
    end
    if ~SP2_CheckFileExistence(data.spec1.methFile)
        return
    end
    
    %--- read acqp parameter file ---
    [acqp,f_done] = SP2_Data_PvReadAcqp(data.spec1.acqpFile);
    if ~f_done
        fprintf('%s -> Reading <acqp> file failed:\n<%s>\n',FCTNAME,data.spec1.acqpFile)
        return
    end
    
    %--- verbose printout ---
    if flag.verbose
       if ~SP2_PrintStructure(acqp)
            return
       end
    end
        
    %--- read method parameter file ---
    [method,f_done] = SP2_Data_PvReadMethod(data.spec1.methFile);
    if ~f_done
        fprintf('%s -> Reading <method> file failed:\n<%s>\n',FCTNAME,data.spec1.methFile)
        return
    end
    
    %--- verbose printout ---
    if flag.verbose
       if ~SP2_PrintStructure(method)
            return
       end
    end
    
    %--- convert parameters to method structure ---
    if ~SP2_Data_PvParsConversion(method,acqp,1)
        fprintf('%s ->\nParaVision parameter conversion failed. Program aborted.\n',FCTNAME)
        return
    end

    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    elseif flag.dataExpType==3              % JDE
        %--- consistency check ---
        if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
            fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
            return
        end
                
        %--- read data file ---
        % 1: old, potential multi-dimensional <fid>, 2: new, single FID in fid file, 3: new, rawdata.job0
        if flag.dataBrukerFormat==1             % old fid
            [data.spec1.fid,f_done] = SP2_Data_PvReadOldFidJDE(data.spec1);
            if ~f_done || (length(data.spec1.fid)==1 && data.spec1.fid==0)
                fprintf('%s -> Reading (old) <fid> data file failed:\n<%s>\n',FCTNAME,data.spec1.fidFile)
                return
            end
        elseif flag.dataBrukerFormat==2         % new fid
            [data.spec1.fid,f_done] = SP2_Data_PvReadNewFidJDE(data.spec1);
            if ~f_done || (length(data.spec1.fid)==1 && data.spec1.fid==0)
                fprintf('%s -> Reading (new) <fid> data file failed:\n<%s>\n',FCTNAME,data.spec1.fidFile)
                return
            end
        else                                    % new raw data
            [data.spec1.fid,f_done] = SP2_Data_PvReadNewRawData(data.spec1);
            if ~f_done || (length(data.spec1.fid)==1 && data.spec1.fid==0)
                fprintf('%s -> Reading <rawdata.job0> data file failed:\n<%s>\n',FCTNAME,data.spec1.fidFile)
                return
            end
            
            %--- reformat JDE data for Yale to allow frequency/phase alignment ---
            % before: inner loop is ISIS (NA 8), outer loop is the JDE conditions
            % after:  the ISIS steps are interleaved with the JDE conditions
            if isfield(method,'IsisNAverages')
                if method.IsisNAverages>0
                    datFidTmp      = reshape(data.spec1.fid,data.spec1.nspecC,method.PVM_NAverages,method.PVM_NRepetitions);
                    data.spec1.fid = reshape(permute(datFidTmp,[1 3 2]),data.spec1.nspecC,1,method.PVM_NAverages*method.PVM_NRepetitions);
                end
            end
        end
        
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    else                                                % regular data format
        %--- read data file ---
        % 1: old, potential multi-dimensional <fid>, 2: new, single FID in fid file, 3: new, rawdata.job0
        if flag.dataBrukerFormat==1             % old fid
            [data.spec1.fid,f_done] = SP2_Data_PvReadOldFid(data.spec1);
            if ~f_done || (length(data.spec1.fid)==1 && data.spec1.fid==0)
                fprintf('%s -> Reading (old) <fid> data file failed:\n<%s>\n',FCTNAME,data.spec1.fidFile)
                return
            end
        elseif flag.dataBrukerFormat==2         % new fid
            [data.spec1.fid,f_done] = SP2_Data_PvReadNewFid(data.spec1);
            if ~f_done || (length(data.spec1.fid)==1 && data.spec1.fid==0)
                fprintf('%s -> Reading (new) <fid> data file failed:\n<%s>\n',FCTNAME,data.spec1.fidFile)
                return
            end
        else                                    % new raw data
            [data.spec1.fid,f_done] = SP2_Data_PvReadNewRawData(data.spec1);
            if ~f_done || (length(data.spec1.fid)==1 && data.spec1.fid==0)
                fprintf('%s -> Reading <rawdata.job0> data file failed:\n<%s>\n',FCTNAME,data.spec1.fidFile)
                return
            end
        end
    end
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    
    % end of Bruker
elseif flag.dataManu==3                                         % GE
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidStability(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [header,f_done] = SP2_Data_GEReadHeader(data.spec1.fidFile);
        if ~f_done
            fprintf('%s ->\nReading GE header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_GEParsConversion(header,1);
            fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
                
        %--- data format handling ---
        if data.spec1.ne==1                 % Larry Kegeles: 1 echo, conditions in nr
            %--- read header & data from file ---
            [datFid,f_done] = SP2_Data_GEReadFid(data.spec1);
            if ~f_done
                fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            % datFid = squeeze(datFid);
            if length(size(datFid))~=3
                fprintf('%s ->\nData format does not match expected JDE format. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            % note that njde is included in nr(metab)
            % raw order: nr(water)+nr(metab), nspecC, nRcvrs
            % new order: nspecC, nRcvrs, nr(metab)
            data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;
            data.spec1.fid = reshape(permute(conj(datFid(data.spec1.trOffset+1:end,:,:)),[2 3 1]),data.spec1.nspecC,...
                                 data.spec1.nRcvrs,data.spec1.nr);
            data.spec1.nr  = size(data.spec1.fid,3);

        elseif data.spec1.ne==2 && strcmp(data.spec1.sequence,'jpress') && strcmp(data.spec1.pp,'GE MEGA-PRESS Multisites')            % Kay/Leavitt/: 2 echoes, nr per condition                                 % Feng Liu: 2 echoes, nr per condition
            fprintf('\n%s ->\nNon-standard data format detected: Liu Feng\n',FCTNAME)
            fprintf('Sequence: ''%s''\n',data.spec1.sequence)
            fprintf('Protocol: ''%s''\n\n',data.spec1.pp)
            
            %--- update trOffset for specific case (Feng Liu) ---
            data.spec1.trOffset = data.spec1.nr - data.spec1.nr_FL;
            
            %--- read header & data from file ---
            [datFid,f_done] = SP2_Data_GEReadFidJDE(data.spec1);
            if ~f_done
                fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            % datFid = squeeze(datFid);
            if length(size(datFid))~=3
                fprintf('%s ->\nData format does not match expected JDE format. Program aborted.\n',FCTNAME)
                return
            end

            % raw order: nr(water)+nr(metab), nspecC, nRcvrs*njde
            % new order: nspecC, nRcvrs, nr(metab)*njde                     % JDE conditions interleaved, water stripped of
            data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;           % note: njde per water scan, included in trOffset
            data.spec1.fid = permute(conj(datFid(data.spec1.trOffset+1:end,:,:)),[2 3 1]);
            data.spec1.nr  = size(data.spec1.fid,3);
            
        elseif data.spec1.ne==2 && strcmp(data.spec1.sequence,'jpress')            % Kay/Leavitt/: 2 echoes, nr per condition
            fprintf('\n%s -> WARNING:\nNon-standard data format detected.\n',FCTNAME)
            fprintf('Sequence: ''%s''\n',data.spec1.sequence)
            fprintf('Protocol: ''%s''\n\n',data.spec1.pp)
                    
            %--- read header & data from file ---
            [datFid,f_done] = SP2_Data_GEReadFidJDE(data.spec1);
            if ~f_done
                fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            % datFid = squeeze(datFid);
            if length(size(datFid))~=3
                fprintf('%s ->\nData format does not match expected JDE format. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            % raw order: nr(water)+nr(metab), nspecC, nRcvrs*njde
            % new order: nspecC, nRcvrs, nr(metab)*njde                     % JDE conditions interleaved, water stripped of
            data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;           % note: njde per water scan, included in trOffset
            data.spec1.fid = permute(conj(datFid(data.spec1.trOffset+1:end,:,:)),[2 3 1]);
            data.spec1.nr  = size(data.spec1.fid,3);

        else               % unknown origin
            fprintf('\n%s -> WARNING:\nUNKNOWN DATA FORMAT DETECTED.\n',FCTNAME)
            fprintf('Sequence: ''%s''\n',data.spec1.sequence)
            fprintf('Protocol: ''%s''\n\n',data.spec1.pp)
            
            data.spec1
            
            %--- read header & data from file ---
            [datFid,f_done] = SP2_Data_GEReadFidJDE(data.spec1);
            if ~f_done
                fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            % datFid = squeeze(datFid);
            if length(size(datFid))~=3
                fprintf('%s ->\nData format does not match expected regular MRS format. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            % raw order: nr(water)+nr(metab), nspecC, nRcvrs*njde
            % new order: nspecC, nRcvrs, nr(metab)*njde                     % JDE conditions interleaved, water stripped of
            data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;           % note: njde per water scan, included in trOffset
            data.spec1.fid = permute(conj(datFid(data.spec1.trOffset+1:end,:,:)),[2 3 1]);
            data.spec1.nr  = size(data.spec1.fid,3);
        end
        
        %--- consistency check ---
        if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
            fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
            return
        end                
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    else                                                % regular data format
        %--- read header from file ---
        [header,f_done] = SP2_Data_GEReadHeader(data.spec1.fidFile);
        if ~f_done
            fprintf('%s ->\nReading GE header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_GEParsConversion(header,1);
            fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read header & data from file ---
        [datFid,f_done] = SP2_Data_GEReadFid(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
                
        %--- data reformating ---
        if data.spec1.nRcvrs>1              % multiple receivers
            if length(size(datFid))~=3
                fprintf('%s ->\nData format does not match expected regular MRS format. Program aborted.\n',FCTNAME)
                return
            end

            %--- metabolite extraction ---
            % original order: nr(water)+nr(metab), nspecC, nRcvrs
            % new order: nspecC, nRcvrs, nr(metab)                  % water stripped of
            data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;
            data.spec1.fid = reshape(permute(conj(datFid(data.spec1.trOffset+1:end,:,:)),[2 3 1]),data.spec1.nspecC,...
                                     data.spec1.nRcvrs,data.spec1.nr);
            data.spec1.nr  = size(data.spec1.fid,3);
        else                                % single receiver
            if length(size(datFid))~=2
                fprintf('%s ->\nData format does not match expected regular MRS format. Program aborted.\n',FCTNAME)
                return
            end

            %--- metabolite extraction ---
            % original order: nr(water)+nr(metab), nspecC, nRcvrs
            % new order: nspecC, nRcvrs, nr(metab)                  % water stripped of
            data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;
            data.spec1.fid = reshape(permute(conj(datFid(data.spec1.trOffset+1:end,:)),[2 1]),...
                                     data.spec1.nspecC,data.spec1.nr);
            data.spec1.nr  = size(data.spec1.fid,2);
        end
        
        % old:
        %         % datFid order: nr, nspecC, nRcvrs
        %         % new order: nspecC, nRcvrs, nr
        %         data.spec1.fid = permute(conj(datFid(3:end,:,:)),[2 3 1]);
        %         data.spec1.nr  = size(data.spec1.fid,3);
    end
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    
    %--- frequency display ---
    fprintf('Frequency: %.6f MHz\n',data.spec1.sf)
    
    % end of GE
elseif flag.dataManu==4                                         % Siemens .rda
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidStability(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_SiemensRdaReadHeader(data.spec1.fidFile);
        if ~f_done
            fprintf('%s ->\nReading Siemens header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec1,f_done] = SP2_Data_SiemensRdaReadFidJDE(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading Siemens data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_SiemensRdaParsConversion(procpar,1)
            fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
%         %--- read header & data from file ---
%         [raw,header,ec,f_done] = SP2_Data_SiemensRdaReadFid(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- convert parameters to method structure ---
%         if ~SP2_Data_SiemensRdaParsConversion(header,1);
%             fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- data reformating ---
%         datFidTmp = squeeze(raw);
%         % raw order: nr, nspecC, nRcvrs
%         % new order: nspecC, nRcvrs, nr
%         % data.spec1.fid = permute(conj(datFidTmp(9:end,:,:)),[2 3 1]);
%         data.spec1.nr  = data.spec1.nr - 8;
%         data.spec1.fid = reshape(permute(conj(datFidTmp(9:end,:,:,:)),[2 4 3 1]),data.spec1.nspecC,...
%                                  data.spec1.nRcvrs,data.spec1.nr*data.spec1.njde);
%         data.spec1.nr  = size(data.spec1.fid,3);
%         
%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end                
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec1.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec1.t2TeExtra))
%         elseif length(data.spec1.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec1.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec1.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec1.mrsi.mat,0),data.spec1.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec1.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec1.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidJDE(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading JDE data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout: sequence timing for JDE sLASER ---
%         if flag.verbose
%             if isfield(procpar,'sequTimingDur1Min')
%                 fprintf('\n********   semi-LASER JDE TIMING   ********\n')
%                 fprintf('Minimum durations (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingDur1Min,procpar.sequTimingDur2Min,procpar.sequTimingDur3Min,...
%                         procpar.sequTimingDur4Min,procpar.sequTimingDur5Min,procpar.sequTimingDur6Min,...
%                         procpar.sequTimingDur7Min,procpar.sequTimingDur8Min)
%             end
%             if isfield(procpar,'sequTimingBal2')
%                 fprintf('Balance delays (2,6,7,8):\n%.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingBal2,procpar.sequTimingBal6,...
%                         procpar.sequTimingBal7,procpar.sequTimingBal8)
%             end
%             if isfield(procpar,'sequTimingDur1')
%                 fprintf('Sequence timing (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingDur1,procpar.sequTimingDur2,procpar.sequTimingDur3,...
%                         procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
%                         procpar.sequTimingDur7,procpar.sequTimingDur8)
%                 fprintf('Sum %.3f ms (TE)\n',...
%                         procpar.sequTimingDur1+procpar.sequTimingDur2+procpar.sequTimingDur3+...
%                         procpar.sequTimingDur4+procpar.sequTimingDur5+procpar.sequTimingDur6+...
%                         procpar.sequTimingDur7+procpar.sequTimingDur8)
%                 fprintf('SpinWizard timings (2&3 combined):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n\n',...
%                         procpar.sequTimingDur1,procpar.sequTimingDur2+procpar.sequTimingDur3,...
%                         procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
%                         procpar.sequTimingDur7,procpar.sequTimingDur8)
%             end
%         end
    else                                                % regular data format
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_SiemensRdaReadHeader(data.spec1.fidFile);
        if ~f_done
            fprintf('%s ->\nReading Siemens header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- consistency check ---
        if ~isempty(findstr(procpar.SequenceName,'csi')) && prod(procpar.CSIMatrixSize)>1
            fprintf('\n%s ->\nCSI sequence detected. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec1,f_done] = SP2_Data_SiemensRdaReadFid(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading Siemens data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_SiemensRdaParsConversion(procpar,1)
            fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
    end
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    % end of Siemens .rda
    
elseif flag.dataManu==5                                         % DICOM (.dcm)
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidStability(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- read header & data from file ---
%         [raw,header,ec,f_done] = SP2_Data_GEReadFid(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- convert parameters to method structure ---
%         if ~SP2_Data_GEParsConversion(header,1);
%             fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- data reformating ---
%         datFidTmp = squeeze(raw);
%         % raw order: nr, nspecC, nRcvrs
%         % new order: nspecC, nRcvrs, nr
%         % data.spec1.fid = permute(conj(datFidTmp(9:end,:,:)),[2 3 1]);
%         data.spec1.nr  = data.spec1.nr - 8;
%         data.spec1.fid = reshape(permute(conj(datFidTmp(9:end,:,:,:)),[2 4 3 1]),data.spec1.nspecC,...
%                                  data.spec1.nRcvrs,data.spec1.nr*data.spec1.njde);
%         data.spec1.nr  = size(data.spec1.fid,3);
%         
%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end                
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec1.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec1.t2TeExtra))
%         elseif length(data.spec1.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec1.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec1.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec1.mrsi.mat,0),data.spec1.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec1.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec1.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return

    else                                                % regular data format
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_DicomImaReadHeader(data.spec1.fidFile);
        if f_done
            fprintf('%s ->\nDICOM (dcm) header read from file\n',FCTNAME)
        else
            fprintf('%s ->\nReading DICOM (dcm) header failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read further header data from file ---
        % included for Kay Igwe, 06/2020
        if strcmp(procpar.Manufacturer,'SIEMENS') || ...
           strcmp(procpar.Manufacturer,'Siemens')
           %--- read header from file ---
            [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec1.fidFile);
            if ~f_done
                fprintf('%s ->\nReading Siemens DICOM (dcm) header from file failed. Program aborted.\n',FCTNAME)
                return
            end

            %--- convert parameters to method structure ---
            if ~SP2_Data_SiemensDatParsConversion(procpar,1)
                fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
                return
            end
            
            % DICOMs contain single FIDs only, i.e. while a multi-Rx system might
            % have been used, this is not prepresented in the data anymore.
            % To this end, a potential nRcvrs>1 entry is reduced to 1 here   
            if data.spec1.nRcvrs == 0
                data.spec1.nRcvrs = 1;
            elseif data.spec1.nRcvrs > 1
                fprintf('Note: # of receivers adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                        data.spec1.nRcvrs)
                data.spec1.nRcvrs = 1;
            end
            if data.spec1.nr > 1
                fprintf('Note: # of repetitions adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                        data.spec1.nr)
                data.spec1.nr = 1;
            end
            
            %--- somewhat ugly: read dicom header again with standard DICOM reader ---
            [procpar,f_done] = SP2_Data_DicomReadHeader(data.spec1.fidFile);
            if ~f_done
                fprintf('%s ->\nReading DICOM (dcm) header failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- assign further parameters ---
            if isfield(procpar,'SoftwareVersion') && strcmp(data.spec1.software,'')
                data.spec1.software = procpar.SoftwareVersion;
            end
            if isfield(procpar,'SoftwareVersion') && strcmp(data.spec1.softGeneration,'')
                if any(strfind(procpar.SoftwareVersion,'MR B'))
                    data.spec1.softGeneration = 'VB';
                elseif any(strfind(procpar.SoftwareVersion,'MR D'))
                    data.spec1.softGeneration = 'VD';
                elseif any(strfind(procpar.SoftwareVersion,'MR E'))
                    data.spec1.softGeneration = 'VE';
                end
            end
            if isfield(procpar,'InstitutionName') && strcmp(data.spec1.institution,'')
                data.spec1.institution = procpar.InstitutionName;
            end
            if isfield(procpar,'PatientName') && strcmp(data.spec1.patient,'')
                data.spec1.patient = procpar.PatientName;
            end
            if isfield(procpar,'StudyDescription') && strcmp(data.spec1.study,'')
                data.spec1.study = procpar.StudyDescription;
            end
            if isfield(procpar,'SequenceName') && strcmp(data.spec1.sequence,'')
                data.spec1.sequence = procpar.SequenceName;
            end
        else
           fprintf('%s ->\nDICOM (dcm) format only supported for Siemens data.\n',FCTNAME)
           return
        end
        
        %--- read data from file ---
        % note: IMA reading function even if dcm file format
        [data.spec1,f_done] = SP2_Data_DicomImaReadFid(data.spec1);
        if f_done
            fprintf('%s ->\nDICOM (dcm) data read from file.\n',FCTNAME)
        else
            fprintf('%s ->\nReading data from DICOM file failed. Program aborted.\n',FCTNAME)
            return
        end
    end
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    % end of DICOM (.dcm)
    
elseif flag.dataManu==6                                         % Siemens .dat
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidStability(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec1.fidFile);
        if ~f_done
            fprintf('%s ->\nReading Siemens JDE header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_SiemensDatParsConversion(procpar,1)
            fprintf('%s ->\nSiemens JDE parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- JDE ---
        data.spec1.njde = 2;
        
        %--- read data from file ---
        [data.spec1,f_done] = SP2_Data_SiemensDatReadFidJDE(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading Siemens JDE data file failed. Program aborted.\n',FCTNAME)
            return
        end
            
        %--- consistency check ---
        % nspecC, nRcvrs, nr
        if length(size(data.spec1.fid))~=3 && data.spec1.nr>1
            fprintf('%s ->\nData format does not match expected JDE MRS format.\n',FCTNAME)
            fprintf('size(data.spec1.fid) = %s\n',SP2_Vec2PrintStr(size(data.spec1.fid),0,1))
            fprintf('Program aborted.\n')
            return
        end    
                
        %--- metabolite extraction ---
        % original order: nspecC, nRcvrs, nr(water)+nr(ON/OFF)
        % new order: nspecC, nRcvrs, nr(ON/OFF)                  % water stripped of
        if data.spec1.trOffset>0
            data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;
            data.spec1.fid = data.spec1.fid(:,:,data.spec1.trOffset+1:end);
            % data.spec1.nr  = size(data.spec1.fid,3);
        end
              
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec1.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec1.t2TeExtra))
%         elseif length(data.spec1.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec1.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec1.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec1.mrsi.mat,0),data.spec1.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec1.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec1.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return

    else                                                % regular data format
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec1.fidFile);
        if ~f_done
            fprintf('%s ->\nReading Siemens header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_SiemensDatParsConversion(procpar,1)
            fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec1,f_done] = SP2_Data_SiemensDatReadFid(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading Siemens data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- consistency check ---
        % nspecC, nRcvrs, nr
        if length(size(data.spec1.fid))~=2 && data.spec1.nr==1
            fprintf('%s ->\nData format does not match expected regular MRS format.\n',FCTNAME)
            fprintf('size(data.spec1.fid) = %s, nr = 1\n',SP2_Vec2PrintStr(size(data.spec1.fid),0,1))
            fprintf('Program aborted.\n')
            return
        end
        if length(size(data.spec1.fid))~=3 && data.spec1.nr>1
            fprintf('%s ->\nData format does not match expected regular MRS format.\n',FCTNAME)
            fprintf('size(data.spec1.fid) = %s\n',SP2_Vec2PrintStr(size(data.spec1.fid),0,1))
            fprintf('Program aborted.\n')
            return
        end
        
        %--- metabolite extraction ---
        % original order: nspecC, nRcvrs, nr(water)+nr(metab)
        % new order: nspecC, nRcvrs, nr(metab)                  % water stripped of
        if data.spec1.trOffset>0
            data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;
            data.spec1.fid = data.spec1.fid(:,:,data.spec1.trOffset+1:end);
            % data.spec1.nr  = size(data.spec1.fid,3);
        end
    end
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    % end of Siemens .dat

elseif flag.dataManu==7                                         % Philips .raw
    %--- check file existence ---
    if ~SP2_CheckFileExistence(data.spec1.acqpFile)
        return
    end
    if ~SP2_CheckFileExistence(data.spec1.methFile)
        return
    end
    
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidStability(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_PhilipsRawReadSinLabFiles(data.spec1.methFile,data.spec1.acqpFile);
        if ~f_done
            fprintf('%s ->\nReading Philips parameters from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_PhilipsRawParsConversion(procpar,1)
            fprintf('%s ->\nPhilips parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [datFid,f_done] = SP2_Data_PhilipsRawReadFid(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading Philips data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- data reformating ---
        if length(size(datFid))~=3
            fprintf('%s ->\nData format does not match expected JDE MRS format. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- metabolite extraction ---
        % order remains unchanged: nspecC, nRcvrs, nr(metab)                  % water stripped of
        data.spec1.nr   = data.spec1.nr - data.spec1.trOffset;
        data.spec1.fid  = datFid(:,:,data.spec1.trOffset+1:end);
        data.spec1.nr   = size(data.spec1.fid,3);
        data.spec1.njde = 2;

%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end                
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec1.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec1.t2TeExtra))
%         elseif length(data.spec1.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec1.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec1.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec1.mrsi.mat,0),data.spec1.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec1.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec1.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidJDE(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading JDE data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout: sequence timing for JDE sLASER ---
%         if flag.verbose
%             if isfield(procpar,'sequTimingDur1Min')
%                 fprintf('\n********   semi-LASER JDE TIMING   ********\n')
%                 fprintf('Minimum durations (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingDur1Min,procpar.sequTimingDur2Min,procpar.sequTimingDur3Min,...
%                         procpar.sequTimingDur4Min,procpar.sequTimingDur5Min,procpar.sequTimingDur6Min,...
%                         procpar.sequTimingDur7Min,procpar.sequTimingDur8Min)
%             end
%             if isfield(procpar,'sequTimingBal2')
%                 fprintf('Balance delays (2,6,7,8):\n%.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingBal2,procpar.sequTimingBal6,...
%                         procpar.sequTimingBal7,procpar.sequTimingBal8)
%             end
%             if isfield(procpar,'sequTimingDur1')
%                 fprintf('Sequence timing (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingDur1,procpar.sequTimingDur2,procpar.sequTimingDur3,...
%                         procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
%                         procpar.sequTimingDur7,procpar.sequTimingDur8)
%                 fprintf('Sum %.3f ms (TE)\n',...
%                         procpar.sequTimingDur1+procpar.sequTimingDur2+procpar.sequTimingDur3+...
%                         procpar.sequTimingDur4+procpar.sequTimingDur5+procpar.sequTimingDur6+...
%                         procpar.sequTimingDur7+procpar.sequTimingDur8)
%                 fprintf('SpinWizard timings (2&3 combined):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n\n',...
%                         procpar.sequTimingDur1,procpar.sequTimingDur2+procpar.sequTimingDur3,...
%                         procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
%                         procpar.sequTimingDur7,procpar.sequTimingDur8)
%             end
%         end
    else                                                % regular data format
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_PhilipsRawReadSinLabFiles(data.spec1.methFile,data.spec1.acqpFile);
        if ~f_done
            fprintf('%s ->\nReading Philips parameters from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_PhilipsRawParsConversion(procpar,1)
            fprintf('%s ->\nPhilips parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [datFid,f_done] = SP2_Data_PhilipsRawReadFid(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading Philips data file failed. Program aborted.\n',FCTNAME)
            return
        end
                
        %--- data reformating ---
%         datFid = squeeze(datFid);
        if length(size(datFid))~=3
            fprintf('%s ->\nData format does not match expected regular MRS format. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- metabolite extraction ---
        % order remains unchanged: nspecC, nRcvrs, nr(metab)                  % water stripped of
        data.spec1.nr  = data.spec1.nr - data.spec1.trOffset;
        data.spec1.fid = datFid(:,:,data.spec1.trOffset+1:end);
        data.spec1.nr  = size(data.spec1.fid,3);
    end
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    % end of Philips .raw
    
elseif flag.dataManu==8                                         % Philips .SDAT
    %--- check file existence ---
    if ~SP2_CheckFileExistence(data.spec1.methFile)
        return
    end
    
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidStability(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_PhilipsSdatReadSparFile(data.spec1.methFile);
        if ~f_done
            fprintf('%s ->\nReading Philips header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_PhilipsSdatParsConversion(procpar,1)
            fprintf('%s ->\nPhilips parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec1,f_done] = SP2_Data_PhilipsSdatReadFid(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading Philips data file failed. Program aborted.\n',FCTNAME)
            return
        end
            
%         %--- data reformating ---
%         datFidTmp = squeeze(datFid);
%         % datFid order: nr, nspecC, nRcvrs
%         % new order: nspecC, nRcvrs, nr
%         % data.spec1.fid = permute(conj(datFidTmp(9:end,:,:)),[2 3 1]);
%         data.spec1.nr  = data.spec1.nr - 8;
%         data.spec1.fid = reshape(permute(conj(datFidTmp(9:end,:,:,:)),[2 4 3 1]),data.spec1.nspecC,...
%                                  data.spec1.nRcvrs,data.spec1.nr*data.spec1.njde);
%         data.spec1.nr  = size(data.spec1.fid,3);

        data.spec1.njde = 2;

%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end                
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec1.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec1.t2TeExtra))
%         elseif length(data.spec1.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec1.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec1.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec1.mrsi.mat,0),data.spec1.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec1.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec1.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidJDE(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading JDE data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout: sequence timing for JDE sLASER ---
%         if flag.verbose
%             if isfield(procpar,'sequTimingDur1Min')
%                 fprintf('\n********   semi-LASER JDE TIMING   ********\n')
%                 fprintf('Minimum durations (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingDur1Min,procpar.sequTimingDur2Min,procpar.sequTimingDur3Min,...
%                         procpar.sequTimingDur4Min,procpar.sequTimingDur5Min,procpar.sequTimingDur6Min,...
%                         procpar.sequTimingDur7Min,procpar.sequTimingDur8Min)
%             end
%             if isfield(procpar,'sequTimingBal2')
%                 fprintf('Balance delays (2,6,7,8):\n%.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingBal2,procpar.sequTimingBal6,...
%                         procpar.sequTimingBal7,procpar.sequTimingBal8)
%             end
%             if isfield(procpar,'sequTimingDur1')
%                 fprintf('Sequence timing (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingDur1,procpar.sequTimingDur2,procpar.sequTimingDur3,...
%                         procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
%                         procpar.sequTimingDur7,procpar.sequTimingDur8)
%                 fprintf('Sum %.3f ms (TE)\n',...
%                         procpar.sequTimingDur1+procpar.sequTimingDur2+procpar.sequTimingDur3+...
%                         procpar.sequTimingDur4+procpar.sequTimingDur5+procpar.sequTimingDur6+...
%                         procpar.sequTimingDur7+procpar.sequTimingDur8)
%                 fprintf('SpinWizard timings (2&3 combined):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n\n',...
%                         procpar.sequTimingDur1,procpar.sequTimingDur2+procpar.sequTimingDur3,...
%                         procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
%                         procpar.sequTimingDur7,procpar.sequTimingDur8)
%             end
%         end
    else                                                % regular data format
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_PhilipsSdatReadSparFile(data.spec1.methFile);
        if ~f_done
            fprintf('%s ->\nReading Philips header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_PhilipsSdatParsConversion(procpar,1)
            fprintf('%s ->\nPhilips parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec1,f_done] = SP2_Data_PhilipsSdatReadFid(data.spec1);
        if ~f_done
            fprintf('%s ->\nReading Philips data file failed. Program aborted.\n',FCTNAME)
            return
        end
    end
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    % end of Philips .SDAT
    
elseif flag.dataManu==9                                         % DICOM .IMA
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidStability(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        
        %--- serial file handling ---
        allNames = SP2_GetAllFiles(data.spec1.fidDir);
        imaNames = {};
        imaCnt   = 0;
        for aCnt = 1:length(allNames)
            if strcmp(allNames{aCnt}(end-3:end),'.IMA')
                imaCnt = imaCnt + 1;
                imaNames{imaCnt} = allNames{aCnt};
                if ispc
                    ind = find(imaNames{imaCnt}=='\');
                else
                    ind = find(imaNames{imaCnt}=='/');
                end
                imaFiles{imaCnt} = imaNames{imaCnt}(ind(end)+1:end);
            end
        end
        nSpecFiles = imaCnt;       % overall number of DICOM files
        if nSpecFiles<1
            fprintf('\nNo (ima) DICOM images found. Program aborted.\n')
            return
        end

        %--- read images from file ---
        fprintf('\n')
        for iCnt = 1:nSpecFiles
            %--- parameter handling ---
            if iCnt==1            % first slice of magnitude
                %--- read header from file ---
                [procpar,f_done] = SP2_Data_DicomImaReadHeader(data.spec1.fidFile);
                if ~f_done
                    fprintf('%s ->\nReading DICOM header failed. Program aborted.\n',FCTNAME)
                    return
                end

                %--- read further header data from file ---
                if strcmp(procpar.Manufacturer,'SIEMENS') || ...
                   strcmp(procpar.Manufacturer,'Siemens')
                   %--- read header from file ---
                    [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec1.fidFile);
                    if ~f_done
                        fprintf('%s ->\nReading Siemens DICOM header from file failed. Program aborted.\n',FCTNAME)
                        return
                    end

                    %--- convert parameters to method structure ---
                    if ~SP2_Data_SiemensDatParsConversion(procpar,1)
                        fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
                        return
                    end

                    % DICOMs contain single FIDs only, i.e. while a multi-Rx system might
                    % have been used, this is not prepresented in the data anymore.
                    % To this end, a potential nRcvrs>1 entry is reduced to 1 here
                    if data.spec1.nRcvrs == 0
                        data.spec1.nRcvrs = 1;
                    elseif data.spec1.nRcvrs > 1
                        fprintf('Note: # of receivers adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                                data.spec1.nRcvrs)
                        data.spec1.nRcvrs = 1;
                    end
                    if data.spec1.nr > 1
                        fprintf('Note: # of repetitions adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                                data.spec1.nr)
                        data.spec1.nr = 1;
                    end

                    %--- somewhat ugly: read dicom header again with standard DICOM reader ---
                    [procpar,f_done] = SP2_Data_DicomReadHeader(data.spec1.fidFile);
                    if ~f_done
                        fprintf('%s ->\nReading DICOM header failed. Program aborted.\n',FCTNAME)
                        return
                    end

                    %--- assign further parameters ---
                    if isfield(procpar,'SoftwareVersion') && strcmp(data.spec1.software,'')
                        data.spec1.software = procpar.SoftwareVersion;
                    end
                    if isfield(procpar,'SoftwareVersion') && strcmp(data.spec1.softGeneration,'')
                        if any(strfind(procpar.SoftwareVersion,'MR B'))
                            data.spec1.softGeneration = 'VB';
                        elseif any(strfind(procpar.SoftwareVersion,'MR D'))
                            data.spec1.softGeneration = 'VD';
                        elseif any(strfind(procpar.SoftwareVersion,'MR E'))
                            data.spec1.softGeneration = 'VE';
                        end
                    end
                    if isfield(procpar,'InstitutionName') && strcmp(data.spec1.institution,'')
                        data.spec1.institution = procpar.InstitutionName;
                    end
                    if isfield(procpar,'PatientName') && strcmp(data.spec1.patient,'')
                        data.spec1.patient = procpar.PatientName;
                    end
                    if isfield(procpar,'StudyDescription') && strcmp(data.spec1.study,'')
                        data.spec1.study = procpar.StudyDescription;
                    end
                    if isfield(procpar,'SequenceName') && strcmp(data.spec1.sequence,'')
                        data.spec1.sequence = procpar.SequenceName;
                    end
                            
                    %--- metabolite extraction ---
                    % order remains unchanged: nspecC, nRcvrs, nr(metab)                  % water stripped of
                    data.spec1.njde = 2;
                    data.spec1.nr   = nSpecFiles;
%                     data.spec1.fid  = complex(zeros(data.spec1.nspecC,1,data.spec1.nr));
                    data.spec1.fidTmp = complex(zeros(data.spec1.nspecC,1,data.spec1.nr));
                else
                   fprintf('%s ->\nDICOM (IMA) format only supported for Siemens data.\n',FCTNAME)
                   return
                end
            end
            
            %--- read data ---
            set(fm.data.spec1FidFile,'String',[data.spec1.fidDir imaFiles{iCnt}])
            if ~SP2_Data_Dat1FidFileUpdate 
                return
            end
            [data.spec1,f_done] = SP2_Data_DicomImaReadFid(data.spec1);
            if f_done
                fprintf('Reading completed.\n')
            else
                fprintf('%s ->\nReading data from DICOM (IMA) file failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data assignment ---
            % order remains unchanged: nspecC, nRcvrs, nr(metab)                  
            data.spec1.fidTmp(:,iCnt) = data.spec1.fid;
        
            %--- info printout ---
            if mod(iCnt,10)==0
                fprintf('%.0f (of %.0f) individual DICOM files loaded...\n',iCnt,nSpecFiles)
            end
        end
        data.spec1.fid = data.spec1.fidTmp;         % 12/06/2021, JDE of GSH @ ZMBBI, Collab MRS course
        data.spec1 = rmfield(data.spec1,'fidTmp');
        
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec1.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec1.t2TeExtra))
%         elseif length(data.spec1.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec1.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec1.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec1.mrsi.mat,0),data.spec1.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec1.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec1.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec1,f_done] = SP2_Data_VnmrReadFidJDE(data.spec1);
%         if ~f_done
%             fprintf('%s ->\nReading JDE data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout: sequence timing for JDE sLASER ---
%         if flag.verbose
%             if isfield(procpar,'sequTimingDur1Min')
%                 fprintf('\n********   semi-LASER JDE TIMING   ********\n')
%                 fprintf('Minimum durations (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingDur1Min,procpar.sequTimingDur2Min,procpar.sequTimingDur3Min,...
%                         procpar.sequTimingDur4Min,procpar.sequTimingDur5Min,procpar.sequTimingDur6Min,...
%                         procpar.sequTimingDur7Min,procpar.sequTimingDur8Min)
%             end
%             if isfield(procpar,'sequTimingBal2')
%                 fprintf('Balance delays (2,6,7,8):\n%.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingBal2,procpar.sequTimingBal6,...
%                         procpar.sequTimingBal7,procpar.sequTimingBal8)
%             end
%             if isfield(procpar,'sequTimingDur1')
%                 fprintf('Sequence timing (1-8):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n',...
%                         procpar.sequTimingDur1,procpar.sequTimingDur2,procpar.sequTimingDur3,...
%                         procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
%                         procpar.sequTimingDur7,procpar.sequTimingDur8)
%                 fprintf('Sum %.3f ms (TE)\n',...
%                         procpar.sequTimingDur1+procpar.sequTimingDur2+procpar.sequTimingDur3+...
%                         procpar.sequTimingDur4+procpar.sequTimingDur5+procpar.sequTimingDur6+...
%                         procpar.sequTimingDur7+procpar.sequTimingDur8)
%                 fprintf('SpinWizard timings (2&3 combined):\n%.3f / %.3f / %.3f / %.3f / %.3f / %.3f / %.3f ms\n\n',...
%                         procpar.sequTimingDur1,procpar.sequTimingDur2+procpar.sequTimingDur3,...
%                         procpar.sequTimingDur4,procpar.sequTimingDur5,procpar.sequTimingDur6,...
%                         procpar.sequTimingDur7,procpar.sequTimingDur8)
%             end
%         end
    else                                                % regular data format
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_DicomImaReadHeader(data.spec1.fidFile);
        if ~f_done
            fprintf('%s ->\nReading DICOM header failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        if strcmp(procpar.Manufacturer,'SIEMENS') || ...
           strcmp(procpar.Manufacturer,'Siemens')
           %--- read header from file ---
            [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec1.fidFile);
            if ~f_done
                fprintf('%s ->\nReading Siemens DICOM header from file failed. Program aborted.\n',FCTNAME)
                return
            end

            %--- convert parameters to method structure ---
            if ~SP2_Data_SiemensDatParsConversion(procpar,1)
                fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
                return
            end
            
            % DICOMs contain single FIDs only, i.e. while a multi-Rx system might
            % have been used, this is not prepresented in the data anymore.
            % To this end, a potential nRcvrs>1 entry is reduced to 1 here   
            if data.spec1.nRcvrs == 0
                data.spec1.nRcvrs = 1;
            elseif data.spec1.nRcvrs > 1
                fprintf('Note: # of receivers adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                        data.spec1.nRcvrs)
                data.spec1.nRcvrs = 1;
            end
            if data.spec1.nr > 1
                fprintf('Note: # of repetitions adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                        data.spec1.nr)
                data.spec1.nr = 1;
            end
            
            %--- somewhat ugly: read dicom header again with standard DICOM reader ---
            [procpar,f_done] = SP2_Data_DicomReadHeader(data.spec1.fidFile);
            if ~f_done
                fprintf('%s ->\nReading DICOM header failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- assign further parameters ---
            if isfield(procpar,'SoftwareVersion') && strcmp(data.spec1.software,'')
                data.spec1.software = procpar.SoftwareVersion;
            end
            if isfield(procpar,'SoftwareVersion') && strcmp(data.spec1.softGeneration,'')
                if any(strfind(procpar.SoftwareVersion,'MR B'))
                    data.spec1.softGeneration = 'VB';
                elseif any(strfind(procpar.SoftwareVersion,'MR D'))
                    data.spec1.softGeneration = 'VD';
                elseif any(strfind(procpar.SoftwareVersion,'MR E'))
                    data.spec1.softGeneration = 'VE';
                end
            end
            if isfield(procpar,'InstitutionName') && strcmp(data.spec1.institution,'')
                data.spec1.institution = procpar.InstitutionName;
            end
            if isfield(procpar,'PatientName') && strcmp(data.spec1.patient,'')
                data.spec1.patient = procpar.PatientName;
            end
            if isfield(procpar,'StudyDescription') && strcmp(data.spec1.study,'')
                data.spec1.study = procpar.StudyDescription;
            end
            if isfield(procpar,'SequenceName') && strcmp(data.spec1.sequence,'')
                data.spec1.sequence = procpar.SequenceName;
            end
        else
           fprintf('%s ->\nDICOM (IMA) format only supported for Siemens data.\n',FCTNAME)
           return
        end
        
        %--- read data ---
        [data.spec1,f_done] = SP2_Data_DicomImaReadFid(data.spec1);
        if f_done
            fprintf('Reading completed.\n')
        else
            fprintf('%s ->\nReading data from DICOM (IMA) file failed. Program aborted.\n',FCTNAME)
            return
        end
        
%         %--- convert parameters to method structure ---
%         if ~SP2_Data_DicomImaParsConversion(procpar,1);
%             fprintf('%s ->\nDICOM parameter conversion failed. Program aborted.\n',FCTNAME)
%             return
%         end
        
        
        %--- data reformating ---
%         data.spec1.fid = squeeze(datFid).';         % fir 1D & NR=1
        % raw order: nr, nspecC, nRcvrs
        % new order: nspecC, nRcvrs, nr
%         data.spec1.fid = permute(datFid(3:end,:,:),[2 3 1]);
%         data.spec1.nr  = size(data.spec1.fid,3);
    end
    
    %--- dimension handling ---
    data.spec1.dim = length(size(data.spec1.fid));
    % end of DICOM .IMA
    
else
    fprintf('%s ->\nData format not valid. File assignment aborted.\n',FCTNAME)
    return
end

%--- update of current receiver assignment ---
if flag.dataRcvrAllSelect                                           % all
    if isfield(data.spec1,'nRcvrs')
        data.rcvr       = ones(1,data.spec1.nRcvrs);                % selection vector assignment
    else
        data.rcvr       = ones(1,data.rcvrMax);                     % selection vector assignment
    end
    data.rcvrInd        = find(data.rcvr);                          %            
    data.rcvrN          = length(data.rcvrInd);                     % number of selected receivers
else                                                                % selection
    data.rcvrInd        = eval(['[' data.rcvrSelectStr ']']);       % selection vector assignment
    data.rcvr           = zeros(1,data.rcvrMax);                    %            
    data.rcvr(data.rcvrInd) = 1;
    data.rcvrN          = length(data.rcvrInd);                     % number of selected receivers
end

%--- extensive parameter display ---
if flag.verbose
    if flag.dataManu==1                             % Varian
        %--- general ---
        procpar
        
        %--- b-value calculation ---
        if strncmp(procpar.seqfil,'cj_MTxSTEAM',11)
            fprintf('\n--- b-value calculation ---\n')
            fprintf('TcrushTE    = %.6f;\n',procpar.TcrushTE);
            fprintf('TcrushTM    = %.6f;\n',procpar.TcrushTM);
            fprintf('Tramp       = %.6f;\n',procpar.Tramp);
            fprintf('GcrushTE    = %.6f;\n',procpar.GcrushTE);
            fprintf('p1          = %.6f;\n',procpar.p1/1e6);
            fprintf('pw          = %.6f;\n',procpar.pw/1e6);
            fprintf('rof1        = %.6f;\n',procpar.rof1/1e6);
            fprintf('WSDuration2 = %.6f;\n',procpar.WSDuration2);
            if isfield(procpar,'TEbalance1')
                fprintf('TEbalance1  = %.6f;\n',procpar.TEbalance1);
            end
            if isfield(procpar,'TMbalance')
                fprintf('TMbalance   = %.6f;\n\n',procpar.TMbalance);
            end
        end
    elseif flag.dataManu==2                         % Bruker
%         acqp
%         method
    elseif flag.dataManu==3                         % GE
        header
%         if isfield(header,'rdb_hdr')
%             fprintf('header.rdb_hdr: \n')
%             header.rdb_hdr
%         end
%         if isfield(header,'data_acq_tab')
%             fprintf('header.data_acq_tab: \n')
%             header.data_acq_tab
%         end
%         if isfield(header,'psc')
%            fprintf('header.psc: \n')
%            header.psc
%         end
%         if isfield(header,'exam')
%            fprintf('header.exam: \n')
%            header.exam
%         end
%         if isfield(header,'series')
%            fprintf('header.series: \n')
%            header.series
%         end
%         if isfield(header,'image')
%            fprintf('header.image: \n')
%            header.image
%         end
%         if isfield(header,'grad_data')
%            fprintf('header.grad_data: \n')
%            header.grad_data
%         end
    elseif flag.dataManu==4 || flag.dataManu==6 || ...      % Siemens rda || dat || ...
           flag.dataManu==7 || flag.dataManu==8             % Philips raw || sdat 
        procpar
    end
    data
end

%--- very basic consistency check ---
if data.spec1.sw_h==0
    fprintf('\n%s ->\nZero bandwidth detected. Program aborted.\n',FCTNAME)
    return
end
if data.spec1.sf==0
    fprintf('\n%s ->\nZero Larmor frequency detected. Program aborted.\n',FCTNAME)
    return
end

%--- update 'Data' window display ---
if f_winUpdate
    SP2_Data_DataWinUpdate
end

%--- update success flag ---
f_succ = 1;
