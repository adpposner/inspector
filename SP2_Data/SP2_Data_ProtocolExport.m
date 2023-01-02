%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ProtocolExport
%% 
%%  Exports all parameters and flags (but no data) to text file.
%%
%%  10-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile pars data proc ana expt flag

FCTNAME = 'SP2_Data_ProtocolExport';



fprintf('%s is not working yet, sorry.\n',FCTNAME);
return


%--- transfer relevant parameters to pars2save struct ---
%--- transfer pars ---
pars2save.spline         = pars.spline;
pars2save.plotRgManMin   = pars.plotRgManMin;
pars2save.plotRgManMax   = pars.plotRgManMax;
pars2save.colLims        = pars.colLims;

%--- transfer data ---
data2save.pathStudy       = data.pathStudy;
data2save.study           = data.study;
data2save.protFile        = data.protFile;
data2save.protDir         = data.protDir;
data2save.protPath        = data.protPath;
data2save.protPathMat     = data.protPathMat;
data2save.protPathTxt     = data.protPathTxt;
data2save.dirFid1         = data.dirFid1;
data2save.dirFid2         = data.dirFid2;
data2save.dirFid3         = data.dirFid3;
data2save.dirFid4         = data.dirFid4;
data2save.fidScanNo1      = data.fidScanNo1;
data2save.fidScanNo2      = data.fidScanNo2;
data2save.fidScanNo3      = data.fidScanNo3;
data2save.fidScanNo4      = data.fidScanNo4;
data2save.fid1            = data.fid1;
data2save.fid2            = data.fid2;
data2save.fid3            = data.fid3;
data2save.fid4            = data.fid4;
data2save.nav1            = data.nav1;
data2save.nav2            = data.nav2;
data2save.nav3            = data.nav3;
data2save.nav4            = data.nav4;
data2save.meth1           = data.meth1;
data2save.meth2           = data.meth2;
data2save.meth3           = data.meth3;
data2save.meth4           = data.meth4;
data2save.acqp1           = data.acqp1;
data2save.acqp2           = data.acqp2;
data2save.acqp3           = data.acqp3;
data2save.acqp4           = data.acqp4;
data2save.rawExp          = data.rawExp;
data2save.rawExpStr       = data.rawExpStr;
data2save.rawExpN         = data.rawExpN;
data2save.rawCombDirName  = data.rawCombDirName;

%--- transfer expt ---
expt2save.dir            = expt.dir;
expt2save.file           = expt.file;
expt2save.path           = expt.path;
expt2save.slice          = expt.slice;

%--- copy data to temporary structures to avoid modification of the     ---
%--- original data structures                                           ---
pars2save   = pars;
data2save    = data;
fcalc2save  = fcalc;
roi2save    = roi;
syn2save    = syn;
pass2save   = pass;
act2save    = act;
impt2save   = impt;
ana2save    = ana;
reg2save    = reg;
b1calc2save = b1calc;
b1ind2save  = b1ind;
expt2save   = expt;
tosi2save   = tosi;
calib2save  = calib;
% biot2save = biot;
rad2save    = rad;

%--- check directory access ---
if ~SP2_CheckDirAccessR(data.protDir)
    fprintf('%s ->\nProtocol export directory is not accessible. Program aborted.\n',FCTNAME);
    return
end

%--- open/generate pars file ---
unit = fopen(data.protPathTxt,'w');
version = SP2_ExtrNumFromString(FCTNAME);
if mod(version,1)~=0
    fprintf(unit, 'software\t = version %.1f\n', version);   % up to 1 subversion
else
    fprintf(unit, 'software\t = version %d\n', version);
end
fprintf(unit, 'date\t\t = %s\n', datestr(now));
fprintf(unit, 'fov\t\t = %s\n', SP2_Vec2PrintStr(expt.fov));
fprintf(unit, 'mat\t\t = %s\n', SP2_Vec2PrintStr(expt.mat,0));
fprintf(unit, 'pos\t\t = %s\n', SP2_Vec2PrintStr(expt.pos));
fprintf(unit, 'f_exptDat\t = %i\n\n', flag.exptDat);
fclose(unit);

save(protFile,'pars2save','data2save','syn2save','fcalc2save','roi2save',...
              'pass2save','act2save','impt2save','ana2save','reg2save',...
              'b1calc2save','b1ind2save','expt2save','tosi2save','calib2save',...
              'rad2save','flag')
                
%--- info printout ---
fprintf('FMAP settings written to\n<%s>\n',data.protPathTxt);
