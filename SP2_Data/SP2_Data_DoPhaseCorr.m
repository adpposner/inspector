%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_DoPhaseCorr
%% 
%%  Apply phase corrections.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag data

FCTNAME = 'SP2_Data_DoPhaseCorr';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec1,'fid')
    if ~SP2_Data_Dat1FidFileLoad
        return
    end
end
if ~isfield(data.spec2,'fid')
    if ~SP2_Data_Dat2FidFileLoad
        return
    end
end

%--- consistency checks ---
if ~flag.dataPhaseCorr
    fprintf('%s ->\nNo phase correction method selected. Program aborted.\n',FCTNAME);
    return
end
if ndims(data.spec1.fid)<ndims(data.spec2.fid)
    fprintf('%s ->\nThe data dimensions are not compatible. Program aborted.\n',FCTNAME);
    return
end
if data.spec1.nRcvrs~=data.spec2.nRcvrs
    fprintf('%s ->\nThe number of receivers does not match (%i~=%i).\nProgram aborted.\n',...
            FCTNAME,data.spec1.nRcvrs,data.spec2.nRcvrs)
    return
end
if data.spec2.nRcvrs~=size(data.spec2.fid,2)        % nRcvrs is always on the 2nd dimension
    fprintf('\n%s ->\nNumber of receivers for data set 2 does not match data size (%i~=%i).\nProgram aborted.\n',...
            FCTNAME,data.spec2.nRcvrs,size(data.spec2.fid,2))
    fprintf('(Hint: This might be due to previous data combination. Therefore, reload and try again)\n');
    return
end
% if mod(data.spec1.nr,data.spec2.nr)~=0      % experiment is not multiple of reference
%     fprintf('%s ->\nThe number of repetitions of the metabolite scan (Data 1, NR=%i)\n',FCTNAME,data.spec1.nr);
%     fprintf('is not a multiple of NR of the reference scan (Data 2, NR=%i).\nProgram aborted.\n',data.spec2.nr);
%     return
% end

%--- phase correction ---
if flag.dataPhaseCorr==1            % Klose method (phase + frequency)
    %--- consistency check ---
    if data.spec1.nspecC~=data.spec2.nspecC
        fprintf('%s ->\nThe Klose method requires equal data sizes.\n',FCTNAME);
        return
    end
    
    %--- phase (and frequency) correction ---
    if flag.dataExpType==6                              % MRSI experiment
        %--- check existence of encoding files ---
        if isempty(data.spec1.mrsi.encTableR) || ...
           isempty(data.spec1.mrsi.encTableP) || ...
           length(data.spec1.mrsi.encTableR)==1 || ...
           length(data.spec1.mrsi.encTableP)==1
            fprintf('No encoding information for data set 1 found. Check loading.\n');
            return
        end
        if isempty(data.spec2.mrsi.encTableR) || ...
           isempty(data.spec2.mrsi.encTableP) || ...
           length(data.spec2.mrsi.encTableR)==1 || ...
           length(data.spec2.mrsi.encTableP)==1
            fprintf('No encoding information for data set 2 found. Check loading.\n');
            return
        end
        
        %--- match encoding files:
        % 1) indexing with respect to reference and
        % 2) check existence 
        data.spec1.mrsi.encRefInd = 0;      % init/reset
        for encCnt = 1:data.spec1.mrsi.nEnc
            % index selection
            indVec = find(data.spec1.mrsi.encTableR(encCnt)==data.spec2.mrsi.encTableR & ...
                          data.spec1.mrsi.encTableP(encCnt)==data.spec2.mrsi.encTableP);
            if isempty(indVec)
                fprintf('%s ->\nk-space table entries #%.0f (Phase: %.0f, Read: %.0f)\ndo not have any match in the reference experiment.\n',...
                        FCTNAME,encCnt,data.spec1.mrsi.encTableR(encCnt),data.spec1.mrsi.encTableP(encCnt))
            else
                data.spec1.mrsi.encRefInd(encCnt) = indVec(1);      % first occurence
            end
                 
            % check existence
            if isempty(data.spec1.mrsi.encRefInd(encCnt))
                fprintf('Encoding step %.0f could not be found in reference scheme. Program aborted.\n',encCnt);
                return
            end
        end
        % encoding extension if applied more than once
        if data.spec1.mrsi.nEnc<data.spec1.nr       % e.g. with JDE
            %--- extension factor ---
            if mod(data.spec1.nr,data.spec1.mrsi.nEnc)==0           % exact multiple
                multFac = data.spec1.nr/data.spec1.mrsi.nEnc;       % multiplication factor, e.g. 2 for JDE
            else
                fprintf('%s ->\nNR is not a multiple of the encoding scheme. Don''t know how to proceed...\n',FCTNAME);
                return
            end
                
            if strcmp(data.spec1.seqcon(3),'s')     % standard: 1 1 2 2 ... n n
                data.spec1.mrsi.encRefInd = reshape(repmat(data.spec1.mrsi.encRefInd,[multFac 1]),1,multFac*data.spec1.mrsi.nEnc);
            else                                    % compressed: 1 2 ... n 1 2 ... n
                data.spec1.mrsi.encRefInd = repmat(data.spec1.mrsi.encRefInd,[1 multFac]);
            end
        end
                
        %--- apply Klose correction ---
        for rCnt = 1:data.spec1.nRcvrs
            for nrCnt = 1:data.spec1.nr
                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,data.spec1.mrsi.encRefInd(nrCnt))));
                phaseCorr = angle(data.spec2.fid(:,rCnt,data.spec1.mrsi.encRefInd(nrCnt)));
                data.spec1.fid(:,rCnt,nrCnt) = squeeze(data.spec1.fid(:,rCnt,nrCnt)) .* exp(-1i*phaseCorr);
            end
        end
    elseif ndims(data.spec2.fid)==2             % temporal + receivers, i.e. single repetition
        for rCnt = 1:data.spec1.nRcvrs
            % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt)));
            phaseCorr = angle(data.spec2.fid(:,rCnt));
            phaseMat  = repmat(exp(-1i*phaseCorr),[1 data.spec1.nr]);
            data.spec1.fid(:,rCnt,:) = squeeze(data.spec1.fid(:,rCnt,:)) .* phaseMat;
        end
    elseif ndims(data.spec2.fid)==3             % temporal + receivers + repetitions (e.g. phase cycle steps)
        % mode e.g. used for T1 measurements
        if data.spec1.t2Series
            for rCnt = 1:data.spec1.nRcvrs
                for nrCnt = 1:data.spec1.nr
                    % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,nrCnt)));
                    phaseCorr = angle(data.spec2.fid(:,rCnt,nrCnt));
                    data.spec1.fid(:,rCnt,nrCnt) = squeeze(data.spec1.fid(:,rCnt,nrCnt)) .* exp(-1i*phaseCorr);
                end
            end
        else
