%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaSaveXls
%% 
%%  Export LCModel result to XLS file.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_AnaSaveXls';


%--- init success flag ---
f_succ = 0;

%--- consistency check ---
if isnumeric(lcm.basis.data)
    fprintf('Neither basis nor LCM result found. Program aborted.\n')
    return
end

%--- target file handling ---
if any(find(lcm.dataFileTxt=='.'))
    fidInd  = find(lcm.dataFileTxt=='.');
    xlsName = lcm.dataFileTxt(1:fidInd(end)-1);
else
    xlsName = lcm.dataFileTxt;
end

%--- consistency checks and path handling ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    fprintf('Default directory for xls export is not accessible. Program aborted.\n')
    return
else
    xlsPath = [lcm.expt.dataDir xlsName '.xls'];
    xlsPath = [lcm.expt.dataDir 'LcmAnalysis.xls'];
end

%--- info printout ---
fprintf('Writing LCM results to xls file started...\n')

%--- init result file ---
if exist(xlsPath,'file')
    delete(xlsPath)
end

%--- write labels to result page ---
xlswrite(xlsPath,{'LCM ANALYSIS'},'analysis','A1');
xlswrite(xlsPath,{'#','Metabolite','Conc. [a.u.]','LB [Hz]','GB [Hz]','Shift [Hz]','CRLB [%]'},'analysis','A3');

%--- write results to file ---
for bCnt = 1:lcm.fit.appliedN
%     xlswrite(xlsPath,[bCnt  lcm.anaLb(bCnt) lcm.anaShift(bCnt) lcm.anaScale(bCnt)],'analysis',sprintf('A%d',3+bCnt));
    xlswrite(xlsPath,{bCnt, lcm.basis.data{lcm.fit.applied(bCnt)}{1},lcm.anaScale(lcm.fit.applied(bCnt)),...
                      lcm.anaLb(lcm.fit.applied(bCnt)),lcm.anaGb(lcm.fit.applied(bCnt)),...
                      lcm.anaShift(lcm.fit.applied(bCnt)),lcm.anaCrlb(bCnt)},...
                      'analysis',sprintf('A%d',bCnt+3));
end
xlswrite(xlsPath,{'PHC0',lcm.anaPhc0},'analysis',sprintf('A%d',lcm.fit.appliedN+5));
xlswrite(xlsPath,{'PHC1',lcm.anaPhc1},'analysis',sprintf('A%d',lcm.fit.appliedN+6));

%--- write lcm structure to xls ---
xlswrite(xlsPath,{'LCM STRUCTURE'},'lcm','A1');
lcmFields  = fields(lcm);
nLcmFields = length(lcmFields);
for lcmCnt = 1:nLcmFields
    xlswrite(xlsPath,{lcmFields{lcmCnt},eval(['lcm.' lcmFields{lcmCnt}])},'lcm',sprintf('A%d',lcmCnt+3));
end

% %--- write lcm structure to xls ---
% xlswrite(xlsPath,{'LCM.BASIS STRUCTURE'},'lcm.basis','A1');
% lcmBasisFields  = fields(lcm.basis);
% nLcmBasisFields = length(lcmBasisFields);
% for lcmCnt = 1:nLcmBasisFields
%     xlswrite(xlsPath,{lcmBasisFields{lcmCnt},eval(['lcm.basis.' lcmBasisFields{lcmCnt}])},'lcm.basis',sprintf('A%d',lcmCnt+3));
% end

% 
% Error using xlswrite (line 220)
% Error: Object returned error code: 0x800A03EC


%--- write lcm structure to xls ---
xlswrite(xlsPath,{'LCM.FIT STRUCTURE'},'lcm.fit','A1');
lcmFitFields  = fields(lcm.fit);
nLcmFitFields = length(lcmFitFields);
for lcmCnt = 1:nLcmFitFields
    xlswrite(xlsPath,{lcmFitFields{lcmCnt},eval(['lcm.fit.' lcmFitFields{lcmCnt}])},'lcm.fit',sprintf('A%d',lcmCnt+3));
end

%--- write correlation matrix and CRLB to xls ---
if isfield(lcm.fit,'crlb') && isfield(lcm.fit,'corr') && 0              % disabled for now...
    xlswrite(xlsPath,{'CRLB ANALYSIS'},'CRLB','A1');
    sizeCrlb = size(lcm.fit.crlb);
    lcmFitFields  = fields(lcm.fit);
    nLcmFitFields = length(lcmFitFields);
    for lcmCnt = 1:nLcmFitFields
        xlswrite(xlsPath,{lcmFitFields{lcmCnt},eval(['lcm.fit.' lcmFitFields{lcmCnt}])},'CRLB',sprintf('A%d',lcmCnt+3));
    end
end

%--- info printout ---
fprintf('LCM results written to file:\n%s\n%s\n',xlsPath)

%--- update success flag ---
f_succ = 1;
