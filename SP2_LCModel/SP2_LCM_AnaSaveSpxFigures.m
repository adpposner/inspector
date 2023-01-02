%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaSaveSpxFigures
%% 
%%  Save screenshots of SPX LCModel (main, basis, fit) to file.
%%
%%  05-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm fmfig fm

FCTNAME = 'SP2_LCM_AnaSaveSpxFigures';


%--- init success flag ---
f_succ = 0;

%--- check directory access ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    fprintf('Directory for INSPECTOR figure(s) export is not accessible. Program aborted.\n');
    return
end

%--- main window ---
mainPath = [lcm.expt.dataDir 'SPX_LcmMain_Screenshot.jpg'];
F = getframe(fmfig);
imwrite(F.cdata,mainPath,'jpg');

%--- basis window ---
% check figure existence
f_basisWinExist = 0;
if isfield(fm.lcm,'basis')
    if ishandle(fm.lcm.basis.fig)
        f_basisWinExist = 1;
    end
end
SP2_LCM_BasisMain
basisPath = [lcm.expt.dataDir 'SPX_LcmBasis_Screenshot.jpg'];
F = getframe(fm.lcm.basis.fig);
imwrite(F.cdata,basisPath,'jpg');
% remove if only create for figure export
if ~f_basisWinExist
    SP2_LCM_BasisExitMain
end

%--- fit window ---
% check figure existence
f_fitWinExist = 0;
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        f_fitWinExist = 1;
    end
end
SP2_LCM_FitDetailsMain
fitPath = [lcm.expt.dataDir 'SPX_LcmFit_Screenshot.jpg'];
F = getframe(fm.lcm.fit.fig);
imwrite(F.cdata,fitPath,'jpg');
% remove if only create for figure export
if ~f_basisWinExist
    SP2_LCM_FitExitMain
end

%--- info printout ---
fprintf('LCM figure written to file\n');

%--- update success flag ---
f_succ = 1;
