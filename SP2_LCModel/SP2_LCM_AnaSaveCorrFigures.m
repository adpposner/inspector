%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaSaveCorrFigures
%% 
%%  Save correlation matrices to file.
%%
%%  05-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_AnaSaveCorrFigures';


%--- init success flag ---
f_succ = 0;

%--- check directory access ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    fprintf('Directory for export of correlation matrices is not accessible. Program aborted.\n')
    return
end

%--- check figure existence ---
f_fhCorrCompl = 0;
f_fhCorrAmp   = 0;
f_fhCorrLb    = 0;
f_fhCorrGb    = 0;
f_fhCorrShift = 0;
if isfield(lcm,'fhCorrCompl')
    if ishandle(lcm.fhCorrCompl)
        f_fhCorrCompl = 1;
    end
end
if isfield(lcm,'fhCorrAmp')
    if ishandle(lcm.fhCorrAmp)
        f_fhCorrAmp = 1;
    end
end
if isfield(lcm,'fhCorrLb')
    if ishandle(lcm.fhCorrLb)
        f_fhCorrLb = 1;
    end
end
if isfield(lcm,'fhCorrGb')
    if ishandle(lcm.fhCorrGb)
        f_fhCorrGb = 1;
    end
end
if isfield(lcm,'fhCorrShift')
    if ishandle(lcm.fhCorrShift)
        f_fhCorrShift = 1;
    end
end

%--- (re)create correlation figures ---
flagVerbose = flag.verbose;     % keep original setting
flag.verbose = 1;               % needed for figure creation
if ~SP2_LCM_AnaDoCalcCRLB_Individual(1)    % create correlation matrices
    return
end
flag.verbose = flagVerbose;     % restore original setting

%--- complete correlation matrix ---
if isfield(lcm,'fhCorrCompl')
    if ishandle(lcm.fhCorrCompl)
        corrComplFigPath = [lcm.expt.dataDir 'SPX_LcmCorrComplete.fig'];
        saveas(lcm.fhCorrCompl,corrComplFigPath,'fig');
                    
        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            corrComplJpgPath = [lcm.expt.dataDir 'SPX_LcmCorrComplete.jpg'];
            saveas(lcm.fhCorrCompl,corrComplJpgPath,'jpg');
            fprintf('Complete correlation matrix saved to file:\n%s\n%s\n',...
                    corrComplFigPath,corrComplJpgPath);
        else
            fprintf('Complete correlation matrix saved to file:\n%s\n',corrComplFigPath);
        end
    end
end

%--- amplitude correlation matrix ---
if isfield(lcm,'fhCorrAmp')
    if ishandle(lcm.fhCorrAmp)
        corrAmpFigPath = [lcm.expt.dataDir 'SPX_LcmCorrAmp.fig'];
        saveas(lcm.fhCorrAmp,corrAmpFigPath,'fig');
                    
        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            corrAmpJpgPath = [lcm.expt.dataDir 'SPX_LcmCorrAmp.jpg'];
            saveas(lcm.fhCorrAmp,corrAmpJpgPath,'jpg');
            fprintf('Amplitude correlation matrix saved to files:\n%s\n%s\n',...
                    corrAmpFigPath,corrAmpJpgPath);
        else
            fprintf('Amplitude correlation matrix saved to file:\n%s\n',corrAmpFigPath);
        end
    end
end

%--- exponential line broadening (LB) correlation matrix ---
if isfield(lcm,'fhCorrLb')
    if ishandle(lcm.fhCorrLb)
        corrLbFigPath = [lcm.expt.dataDir 'SPX_LcmCorrLb.fig'];
        saveas(lcm.fhCorrLb,corrLbFigPath,'fig');
                    
        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            corrLbJpgPath = [lcm.expt.dataDir 'SPX_LcmCorrLb.jpg'];
            saveas(lcm.fhCorrLb,corrLbJpgPath,'jpg');
            fprintf('Correlation matrix of exponential linebroadening saved to files:\n%s\n%s\n',...
                    corrLbFigPath,corrLbJpgPath);
        else
            fprintf('Correlation matrix of exponential linebroadening saved to file:\n%s\n',corrLbFigPath);
        end
    end
end

%--- Gaussian line broadening (GB) correlation matrix ---
if isfield(lcm,'fhCorrGb')
    if ishandle(lcm.fhCorrGb)
        corrGbFigPath = [lcm.expt.dataDir 'SPX_LcmCorrGb.fig'];
        saveas(lcm.fhCorrGb,corrGbFigPath,'fig');
                    
        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            corrGbJpgPath = [lcm.expt.dataDir 'SPX_LcmCorrGb.jpg'];
            saveas(lcm.fhCorrGb,corrGbJpgPath,'jpg');
            fprintf('Correlation matrix of Gaussian linebroadening saved to files:\n%s\n%s\n',...
                    corrGbFigPath,corrGbJpgPath);
        else
            fprintf('Correlation matrix of Gaussian linebroadening saved to file:\n%s\n',corrGbFigPath);
        end
    end
