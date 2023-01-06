%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaSaveLogInit
%% 
%%  Initialization of log file for text printout equivalent to command window trace.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag 

FCTNAME = 'SP2_LCM_AnaSaveLogInit';


%--- init success flag ---
f_succ = 0;

%--- consistency checks and path handling ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    fprintf('\nWARNING:\nDirectory for log export is not accessible:\n%s\n',lcm.expt.dataDir);
    fprintf('(flag for log file creation disabled.)\n\n');
    flag.lcmSaveLog = 0;
    SP2_LCM_LCModelWinUpdate 
else
    lcm.logPath = [lcm.expt.dataDir 'SPX_LcmAnalysis.log'];

    %--- create/init log file ---
    lcm.log = fopen(lcm.logPath,'w');
    if ~lcm.log
        fprintf('\nWARNING:\nLCM log file could not be created even if directory is accessible:\n%s\n',lcm.logPath);
        fprintf('Check directory permissions...\n');
        fprintf('(flag for log file creation disabled.)\n\n');
        flag.lcmSaveLog = 0;
        SP2_LCM_LCModelWinUpdate    
    else
        %--- init file ---
        fprintf(lcm.log,'\nINSPECTOR LCM ANALYSIS LOG\n\n');
        fprintf(lcm.log,'%s\n\n',datestr(now));
    %     fclose(lcm.log);

        %--- info printout ---
        if flag.verbose
            fprintf('LCM log file created/initialized:\n%s\n',lcm.logPath);
        end
    end
end

%--- update success flag ---
f_succ = 1;

end
