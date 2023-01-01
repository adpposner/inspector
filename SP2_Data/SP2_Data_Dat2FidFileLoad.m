%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat2FidFileLoad(varargin)
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

global flag data procpar

FCTNAME = 'SP2_Data_Dat2FidFileLoad';


%--- init success flag ---
f_succ = 0;

%--- argument handling ---
nArg = nargin;
if nArg==0
    f_winUpdate = 1;        % default: window update
elseif nArg==1
    f_winUpdate = SP2_Check4FlagR( varargin{1} );
end

%--- retrieve/update data format ---
fprintf('\nLoading water reference (Data 2):\n')
if strcmp(data.spec2.fidDir(end-4:end-1),'.fid')                % Varian
    fprintf('Data format: Varian\n')
    flag.dataManu = 1;        
elseif strcmp(data.spec2.fidName,'fid') || strcmp(data.spec2.fidName,'fid.refscan') || ...   % Bruker
       strcmp(data.spec2.fidName,'rawdata.job0') || strcmp(data.spec2.fidName,'rawdata.job1')  
    fprintf('Data format: Bruker\n')
    flag.dataManu = 2;     
elseif strcmp(data.spec2.fidFile(end-1:end),'.7')               % GE
    fprintf('Data format: General Electric\n')
    flag.dataManu = 3;
elseif strcmp(data.spec2.fidFile(end-3:end),'.rda')             % Siemens
    fprintf('Data format: Siemens (.rda)\n')
    flag.dataManu = 4;
elseif strcmp(data.spec2.fidFile(end-3:end),'.dcm')             % DICOM (.dcm)
    fprintf('Data format: DICOM\n')
    flag.dataManu = 5;
elseif strcmp(data.spec2.fidFile(end-3:end),'.dat')             % Siemens
    fprintf('Data format: Siemens (.dat)\n')
    flag.dataManu = 6;
elseif strcmp(data.spec2.fidFile(end-3:end),'.raw')             % Philips raw
    fprintf('Data format: Philips (.raw)\n')
    flag.dataManu = 7;
elseif strcmp(data.spec2.fidFile(end-4:end),'.SDAT')            % Philips collapsed
    fprintf('Data format: Philips (.SDAT)\n')
    flag.dataManu = 8;
elseif strcmp(data.spec2.fidFile(end-3:end),'.IMA')             % DICOM (.IMA)
    fprintf('Data format: DICOM (.IMA)\n')
    flag.dataManu = 9;
end

%--- check file existence ---
if ~SP2_CheckFileExistenceR(data.spec2.fidFile)
    return
end