end

%--- shift correlation matrix ---
if isfield(lcm,'fhCorrShift')
    if ishandle(lcm.fhCorrShift)
        corrShiftFigPath = [lcm.expt.dataDir 'SPX_LcmCorrShift.fig'];
        saveas(lcm.fhCorrShift,corrShiftFigPath,'fig');
                    
        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            corrShiftJpgPath = [lcm.expt.dataDir 'SPX_LcmCorrShift.jpg'];
            saveas(lcm.fhCorrShift,corrShiftJpgPath,'jpg');
            fprintf('Correlation matrix of frequency shifts saved to files:\n%s\n%s\n',...
                    corrShiftFigPath,corrShiftJpgPath);
        else
            fprintf('Correlation matrix of frequency shifts saved to file:\n%s\n',corrShiftFigPath);
        end
    end
end


%--- remove figures that have not existed beforehand ---
if ~f_fhCorrCompl && isfield(lcm,'fhCorrCompl')
    if ishandle(lcm.fhCorrCompl)
        delete(lcm.fhCorrCompl)
    end
    lcm = rmfield(lcm,'fhCorrCompl');
end
if ~f_fhCorrAmp && isfield(lcm,'fhCorrAmp')
    if ishandle(lcm.fhCorrAmp)
        delete(lcm.fhCorrAmp)
    end
    lcm = rmfield(lcm,'fhCorrAmp');
end
if ~f_fhCorrLb && isfield(lcm,'fhCorrLb')
    if ishandle(lcm.fhCorrLb)
        delete(lcm.fhCorrLb)
    end
    lcm = rmfield(lcm,'fhCorrLb');
end
if ~f_fhCorrGb && isfield(lcm,'fhCorrGb')
    if ishandle(lcm.fhCorrGb)
        delete(lcm.fhCorrGb)
    end
    lcm = rmfield(lcm,'fhCorrGb');
end
if ~f_fhCorrShift && isfield(lcm,'fhCorrShift')
    if ishandle(lcm.fhCorrShift)
        delete(lcm.fhCorrShift)
    end
    lcm = rmfield(lcm,'fhCorrShift');
end
if isfield(lcm,'fhFisher')
    if ishandle(lcm.fhFisher)
        delete(lcm.fhFisher)
    end
    lcm = rmfield(lcm,'fhFisher');
end


%--- metabolite combinations ---
if flag.lcmComb1 || flag.lcmComb2 || flag.lcmComb3
    %--- check figure existence ---
    f_fhCombCorrCompl = 0;
    f_fhCombCorrAmp   = 0;
    f_fhCombCorrLb    = 0;
    f_fhCombCorrGb    = 0;
    f_fhCombCorrShift = 0;
    if isfield(lcm,'fhCombCorrCompl')
        if ishandle(lcm.fhCombCorrCompl)
            f_fhCombCorrCompl = 1;
        end
    end
    if isfield(lcm,'fhCombCorrAmp')
        if ishandle(lcm.fhCombCorrAmp)
            f_fhCombCorrAmp = 1;
        end
    end
    if isfield(lcm,'fhCombCorrLb')
        if ishandle(lcm.fhCombCorrLb)
            f_fhCombCorrLb = 1;
        end
    end
    if isfield(lcm,'fhCombCorrGb')
        if ishandle(lcm.fhCombCorrGb)
            f_fhCombCorrGb = 1;
        end
    end
    if isfield(lcm,'fhCombCorrShift')
        if ishandle(lcm.fhCombCorrShift)
            f_fhCombCorrShift = 1;
        end
    end

    %--- (re)create correlation figures ---
    flagVerbose = flag.verbose;     % keep original setting
    flag.verbose = 1;               % needed for figure creation
    if ~SP2_LCM_AnaDoCalcCRLB_Combined(1)    % create correlation matrices
        return
    end
    flag.verbose = flagVerbose;     % restore original setting