%             for rCnt = 1:data.spec1.nRcvrs
%                 for nrCnt = 1:data.spec1.nr
%                     % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1,data.nPhCycle)+1)));
%                     if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
%                         fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
%                         return
%                     else
%                         %--- info printout ---
%                         if rCnt==1          % 1st receiver only
%                             if nrCnt==1
%                                 fprintf('Phase correction NR indices: [%.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
%                             elseif nrCnt==data.spec1.nr
%                                 fprintf(' %.0f]\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
%                             else
%                                 fprintf(' %.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
%                             end
%                         end
%                     
%                         %--- extract correction phase ---
%                         phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
%                     end
%                     data.spec1.fid(:,rCnt,nrCnt) = squeeze(data.spec1.fid(:,rCnt,nrCnt)) .* exp(-1i*phaseCorr);
%                 end
%             end
            
            if flag.dataKloseMode==2        % Klose correction with individual phase cycling steps
                % data.nPhCycle = 12;
                for nrCnt = 1:data.spec1.nr
                    for rCnt = 1:data.spec1.nRcvrs
                        if ndims(data.spec2.fid)==2     % spectral + receivers, single reference for all
                            % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt)));
                            phaseCorr = angle(data.spec2.fid(:,rCnt));
                        else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
                            % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1,data.nPhCycle)+1)));
                            if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                return
                            else
                                %--- info printout ---
                                if rCnt==1          % 1st receiver only
                                    if nrCnt==1
                                        fprintf('Phase cycle: %.0f steps\n',data.nPhCycle);
                                        fprintf('Phase correction NR indices: [%.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    elseif nrCnt==data.spec1.nr
                                        fprintf(' %.0f]\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    else
                                        fprintf(' %.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    end
                                end

                                %--- extract correction phase ---
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                                phaseCorr = angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds));
                                % fprintf('%.0f\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                            end
                        end
                        phaseVec = exp(-1i*phaseCorr');
                        data.spec1.fid(:,rCnt,nrCnt) = squeeze(data.spec1.fid(:,rCnt,nrCnt)) .* phaseVec.';
                    end
                end

                %--- info printout ---
                fprintf('(Phase cycle-specific) Klose phase correction applied.\n');
            elseif flag.dataKloseMode==3            % Klose correction with selected/single reference (from arrayed experiment)
                %--- consistency check ---
                if ndims(data.spec2.fid)==2
                    fprintf('Selected reference scan is not arrayed\nand does not have multiple NR''s available (NR=1 is used).\n');
                    if data.phaseCorrNr==1
                        fprintf('... just a WARNING.\n');
                    else            % selected NR does not exist
                        return
                    end
                else
                    if data.spec2.nr<data.phaseCorrNr
                        fprintf('Selected single water reference exceeds data set dimensions (%.0f>%.0f).\nProgram aborted.\n',...
                                data.phaseCorrNr,data.spec2.nr)
                       return
                    end
                end

                %--- apply correction ---
                for nrCnt = 1:data.spec1.nr
                    for rCnt = 1:data.spec1.nRcvrs
                        if ndims(data.spec2.fid)==2     % spectral + receivers, single reference for all
                            % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt)));
                            phaseCorr = angle(data.spec2.fid(:,rCnt));
                        else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
                            if data.spec2.nr==1         % single reference
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1,data.nPhCycle)+1)));
                                if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                    fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                    return
                                else
                                    %--- info printout ---
                                    if rCnt==1          % 1st receiver only
                                        if nrCnt==1
                                            fprintf('Phase cycle: %.0f steps\n',data.nPhCycle);
                                            fprintf('Phase correction NR indices: [%.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        elseif nrCnt==data.spec1.nr
                                            fprintf(' %.0f]\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        else
                                            fprintf(' %.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        end
                                    end

                                    %--- extract correction phase ---
                                    % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                                    phaseCorr = angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds));
                                end
                            else                        % reference array (e.g. multiple JDE frequencies)
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,data.phaseCorrNr)));
                                phaseCorr = angle(data.spec2.fid(:,rCnt,data.phaseCorrNr));
                            end
                        end
                        phaseVec = exp(-1i*phaseCorr');
                        data.spec1.fid(:,rCnt,nrCnt) = squeeze(data.spec1.fid(:,rCnt,nrCnt)) .* phaseVec.';
                    end
                end

                %--- info printout ---
                fprintf('Single scan-specific Klose phase correction applied.\n');
            else
                fprintf('flag.dataKloseMode==1 is not supported. Program aborted.\n');
                return
            end
        end
        fprintf('NR-specific Klose phase correction for %.0f-step phase cycle scheme applied.\n',data.nPhCycle);
    elseif ndims(data.spec2.fid)==4             % temporal + receivers + repetitions (e.g. phase cycle steps) + nSatRec
        %--- consistency check ---
        if flag.dataExpType~=2
            fprintf('%s ->\n4-dimensional data is expected to be of type ''saturation-recovery''. Program aborted.\n',FCTNAME);
            return
        end
        
        %--- info printout ---
        fprintf('Klose correction for saturation-recovery experiment ...\n');
        
        %--- phase correction ---
        % current format: single phase cycle water reference for every 
        % sat-rec delay applied to all phase cycle steps of metabolite acquisition
        for rCnt = 1:data.spec1.nRcvrs
            for srCnt = 1:data.spec1.nSatRec
                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,1,srCnt)));
                phaseCorr = angle(data.spec2.fid(:,rCnt,1,srCnt));
                for nvCnt = 1:data.spec1.nv
                    data.spec1.fid(:,rCnt,nvCnt,srCnt) = squeeze(data.spec1.fid(:,rCnt,nvCnt,srCnt)) .* exp(-1i*phaseCorr);
                end
            end
        end
    end
