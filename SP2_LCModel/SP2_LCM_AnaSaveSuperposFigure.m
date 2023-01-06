%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaSaveSuperposFigure
%% 
%%  Save LCModel summary figure to file.
%%
%%  08-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_AnaSaveSuperposFigure';


%--- init success flag ---
f_succ = 0;

%--- check directory access ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    fprintf('Directory for superposition figure export is not accessible. Program aborted.\n');
    return
end

%--- keep parameter settings ---
flagLcmShowSelAll = flag.lcmShowSelAll;

%--- temporary adopt parameter settings ---
flag.lcmShowSelAll = 0;         % all metabolites, i.e. no selection

%--- check figure existence ---
f_fhLcmFitSpecSuperpos = 0;
if isfield(lcm,'fhLcmFitSpecSuperpos')
    if ishandle(lcm.fhLcmFitSpecSuperpos)
        f_fhLcmFitSpecSuperpos = 1;
    end
end

%--- (re)create LCM superpos figure ---
if ~SP2_LCM_PlotResultSpecSuperpos(1)    
    return
end

%--- save figure to file ---
if isfield(lcm,'fhLcmFitSpecSuperpos')
    if ishandle(lcm.fhLcmFitSpecSuperpos)
        superposFigPath = [lcm.expt.dataDir 'SPX_LcmSuperpos.fig'];
        saveas(lcm.fhLcmFitSpecSuperpos,superposFigPath,'fig');
        
        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            superposJpgPath = [lcm.expt.dataDir 'SPX_LcmSuperpos.jpg'];
            saveas(lcm.fhLcmFitSpecSuperpos,superposJpgPath,'jpg');
            fprintf('LCM total superposition figure saved to files:\n%s\n%s\n',...
                    superposFigPath,superposJpgPath);
        else
            fprintf('LCM total superposition figure saved to files:\n%s\n',superposFigPath);
        end
    end
end

%--- remove figures that have not existed beforehand ---
if ~f_fhLcmFitSpecSuperpos && isfield(lcm,'fhLcmFitSpecSuperpos')
    if ishandle(lcm.fhLcmFitSpecSuperpos)
        delete(lcm.fhLcmFitSpecSuperpos)
    end
    lcm = rmfield(lcm,'fhLcmFitSpecSuperpos');
end

%--- reset parameter settings ---
flag.lcmShowSelAll = flagLcmShowSelAll;

%--- update success flag ---
f_succ = 1;

end
