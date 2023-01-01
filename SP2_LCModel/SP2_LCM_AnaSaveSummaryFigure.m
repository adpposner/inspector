%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaSaveSummaryFigure(varargin)
%% 
%%  Save LCModel summary figure to file.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_AnaSaveSummaryFigure';


%--- init success flag ---
f_succ = 0;

%--- check directory access ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    fprintf('Directory for summary figure export is not accessible. Program aborted.\n')
    return
end

%--- check figure existence ---
f_fhLcmFitSpecSummary = 0;
if isfield(lcm,'fhLcmFitSpecSummary')
    if ishandle(lcm.fhLcmFitSpecSummary)
        f_fhLcmFitSpecSummary = 1;
    end
end

%--- (re)create LCM summary figure ---
if ~SP2_LCM_PlotResultSpecSummary(1)    
    return
end

%--- save figure to file ---
if isfield(lcm,'fhLcmFitSpecSummary')
    if ishandle(lcm.fhLcmFitSpecSummary)
        if nargin==1          % direct assignment of summary file name (through MC master script)
            summaryFigPath = SP2_Check4StrR(varargin{1});
        else                % default file name
            summaryFigPath = [lcm.expt.dataDir 'SPX_LcmSummary.fig'];
        end
        saveas(lcm.fhLcmFitSpecSummary,summaryFigPath,'fig');
        
        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            summaryJpgPath = [lcm.expt.dataDir 'SPX_LcmSummary.jpg'];
            saveas(lcm.fhLcmFitSpecSummary,summaryJpgPath,'jpg');
            fprintf('LCM summary figure saved to files:\n%s\n%s\n',...
                    summaryFigPath,summaryJpgPath);
        else
            fprintf('LCM summary figure saved to files:\n%s\n',summaryFigPath);
        end
    end
end

%--- remove figures that have not existed beforehand ---
if ~f_fhLcmFitSpecSummary && isfield(lcm,'fhLcmFitSpecSummary')
    if ishandle(lcm.fhLcmFitSpecSummary)
        delete(lcm.fhLcmFitSpecSummary)
    end
    lcm = rmfield(lcm,'fhLcmFitSpecSummary');
end

%--- update success flag ---
f_succ = 1;