%--- load parameters and data ---
if flag.dataManu==1                                             % Varian
    %--- check file existence ---
    if ~SP2_CheckFileExistenceR(data.spec2.methFile)
        return
    end
        
    %--- read acqp/method parameter files ---
    [procpar,f_doneLoc] = SP2_Data_VnmrReadProcpar(data.spec2.methFile,1);
    if ~f_doneLoc
        fprintf('%s -> Data reading failed. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- read headers ---
    [procpar.dHeader,procpar.bHeader,f_read] = SP2_Data_VnmrReadHeaders(data.spec2.fidFile);
    if ~f_read
        return
    end
    
    %--- convert procpar to method structure ---
    if ~SP2_Data_ProcparConversion(procpar,2);
        fprintf('%s ->\nProcpar conversion failed. Program aborted.\n',FCTNAME)
        return
    end

    %--- read data file ---
    if flag.dataExpType==2                                  % saturation-recovery series
        [data.spec2,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
    elseif flag.dataExpType==5                              % T1/T2 series    
            [data.spec2,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec2);
            if ~f_done
                fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
                return
            end

            %--- T2 (TE) series ---
            if data.spec2.t2Series
                fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec2.t2TeExtra))
            elseif length(data.spec2.te)>1      % array
                fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec2.te))
            end        
    elseif flag.dataExpType==6                              % MRSI water reference
        %--- read data ---
        [data.spec2,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading MRSI water reference failed. Program aborted.\n',FCTNAME)
            return
        end

        %--- info printout ---
        fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec2.mrsi.fov),...
                SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),data.spec2.mrsi.nEnc)        

        %--- consistency check ---
        if any(data.spec1.mrsi.mat~=data.spec2.mrsi.mat)
            fprintf('Inconsistent MRSI matrix sizes detected %s ~= %s\n',...
                    SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),SP2_Vec2PrintStr(data.spec1.mrsi.mat,0))
    %         return
        end
        if any(data.spec1.mrsi.fov~=data.spec2.mrsi.fov)
            fprintf('Inconsistent MRSI FOV sizes detected %smm  ~= %smm\n',...
                    SP2_Vec2PrintStr(data.spec2.mrsi.fov),SP2_Vec2PrintStr(data.spec1.mrsi.fov))
    %         return
        end

        %--- read encoding tables from file ---
        [data.spec2.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec2.mrsi);
        if ~f_done
            fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
            return
        end
    elseif flag.dataExpType==7                              % JDE arrayed
        [data.spec2,f_done] = SP2_Data_VnmrReadFidArray(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
    elseif flag.dataKloseMode==3 && data.spec2.nr>1         % arrayed water reference
        %--- read data ---
        [data.spec2,f_done] = SP2_Data_VnmrReadFidNR(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading (arrayed) water reference failed. Program aborted.\n',FCTNAME)
            return
        end
    else                                                    % regular data format
        [data.spec2,f_done] = SP2_Data_VnmrReadFid(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
    end
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    
    % end of Varian
elseif flag.dataManu==2                                         % Bruker
    %--- check file existence ---
    if ~SP2_CheckFileExistence(data.spec2.acqpFile)
        return
    end
    if ~SP2_CheckFileExistence(data.spec2.methFile)
        return
    end
    
    %--- read acqp/method parameter files ---
    [acqp,f_done] = SP2_Data_PvReadAcqp(data.spec2.acqpFile);
    if ~f_done
        fprintf('%s -> Reading <acqp> file failed:\n<%s>\n',FCTNAME,data.spec2.acqpFile)
        return
    end
    [method,f_done] = SP2_Data_PvReadMethod(data.spec2.methFile);
    if ~f_done
        fprintf('%s -> Reading <method> file failed:\n<%s>\n',FCTNAME,data.spec2.methFile)
        return
    end
    
    %--- convert parameters to method structure ---
    if ~SP2_Data_PvParsConversion(method,acqp,2)
        fprintf('%s ->\nParaVision parameter conversion failed. Program aborted.\n',FCTNAME)
        return
    end
            
        %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    elseif flag.dataExpType==3              % JDE
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
                
        %--- read data file ---
        % 1: old, potential multi-dimensional <fid>, 2: new, single FID in fid file, 3: new, rawdata.job0
        if flag.dataBrukerFormat==1             % old fid
            [data.spec2.fid,f_done] = SP2_Data_PvReadOldFidJDE(data.spec2);
            if ~f_done || (length(data.spec2.fid)==1 && data.spec2.fid==0)
                fprintf('%s -> Reading (old) <fid> data file failed:\n<%s>\n',FCTNAME,data.spec2.fidFile)
                return
            end
        elseif flag.dataBrukerFormat==2         % new fid
            [data.spec2.fid,f_done] = SP2_Data_PvReadNewFidJDE(data.spec2);
            if ~f_done || (length(data.spec2.fid)==1 && data.spec2.fid==0)
                fprintf('%s -> Reading (new) <fid> data file failed:\n<%s>\n',FCTNAME,data.spec2.fidFile)
                return
            end
        else                                    % new raw data
            [data.spec2.fid,f_done] = SP2_Data_PvReadNewRawData(data.spec2);
            if ~f_done || (length(data.spec2.fid)==1 && data.spec2.fid==0)
                fprintf('%s -> Reading <rawdata.job0> data file failed:\n<%s>\n',FCTNAME,data.spec2.fidFile)
                return
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
        
    elseif flag.dataExpType==7                          % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        
    else                                                % regular data format
   
        %--- read data file ---
        % 1: old, potential multi-dimensional <fid>, 2: new, single FID in fid file, 3: new, rawdata.job0
        if flag.dataBrukerFormat==1             % old fid
            [data.spec2.fid,f_done] = SP2_Data_PvReadOldFid(data.spec2);
            if ~f_done || (length(data.spec2.fid)==1 && data.spec2.fid==0)
                fprintf('%s -> Reading (old) <fid> data file failed:\n<%s>\n',FCTNAME,data.spec2.fidFile)
                return
            end
        elseif flag.dataBrukerFormat==2         % new fid
            [data.spec2.fid,f_done] = SP2_Data_PvReadNewFid(data.spec2);
            if ~f_done || (length(data.spec2.fid)==1 && data.spec2.fid==0)
                fprintf('%s -> Reading (new) <fid> data file failed:\n<%s>\n',FCTNAME,data.spec2.fidFile)
                return
            end
        else                                    % new raw data
            [data.spec2.fid,f_done] = SP2_Data_PvReadNewRawData(data.spec2);
            if ~f_done || (length(data.spec2.fid)==1 && data.spec2.fid==0)
                fprintf('%s -> Reading <rawdata.job0> data file failed:\n<%s>\n',FCTNAME,data.spec2.fidFile)
                return
            end
        end
    end
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    
    % end of Bruker
elseif flag.dataManu==3                                         % GE
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidStability(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [header,f_done] = SP2_Data_GEReadHeader(data.spec2.fidFile);
        if ~f_done
            fprintf('%s ->\nReading GE header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_GEParsConversion(header,2)
            fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
                
        %--- data format handling ---
        if data.spec2.ne==1                 % Larry Kegeles: 1 echo, conditions in nr
            %--- read header & data from file ---
            [datFid,f_done] = SP2_Data_GEReadFid(data.spec2);
            if ~f_done
                fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            % datFid = squeeze(datFid);
            if length(size(datFid))~=3
                fprintf('%s ->\nData format does not match expected JDE MRS format. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            if data.spec2.trOffset==0               % case 1: water reference only
                % note that njde is included in nr(metab)
                % raw order: nr(water), nspecC, nRcvrs
                % new order: nspecC, nRcvrs, nr(water)
                data.spec2.fid = reshape(permute(conj(datFid),[2 3 1]),data.spec2.nspecC,...
                                         data.spec2.nRcvrs,data.spec2.nr);
            else                                    % case 2: water reference in front of metabolite data 
                % note that njde is included in nr(metab)
                % raw order: nr(water)+nr(metab), nspecC, nRcvrs
                % new order: nspecC, nRcvrs, nr(metab)
                data.spec2.nr  = data.spec2.trOffset;
                data.spec2.fid = reshape(permute(conj(datFid(1:data.spec2.trOffset,:,:)),[2 3 1]),data.spec2.nspecC,...
                                         data.spec2.nRcvrs,data.spec2.nr);
                data.spec2.nr  = size(data.spec2.fid,3);
            end
            
        elseif data.spec2.ne==2 && strcmp(data.spec2.sequence,'jpress') && strcmp(data.spec2.pp,'GE MEGA-PRESS Multisites')            % Kay/Leavitt/: 2 echoes, nr per condition
            fprintf('\n%s ->\nNon-standard data format detected: Liu Feng\n',FCTNAME)
            fprintf('Sequence: ''%s''\n',data.spec2.sequence)
            fprintf('Protocol: ''%s''\n\n',data.spec2.pp)
                    fprintf('\n%s -> WARNING:\nNon-standard data format detected.\n\n',FCTNAME)
                        
            %--- update trOffset for specific case (Feng Liu) ---
            data.spec2.trOffset = data.spec2.nr - data.spec2.nr_FL;
            
            %--- read header & data from file ---
            [datFid,f_done] = SP2_Data_GEReadFidJDE(data.spec2);
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
            if data.spec2.trOffset==0               % case 1: water reference only
                % raw order: nr(water)*njde, nspecC, nRcvrs
                % new order: nspecC, nRcvrs, nr(water)*njde                 % JDE conditions interleaved, water stripped of
                data.spec2.fid = permute(conj(datFid),[2 3 1]);
            else                                    % case 2: water reference in front of metabolite data 
                % raw order: (nr(water)+nr(metab))*njde, nspecC, nRcvrs
                % new order: nspecC, nRcvrs, nr(metab)*njde                     % JDE conditions interleaved, water stripped of
                data.spec2.nr  = data.spec2.trOffset;
                data.spec2.fid = permute(conj(datFid(1:data.spec2.trOffset,:,:)),[2 3 1]);
                data.spec2.nr  = size(data.spec2.fid,3);
            end
            
        elseif data.spec2.ne==2 && strcmp(data.spec2.sequence,'jpress')            % Kay/Leavitt/: 2 echoes, nr per condition
            fprintf('\n%s -> WARNING:\nNon-standard data format detected: Zhengchao Dong.\n',FCTNAME)
            fprintf('Sequence: ''%s''\n',data.spec2.sequence)
            fprintf('Protocol: ''%s''\n\n',data.spec2.pp)
                    
            %--- read header & data from file ---
            [datFid,f_done] = SP2_Data_GEReadFidJDE(data.spec2);
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
            if data.spec2.trOffset==0               % case 1: water reference only
                % raw order: nr(water), nspecC, nRcvrs*njde
                % new order: nspecC, nRcvrs, nr(water)*njde                 % JDE conditions interleaved, water stripped of
                data.spec2.fid = permute(conj(datFid),[2 3 1]);
            else                                    % case 2: water reference in front of metabolite data 
                % raw order: nr(water)+nr(metab), nspecC, nRcvrs*njde
                % new order: nspecC, nRcvrs, nr(water)*njde                     % JDE conditions interleaved, water stripped of
                data.spec2.nr  = data.spec2.trOffset;           % note: njde per water scan, included in trOffset
                data.spec2.fid = permute(conj(datFid(1:data.spec2.trOffset,:,:)),[2 3 1]);
                data.spec2.nr  = size(data.spec2.fid,3);
            end
            
        else               % unknown origin
            fprintf('\n%s -> WARNING:\nUNKNOWN DATA FORMAT DETECTED.\n',FCTNAME)
            fprintf('Sequence: ''%s''\n',data.spec2.sequence)
            fprintf('Protocol: ''%s''\n\n',data.spec2.pp)
                    
            %--- read header & data from file ---
            [datFid,f_done] = SP2_Data_GEReadFidJDE(data.spec2);
            if ~f_done
                fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            datFid = squeeze(datFid);
            if length(size(datFid))~=3
                fprintf('%s ->\nData format does not match expected JDE format. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data reformating ---
            if data.spec2.trOffset==0               % case 1: water reference only
                % raw order: nr(water), nspecC, nRcvrs*njde
                % new order: nspecC, nRcvrs, nr(water)*njde                 % JDE conditions interleaved, water stripped of
                data.spec2.fid = permute(conj(datFid),[2 3 1]);
            else                                    % case 2: water reference in front of metabolite data 
                % raw order: nr(water)+nr(metab), nspecC, nRcvrs*njde
                % new order: nspecC, nRcvrs, nr(water)*njde                     % JDE conditions interleaved, water stripped of
                data.spec2.nr  = data.spec2.trOffset;           % note: njde per water scan, included in trOffset
                data.spec2.fid = permute(conj(datFid(1:data.spec2.trOffset,:,:)),[2 3 1]);
                data.spec2.nr  = size(data.spec2.fid,3);
            end
        end
        
        %--- consistency check ---
        if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
            fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
            return
        end   
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec2.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec2.t2TeExtra))
%         elseif length(data.spec2.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec2.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec2.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),data.spec2.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec2.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec2.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidJDE(data.spec2);
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
        [header,f_done] = SP2_Data_GEReadHeader(data.spec2.fidFile);
        if ~f_done
            fprintf('%s ->\nReading GE header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_GEParsConversion(header,2)
            fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read header & data from file ---
        [datFid,f_done] = SP2_Data_GEReadFid(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
                
        %--- data reformating ---
%         datFid = squeeze(datFid);
        if data.spec1.nRcvrs>1              % multiple receivers
            if length(size(datFid))~=3
                fprintf('%s ->\nData format does not match expected regular MRS format. Program aborted.\n',FCTNAME)
                return
            end

            %--- metabolite extraction ---
            if data.spec2.trOffset==0               % case 1: water reference only
                % original order: nr(water), nspecC, nRcvrs
                % new order: nspecC, nRcvrs, nr(water)                  % water stripped of
                % note that data.spec2.nr is already correct and does not need to be adopted
                data.spec2.fid = reshape(permute(conj(datFid),[2 3 1]),data.spec2.nspecC,...
                                         data.spec2.nRcvrs,data.spec2.nr);
            else                                    % case 2: water reference in front of metabolite data 
                % original order: nr(water)+nr(metab), nspecC, nRcvrs
                % new order: nspecC, nRcvrs, nr(water)                  % water stripped of
                data.spec2.nr = data.spec2.trOffset;
                data.spec2.fid = reshape(permute(conj(datFid(1:data.spec2.trOffset,:,:)),[2 3 1]),data.spec2.nspecC,...
                                             data.spec2.nRcvrs,data.spec2.nr);
                data.spec2.nr  = size(data.spec2.fid,3);
            end
        else                                % single receiver
            if length(size(datFid))~=2
                fprintf('%s ->\nData format does not match expected regular MRS format. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- metabolite extraction ---
            if data.spec2.trOffset==0               % case 1: water reference only
                % original order: nr(water), nspecC, nRcvrs
                % new order: nspecC, nRcvrs, nr(water)                  % water stripped of
                % note that data.spec2.nr is already correct and does not need to be adopted
                data.spec2.fid = reshape(permute(conj(datFid),[2 3 1]),data.spec2.nspecC,...
                                         data.spec2.nRcvrs,data.spec2.nr);
            else                                    % case 2: water reference in front of metabolite data 
                % original order: nr(water)+nr(metab), nspecC, nRcvrs
                % new order: nspecC, nRcvrs, nr(water)                  % water stripped of
                data.spec2.nr = data.spec2.trOffset;
                data.spec2.fid = reshape(permute(conj(datFid(1:data.spec2.trOffset,:)),[2 1]),...
                                         data.spec2.nspecC,data.spec2.nr);
                data.spec2.nr  = size(data.spec2.fid,2);
            end
        end
    end
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    
    %--- frequency display ---
    fprintf('Frequency: %.6f MHz\n',data.spec2.sf)
    % end of GE

elseif flag.dataManu==4                                         % Siemens .rda
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidStability(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_SiemensRdaReadHeader(data.spec2.fidFile);
        if ~f_done
            fprintf('%s ->\nReading Siemens header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec2,f_done] = SP2_Data_SiemensRdaReadFid(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading Siemens data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_SiemensRdaParsConversion(procpar,2)
            fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
%         %--- read header & data from file ---
%         [raw,header,ec,f_done] = SP2_Data_SiemensRdaReadFid(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- convert parameters to method structure ---
%         if ~SP2_Data_SiemensRdaParsConversion(header,2);
%             fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- data reformating ---
%         datFidTmp = squeeze(raw);
%         % raw order: nr, nspecC, nRcvrs
%         % new order: nspecC, nRcvrs, nr
%         % data.spec2.fid = permute(conj(datFidTmp(9:end,:,:)),[2 3 1]);
%         data.spec2.nr  = data.spec2.nr - 8;
%         data.spec2.fid = reshape(permute(conj(datFidTmp(9:end,:,:,:)),[2 4 3 1]),data.spec2.nspecC,...
%                                  data.spec2.nRcvrs,data.spec2.nr*data.spec2.njde);
%         data.spec2.nr  = size(data.spec2.fid,3);
%         
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end                
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec2.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec2.t2TeExtra))
%         elseif length(data.spec2.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec2.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec2.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),data.spec2.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec2.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec2.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidJDE(data.spec2);
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
        [procpar,f_done] = SP2_Data_SiemensRdaReadHeader(data.spec2.fidFile);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec2,f_done] = SP2_Data_SiemensRdaReadFid(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_SiemensRdaParsConversion(procpar,2)
            fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
    end
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    % end of Siemens .rda
    
elseif flag.dataManu==5                                         % DICOM (.dcm)
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidStability(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- read header & data from file ---
%         [raw,header,ec,f_done] = SP2_Data_GEReadFid(data.spec2);
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
%         % data.spec2.fid = permute(conj(datFidTmp(9:end,:,:)),[2 3 1]);
%         data.spec2.nr  = data.spec2.nr - 8;
%         data.spec2.fid = reshape(permute(conj(datFidTmp(9:end,:,:,:)),[2 4 3 1]),data.spec2.nspecC,...
%                                  data.spec2.nRcvrs,data.spec2.nr*data.spec2.njde);
%         data.spec2.nr  = size(data.spec2.fid,3);
%         
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end                
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec2.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec2.t2TeExtra))
%         elseif length(data.spec2.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec2.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec2.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),data.spec2.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec2.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec2.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidJDE(data.spec2);
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
        [procpar,f_done] = SP2_Data_DicomImaReadHeader(data.spec2.fidFile);
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
            [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec2.fidFile);
            if ~f_done
                fprintf('%s ->\nReading Siemens DICOM (dcm) header from file failed. Program aborted.\n',FCTNAME)
                return
            end

            %--- convert parameters to method structure ---
            if ~SP2_Data_SiemensDatParsConversion(procpar,2)
                fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
                return
            end
            
            % DICOMs contain single FIDs only, i.e. while a multi-Rx system might
            % have been used, this is not prepresented in the data anymore.
            % To this end, a potential nRcvrs>1 entry is reduced to 1 here   
            if data.spec2.nRcvrs == 0
                data.spec2.nRcvrs = 1;
            elseif data.spec2.nRcvrs > 1
                fprintf('Note: # of receivers adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                        data.spec2.nRcvrs)
                data.spec2.nRcvrs = 1;
            end
            if data.spec2.nr > 1
                fprintf('Note: # of repetitions adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                        data.spec2.nr)
                data.spec2.nr = 1;
            end
            
            %--- somewhat ugly: read dicom header again with standard DICOM reader ---
            [procpar,f_done] = SP2_Data_DicomReadHeader(data.spec2.fidFile);
            if ~f_done
                fprintf('%s ->\nReading DICOM (dcm) header failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- assign further parameters ---
            if isfield(procpar,'SoftwareVersion') && strcmp(data.spec2.software,'')
                data.spec2.software = procpar.SoftwareVersion;
            end
            if isfield(procpar,'SoftwareVersion') && strcmp(data.spec2.softGeneration,'')
                if any(strfind(procpar.SoftwareVersion,'MR B'))
                    data.spec2.softGeneration = 'VB';
                elseif any(strfind(procpar.SoftwareVersion,'MR D'))
                    data.spec2.softGeneration = 'VD';
                elseif any(strfind(procpar.SoftwareVersion,'MR E'))
                    data.spec2.softGeneration = 'VE';
                end
            end
            if isfield(procpar,'InstitutionName') && strcmp(data.spec2.institution,'')
                data.spec2.institution = procpar.InstitutionName;
            end
            if isfield(procpar,'PatientName') && strcmp(data.spec2.patient,'')
                data.spec2.patient = procpar.PatientName;
            end
            if isfield(procpar,'StudyDescription') && strcmp(data.spec2.study,'')
                data.spec2.study = procpar.StudyDescription;
            end
            if isfield(procpar,'SequenceName') && strcmp(data.spec2.sequence,'')
                data.spec2.sequence = procpar.SequenceName;
            end
        else
           fprintf('%s ->\nDICOM (dcm) format only supported for Siemens data.\n',FCTNAME)
           return
        end
        
        %--- read data from file ---
        % note: IMA reading function even if dcm file format
        [data.spec2,f_done] = SP2_Data_DicomImaReadFid(data.spec2);
        if f_done
            fprintf('%s ->\nDICOM (dcm) data read from file.\n',FCTNAME)
        else
            fprintf('%s ->\nReading data from DICOM file failed. Program aborted.\n',FCTNAME)
            return
        end
    
    end         % end of regular
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    % end of DICOM
    % end of DICOM
    
elseif flag.dataManu==6                                         % Siemens .dat
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidStability(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec2.fidFile);
        if ~f_done
            fprintf('%s ->\nReading Siemens header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_SiemensDatParsConversion(procpar,2)
            fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- JDE ---
        data.spec2.njde = 2;
        
        %--- read data from file ---
        [data.spec2,f_done] = SP2_Data_SiemensDatReadFidJDE(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading Siemens JDE data file failed. Program aborted.\n',FCTNAME)
            return
        end
            
        %--- consistency check ---
        % nspecC, nRcvrs, nr
        if length(size(data.spec2.fid))~=3 && data.spec2.nr>1
            fprintf('%s ->\nData format does not match expected JDE MRS format.\n',FCTNAME)
            fprintf('size(data.spec2.fid) = %s\n',SP2_Vec2PrintStr(size(data.spec2.fid),0,1))
            fprintf('Program aborted.\n')
            return
        end    
                
        %--- water extraction ---
        % original order: nspecC, nRcvrs, nr(water)+nr(ON/OFF)
        % new order: nspecC, nRcvrs, nr(water)                  % metabolites stripped of
        if data.spec2.trOffset>0
            data.spec2.nr  = data.spec2.trOffset;               % =1
            data.spec2.fid = data.spec2.fid(:,:,1:data.spec2.nr);
            % data.spec2.nr  = size(data.spec2.fid,3);
        end
        
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec2.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec2.t2TeExtra))
%         elseif length(data.spec2.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec2.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec2.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),data.spec2.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec2.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec2.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidJDE(data.spec2);
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
        [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec2.fidFile);
        if ~f_done
            fprintf('%s ->\nReading Siemens header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_SiemensDatParsConversion(procpar,2)
            fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec2,f_done] = SP2_Data_SiemensDatReadFid(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading Siemens data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- consistency check ---
        % expected format: nspecC, nRcvrs, not included: nr=1
        if length(size(data.spec2.fid))~=2 && data.spec2.nr==1
            fprintf('%s ->\nData format does not match expected regular MRS format.\n',FCTNAME)
            fprintf('size(data.spec2.fid) = %s, nr = 1\n',SP2_Vec2PrintStr(size(data.spec2.fid),0,1))
            fprintf('Program aborted.\n')
            return
        end
        % expected format: nspecC, nRcvrs, nr
        if length(size(data.spec2.fid))~=3 && data.spec2.nr>1
            fprintf('%s ->\nData format does not match expected regular MRS format.\n',FCTNAME)
            fprintf('size(data.spec2.fid) = %s\n',SP2_Vec2PrintStr(size(data.spec2.fid),0,1))
            fprintf('Program aborted.\n')
            return
        end
        
        %--- water extraction ---
        % original order: nspecC, nRcvrs, nr(water)+nr(metab)
        % new order: nspecC, nRcvrs, nr(water)                  % metabolites stripped of
        if data.spec2.trOffset>0
            data.spec2.nr  = data.spec2.trOffset;               % =1
            data.spec2.fid = data.spec2.fid(:,:,1:data.spec2.nr);
            % data.spec2.nr  = size(data.spec2.fid,3);
        end
    end
    
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    % end of Siemens .dat

elseif flag.dataManu==7                                         % Philips .raw
    %--- check file existence ---
    if ~SP2_CheckFileExistence(data.spec2.acqpFile)
        return
    end
    if ~SP2_CheckFileExistence(data.spec2.methFile)
        return
    end
    
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidStability(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_PhilipsRawReadSinLabFiles(data.spec2.methFile,data.spec2.acqpFile);
        if ~f_done
            fprintf('%s ->\nReading Philips parameters from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_PhilipsRawParsConversion(procpar,2)
            fprintf('%s ->\nPhilips parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [datFid,f_done] = SP2_Data_PhilipsRawReadFid(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading Philips data file failed. Program aborted.\n',FCTNAME)
            return
        end
                
        %--- data reformating ---
        if length(size(datFid))~=3
            fprintf('%s ->\nData format does not match expected regular MRS format. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- metabolite extraction ---
        if data.spec2.trOffset==0               % case 1: water reference only
            % overall order remains unchanged: nspecC, nRcvrs, nr
            % raw order: nspecC, nRcvrs, nr(water)
            % new order: nspecC, nRcvrs, nr(water)
            data.spec2.fid = datFid;
        else                                    % case 2: water reference in front of metabolite data 
            % overall order remains unchanged: nspecC, nRcvrs, nr
            % raw order: nspecC, nRcvrs, nr(water)+nr(metab)
            % new order: nspecC, nRcvrs, nr(water)
            data.spec2.fid = datFid(:,:,1:data.spec2.trOffset);
            data.spec2.nr  = size(data.spec2.fid,3);    % = data.spec2.trOffset
        end
    
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec2.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec2.t2TeExtra))
%         elseif length(data.spec2.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec2.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec2.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),data.spec2.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec2.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec2.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidJDE(data.spec2);
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
        [procpar,f_done] = SP2_Data_PhilipsRawReadSinLabFiles(data.spec2.methFile,data.spec2.acqpFile);
        if ~f_done
            fprintf('%s ->\nReading Philips parameters from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_PhilipsRawParsConversion(procpar,2)
            fprintf('%s ->\nPhilips parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [datFid,f_done] = SP2_Data_PhilipsRawReadFid(data.spec2);
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
        if data.spec2.trOffset==0               % case 1: water reference only
            % overall order remains unchanged: nspecC, nRcvrs, nr
            % raw order: nspecC, nRcvrs, nr(water)
            % new order: nspecC, nRcvrs, nr(water)
            data.spec2.fid = datFid;
        else                                    % case 2: water reference in front of metabolite data 
            % overall order remains unchanged: nspecC, nRcvrs, nr
            % raw order: nspecC, nRcvrs, nr(water)+nr(metab)
            % new order: nspecC, nRcvrs, nr(water)
            data.spec2.fid = datFid(:,:,1:data.spec2.trOffset);
            data.spec2.nr  = size(data.spec2.fid,3);    % = data.spec2.trOffset
        end
    end
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    % end of Philips .raw

elseif flag.dataManu==8                                         % Philips .SDAT
    %--- check file existence ---
    if ~SP2_CheckFileExistence(data.spec2.methFile)
        return
    end
    
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidStability(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %--- read header from file ---
        [procpar,f_done] = SP2_Data_PhilipsSdatReadHeader(data.spec2.fidFile);
        if ~f_done
            fprintf('%s ->\nReading Philips header from file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_PhilipsSdatParsConversion(procpar,2)
            fprintf('%s ->\nPhilips parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec2,f_done] = SP2_Data_PhilipsSdatReadFid(data.spec2);
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

%         data.spec1.njde = 2;

%         %--- consistency check ---
%         if data.spec1.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end     
    
    
    
    
    
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec2.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec2.t2TeExtra))
%         elseif length(data.spec2.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec2.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec2.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),data.spec2.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec2.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec2.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidJDE(data.spec2);
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
        [procpar,f_done] = SP2_Data_PhilipsSdatReadSparFile(data.spec2.methFile);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- convert parameters to method structure ---
        if ~SP2_Data_PhilipsSdatParsConversion(procpar,2)
            fprintf('%s ->\nGE parameter conversion failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        [data.spec2,f_done] = SP2_Data_PhilipsSdatReadFid(data.spec2);
        if ~f_done
            fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
            return
        end
    end
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    % end of Philips .SDAT
    
elseif flag.dataManu==9                                         % DICOM .IMA
    %--- read data file ---
    if flag.dataExpType==4                  % data format for stability analysis
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidStability(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading of stability data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==3              % JDE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %--- serial file handling ---
        allNames = SP2_GetAllFiles(data.spec1.fidDir);
        imaNames = {};
        imaCnt   = 0;
        for aCnt = 1:length(allNames)
            if strcmp(allNames{aCnt}(end-3:end),'.IMA')
                imaCnt = imaCnt + 1;
                imaNames{imaCnt} = allNames{aCnt};
                if ispc
                    ind = find(imaNames{imaCnt},'\');
                else
                    ind = find(imaNames{imaCnt},'/');
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
            %--- info printout ---
            if mod(iCnt,10)==0
                fprintf('%.0f (of %.0f) individual DICOM files loaded...\n',iCnt,nSpecFiles)
            end
            
            %--- parameter handling ---
            if iCnt==1            % first slice of magnitude
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
                    if data.spec1.nRcvrs > 1
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
                    data.spec1.fid  = complex(zeros(data.spec1.nspecC,data.spec1.nr));
                else
                   fprintf('%s ->\nDICOM format only supported for Siemens data.\n',FCTNAME)
                   return
                end
            end
            
            %--- read data ---
            [data.spec1,f_done] = SP2_Data_DicomImaReadFid(data.spec1);
            if f_done
                fprintf('Reading completed.\n')
            else
                fprintf('%s ->\nReading data from DICOM file failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- data assignment ---
            % order remains unchanged: nspecC, nRcvrs, nr(metab)                  
            data.spec1.fid(:,iCnt) = data.spec1.fid;
        end
        
    elseif flag.dataExpType==2                          % saturation-recovery series
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidSatRec(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
    elseif flag.dataExpType==5                          % T1/T2 series    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidT1T2(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- T2 (TE) series ---
%         if data.spec2.t2Series
%             fprintf('TE extension: %sms\n',SP2_Vec2PrintStr(data.spec2.t2TeExtra))
%         elseif length(data.spec2.te)>1      % array
%             fprintf('TE array: %sms\n',SP2_Vec2PrintStr(data.spec2.te))
%         end        
    elseif flag.dataExpType==6                          % MRSI    
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidMRSI(data.spec2);
%         if ~f_done
%             fprintf('%s ->\nReading MRSI data file failed. Program aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- info printout ---
%         fprintf('MRSI geometry: FOV %s mm, matrix %s, %.0f-step encoding\n',SP2_Vec2PrintStr(data.spec2.mrsi.fov),...
%                 SP2_Vec2PrintStr(data.spec2.mrsi.mat,0),data.spec2.mrsi.nEnc)   
%             
%         %--- read encoding tables from file ---
%         [data.spec2.mrsi,f_done] = SP2_Data_MrsiReadEncTable(data.spec2.mrsi);
%         if ~f_done
%             fprintf('Reading MRSI encoding table from file failed. Program aborted.\n')
%             return
%         end 
    elseif flag.dataExpType==7              % JDE - array
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
%         %--- consistency check ---
%         if data.spec2.njde<3 && flag.dataEditNo==2      % single edit, 2nd edit selected
%             fprintf('%s ->\nSelection of the 2nd editing condition requires\nan interleaved multi-edit experiment (which it isn''t).\nProgram aborted.\n',FCTNAME)
%             return
%         end
%         
%         %--- read data ---
%         [data.spec2,f_done] = SP2_Data_VnmrReadFidJDE(data.spec2);
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
        [procpar,f_done] = SP2_Data_DicomImaReadHeader(data.spec2.fidFile);
        if ~f_done
            fprintf('%s ->\nReading DICOM header failed. Program aborted.\n',FCTNAME)
            return
        end
        
        %--- read data from file ---
        if strcmp(procpar.Manufacturer,'SIEMENS') || ...
           strcmp(procpar.Manufacturer,'Siemens')
           %--- read header from file ---
            [procpar,f_done] = SP2_Data_SiemensDatReadHeader(data.spec2.fidFile);
            if ~f_done
                fprintf('%s ->\nReading Siemens DICOM header from file failed. Program aborted.\n',FCTNAME)
                return
            end

            %--- convert parameters to method structure ---
            if ~SP2_Data_SiemensDatParsConversion(procpar,2)
                fprintf('%s ->\nSiemens parameter conversion failed. Program aborted.\n',FCTNAME)
                return
            end
            
            % DICOMs contain single FIDs only, i.e. while a multi-Rx system might
            % have been used, this is not prepresented in the data anymore.
            % To this end, a potential nRcvrs>1 entry is reduced to 1 here   
            if data.spec2.nRcvrs == 0
                data.spec2.nRcvrs = 1;
            elseif data.spec2.nRcvrs > 1
                fprintf('Note: # of receivers adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                        data.spec2.nRcvrs)
                data.spec2.nRcvrs = 1;
            end
            if data.spec2.nr > 1
                fprintf('Note: # of repetitions adapted from %.0f (experiment) to 1 (DICOM data size).\n',...
                        data.spec2.nr)
                data.spec2.nr = 1;
            end
            
            %--- somewhat ugly: read dicom header again with standard DICOM reader ---
            [procpar,f_done] = SP2_Data_DicomReadHeader(data.spec2.fidFile);
            if ~f_done
                fprintf('%s ->\nReading DICOM header failed. Program aborted.\n',FCTNAME)
                return
            end
            
            %--- assign further parameters ---
            if isfield(procpar,'SoftwareVersion') && strcmp(data.spec2.software,'')
                data.spec2.software = procpar.SoftwareVersion;
            end
            if isfield(procpar,'SoftwareVersion') && strcmp(data.spec2.softGeneration,'')
                if any(strfind(procpar.SoftwareVersion,'MR B'))
                    data.spec2.softGeneration = 'VB';
                elseif any(strfind(procpar.SoftwareVersion,'MR D'))
                    data.spec2.softGeneration = 'VD';
                elseif any(strfind(procpar.SoftwareVersion,'MR E'))
                    data.spec2.softGeneration = 'VE';
                end
            end
            if isfield(procpar,'InstitutionName') && strcmp(data.spec2.institution,'')
                data.spec2.institution = procpar.InstitutionName;
            end
            if isfield(procpar,'PatientName') && strcmp(data.spec2.patient,'')
                data.spec2.patient = procpar.PatientName;
            end
            if isfield(procpar,'StudyDescription') && strcmp(data.spec2.study,'')
                data.spec2.study = procpar.StudyDescription;
            end
            if isfield(procpar,'SequenceName') && strcmp(data.spec2.sequence,'')
                data.spec2.sequence = procpar.SequenceName;
            end
        else
           fprintf('%s ->\nDICOM format only supported for Siemens data.\n',FCTNAME)
           return
        end
        
        [data.spec2,f_done] = SP2_Data_DicomImaReadFid(data.spec2);
        if f_done
            fprintf('Reading completed.\n')
        else
            fprintf('%s ->\nReading data from DICOM file failed. Program aborted.\n',FCTNAME)
            return
        end
    end
    
    %--- dimension handling ---
    data.spec2.dim = length(size(data.spec2.fid));
    % end of DICOM .IMA

else
    fprintf('%s ->\nData format not valid. File assignment aborted.\n',FCTNAME)
    return
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
        acqp
        method
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
if data.spec2.sw_h==0
    fprintf('\n%s ->\nZero bandwidth detected. Program aborted.\n',FCTNAME)
    return
end
if data.spec2.sf==0
    fprintf('\n%s ->\nZero Larmor frequency detected. Program aborted.\n',FCTNAME)
    return
end

%--- update success flag ---
f_succ = 1;

%--- update 'Data' window display ---
if f_winUpdate
    SP2_Data_DataWinUpdate
end