else                                        % phase of first point of ref. FID (phase only)
    if ndims(data.spec2.fid)==2             % temporal + receivers, i.e. single repetition
        for rCnt = 1:data.spec1.nRcvrs
            phaseCorr = angle(data.spec2.fid(1,rCnt));
            phaseMat  = exp(-1i*phaseCorr)*ones(data.spec1.nspecC,data.spec1.nr);
            data.spec1.fid(:,rCnt,:) = squeeze(data.spec1.fid(:,rCnt,:)) .* phaseMat;
        end
    elseif ndims(data.spec2.fid)==3         % temporal + receivers + repetitions (e.g. phase cycle steps)
        for rCnt = 1:data.spec1.nRcvrs
            for nrCnt = 1:data.spec1.nr
                % phaseCorr = angle(data.spec2.fid(1,rCnt,mod(nrCnt-1,data.nPhCycle)+1));
                if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                    fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                    return
                else
                    %--- info printout ---
                    if rCnt==1          % 1st receiver only
                        if nrCnt==1
                            fprintf('Phase correction NR indices: [%.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                        elseif nrCnt==data.spec1.nr
                            fprintf(' %.0f]\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                        else
                            fprintf(' %.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                        end
                    end
                    
                    %--- extract correction phase ---
                    phaseCorr = angle(data.spec2.fid(1,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds));
                end
                data.spec1.fid(:,rCnt,nrCnt) = squeeze(data.spec1.fid(:,rCnt,nrCnt)) .* exp(-1i*phaseCorr);
            end
        end
    end
end

%--- info printout ---
fprintf('%s done.\n',FCTNAME);
    
%--- update success flag ---
f_succ = 1;