%     %--- complete correlation matrix ---
%     if isfield(lcm,'fhCombCorrCompl')
%         if ishandle(lcm.fhCombCorrCompl)
%             corrComplFigPath = [lcm.expt.dataDir 'SPX_LcmCorrComplete.fig'];
%             saveas(lcm.fhCombCorrCompl,corrComplFigPath,'fig');
%             fprintf('Complete correlation matrix saved to file:\n%s\n',corrComplFigPath);
%         end
%     end

    %--- amplitude correlation matrix ---
    if isfield(lcm,'fhCombCorrAmp')
        if ishandle(lcm.fhCombCorrAmp)
            corrAmpFigPath = [lcm.expt.dataDir 'SPX_LcmCombCorrAmp.fig'];
            saveas(lcm.fhCombCorrAmp,corrAmpFigPath,'fig');
                        
            %--- save as jpeg ---
            if flag.lcmSaveJpeg
                corrAmpJpgPath = [lcm.expt.dataDir 'SPX_LcmCombCorrAmp.jpg'];
                saveas(lcm.fhCombCorrAmp,corrAmpJpgPath,'jpg');
                fprintf('Amplitude correlation matrix saved to files:\n%s\n%s\n',...
                        corrAmpFigPath,corrAmpJpgPath);
            else
                fprintf('Amplitude correlation matrix saved to file:\n%s\n',corrAmpFigPath);
            end
        end
    end

    %--- exponential line broadening (LB) correlation matrix ---
    if isfield(lcm,'fhCombCorrLb')
        if ishandle(lcm.fhCombCorrLb)
            corrLbFigPath = [lcm.expt.dataDir 'SPX_LcmCombCorrLb.fig'];
            saveas(lcm.fhCombCorrLb,corrLbFigPath,'fig');
                        
            %--- save as jpeg ---
            if flag.lcmSaveJpeg
                corrLbJpgPath = [lcm.expt.dataDir 'SPX_LcmCombCorrLb.jpg'];
                saveas(lcm.fhCombCorrLb,corrLbJpgPath,'jpg');
                fprintf('Correlation matrix of exponential linebroadening saved to files:\n%s\n%s\n',...
                        corrLbFigPath,corrLbJpgPath);
            else
                fprintf('Correlation matrix of exponential linebroadening saved to file:\n%s\n',corrLbFigPath);
            end
        end
    end

    %--- Gaussian line broadening (GB) correlation matrix ---
    if isfield(lcm,'fhCombCorrGb')
        if ishandle(lcm.fhCombCorrGb)
            corrGbFigPath = [lcm.expt.dataDir 'SPX_LcmCombCorrGb.fig'];
            saveas(lcm.fhCombCorrGb,corrGbFigPath,'fig');
                        
            %--- save as jpeg ---
            if flag.lcmSaveJpeg
                corrGbJpgPath = [lcm.expt.dataDir 'SPX_LcmCombCorrGb.jpg'];
                saveas(lcm.fhCombCorrGb,corrGbJpgPath,'jpg');
                fprintf('Correlation matrix of Gaussian linebroadening saved to files:\n%s\n%s\n',...
                        corrGbFigPath,corrGbJpgPath);
            else
                fprintf('Correlation matrix of Gaussian linebroadening saved to file:\n%s\n',corrGbFigPath);
            end
        end
    end

    %--- shift correlation matrix ---
    if isfield(lcm,'fhCombCorrShift')
        if ishandle(lcm.fhCombCorrShift)
            corrShiftFigPath = [lcm.expt.dataDir 'SPX_LcmCombCorrShift.fig'];
            saveas(lcm.fhCombCorrShift,corrShiftFigPath,'fig');
            
            %--- save as jpeg ---
            if flag.lcmSaveJpeg
                corrShiftJpgPath = [lcm.expt.dataDir 'SPX_LcmCombCorrShift.jpg'];
                saveas(lcm.fhCombCorrShift,corrShiftJpgPath,'jpg');
                fprintf('Correlation matrix of frequency shifts saved to files:\n%s\n%s\n',...
                        corrShiftFigPath,corrShiftJpgPath);
            else
                fprintf('Correlation matrix of frequency shifts saved to file:\n%s\n',corrShiftFigPath);
            end
        end
    end

    %--- remove figures that have not existed beforehand ---
    if ~f_fhCombCorrCompl && isfield(lcm,'fhCombCorrCompl')
        if ishandle(lcm.fhCombCorrCompl)
            delete(lcm.fhCombCorrCompl)
        end
        lcm = rmfield(lcm,'fhCombCorrCompl');
    end
    if ~f_fhCombCorrAmp && isfield(lcm,'fhCombCorrAmp')
        if ishandle(lcm.fhCombCorrAmp)
            delete(lcm.fhCombCorrAmp)
        end
        lcm = rmfield(lcm,'fhCombCorrAmp');
    end
    if ~f_fhCombCorrLb && isfield(lcm,'fhCombCorrLb')
        if ishandle(lcm.fhCombCorrLb)
            delete(lcm.fhCombCorrLb)
        end
        lcm = rmfield(lcm,'fhCombCorrLb');
    end
    if ~f_fhCombCorrGb && isfield(lcm,'fhCombCorrGb')
        if ishandle(lcm.fhCombCorrGb)
            delete(lcm.fhCombCorrGb)
        end
        lcm = rmfield(lcm,'fhCombCorrGb');
    end
    if ~f_fhCombCorrShift && isfield(lcm,'fhCombCorrShift')
        if ishandle(lcm.fhCombCorrShift)
            delete(lcm.fhCombCorrShift)
        end
        lcm = rmfield(lcm,'fhCombCorrShift');
    end
    if isfield(lcm,'fhCombFisher')
        if ishandle(lcm.fhCombFisher)
            delete(lcm.fhCombFisher)
        end
        lcm = rmfield(lcm,'fhCombFisher');
    end
end
    
%--- info printout ---
fprintf('LCM correlation figures written to file\n')

%--- update success flag ---
f_succ = 1;
