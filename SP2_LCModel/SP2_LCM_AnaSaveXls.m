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

%--- PHC1 NOT SUPPORTED ---
if flag.lcmAnaPhc1
    fprintf('\n\nCRLB for first order phase PHC1 is not supported yet. Program aborted.\n\n');
    return
end

%--- consistency check ---
if isnumeric(lcm.basis.data)
    fprintf('Neither basis nor LCM result found. Program aborted.\n');
    return
end

%--- consistency checks and path handling ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    fprintf('Directory for xls export is not accessible. Program aborted.\n');
    return
else
    xlsPath = [lcm.expt.dataDir 'SPX_LcmAnalysis.xls'];
end

%--- info printout ---
fprintf('Writing LCM results to xls file started...\n');

%--- delete old result file ---
% note that this only works if the file is closed
if exist(xlsPath,'file')
    delete(xlsPath)
end

% %--- check if file is in use ---
% if fopen(xlsPath)>0         % file still exists, i.e. it must have been open (and write-protected)
%     fprintf('\nThe xls file is not writable:\n%s\nPlease make sure the file is not open and try again.\n\n',xlsPath);
%     return
% end

%--- write labels to result page ---
xlswrite(xlsPath,{'LCM ANALYSIS'},'analysis','A1');
xlswrite(xlsPath,{sprintf('%s',datestr(now))},'analysis','A2');


%-------------------------------------------------------------------------------------------------
%---    I N D I V I D U A L    M E T A B O L I T E - S P E C I F I C     P A R A M E T E R S   ---
%-------------------------------------------------------------------------------------------------
%--- metabolite counter ---
xlswrite(xlsPath,{'#','Metabolite','Conc.','CRLB(Conc.)','Hess(Conc.)'},'analysis','A4');
xlswrite(xlsPath,{'','','[a.u.]','[%]','[%]'},'analysis','A5');
xlswrite(xlsPath,(1:lcm.fit.appliedN)','analysis',sprintf('A6:A%d',6+lcm.fit.appliedN-1));

%--- metabolite name
for bCnt = 1:lcm.fit.appliedN
    xlswrite(xlsPath,cellstr(lcm.basis.data{lcm.fit.applied(bCnt)}{1}),'analysis',sprintf('B%d',bCnt+5));
end

%--- amplitude / concentration ---
xlswrite(xlsPath,lcm.anaScale(lcm.fit.applied)','analysis',sprintf('C6:C%d',6+lcm.fit.appliedN-1));

%--- amplitude CRLB ---
xlswrite(xlsPath,lcm.fit.crlbAmp','analysis',sprintf('D6:D%d',6+lcm.fit.appliedN-1));

%--- amplitude Hessian error ---
xlswrite(xlsPath,100*lcm.anaScaleErr(lcm.fit.applied)'./lcm.anaScale(lcm.fit.applied)','analysis',sprintf('E6:E%d',6+lcm.fit.appliedN-1));

%--- row handling for additional fitting parameters ---
colCnt   = 5;                           % init row counter, 1..4 are always used
alphabet = char('A'+(1:26)-1)';         % create vector of alphabet letters

%--- exponential line broadening (LB) ---
if flag.lcmAnaLb && ~flag.lcmLinkLb
    %--- labels ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,{'LB','CRLB(LB)','Hess(LB)'},'analysis',sprintf('%s4',alphabet(colCnt)));
    xlswrite(xlsPath,{'[Hz]','[Hz]','[Hz]'},'analysis',sprintf('%s5',alphabet(colCnt)));
    
    %--- LB ---
    xlswrite(xlsPath,lcm.anaLb(lcm.fit.applied)','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));

    %--- LB CRLB ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,lcm.fit.crlbLb','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));

    %--- LB Hessian error ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,lcm.anaLbErr(lcm.fit.applied)','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));
end

%--- Gaussian line broadening (GB) ---
if flag.lcmAnaGb && ~flag.lcmLinkGb
    %--- labels ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,{'GB','CRLB(GB)','Hess(GB)'},'analysis',sprintf('%s4',alphabet(colCnt)));
    xlswrite(xlsPath,{'[Hz]','[Hz]','[Hz]'},'analysis',sprintf('%s5',alphabet(colCnt)));
    
    %--- GB ---
    xlswrite(xlsPath,lcm.anaGb(lcm.fit.applied)','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));

    %--- GB CRLB ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,lcm.fit.crlbGb','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));

    %--- GB Hessian error ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,lcm.anaGbErr(lcm.fit.applied)','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));
end

%--- frequency shift ---
if flag.lcmAnaShift && ~flag.lcmLinkShift
    %--- labels ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,{'Shift','CRLB(Shift)','Hess(Shift)'},'analysis',sprintf('%s4',alphabet(colCnt)));
    xlswrite(xlsPath,{'[Hz]','[Hz]','[Hz]'},'analysis',sprintf('%s5',alphabet(colCnt)));
    
    %--- shift ---
    xlswrite(xlsPath,lcm.anaShift(lcm.fit.applied)','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));

    %--- shift CRLB ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,lcm.fit.crlbShift','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));

    %--- shift Hessian error ---
    colCnt = colCnt + 1;    
    xlswrite(xlsPath,lcm.anaShiftErr(lcm.fit.applied)','analysis',sprintf('%s6:%s%d',...
             alphabet(colCnt),alphabet(colCnt),6+lcm.fit.appliedN-1));
end


%-------------------------------------------------------------------------------------------------
%---    C O M B I N E D    M E T A B O L I T E - S P E C I F I C     P A R A M E T E R S   ---
%-------------------------------------------------------------------------------------------------


% printout: metabolite combinations to command window ---
if flag.lcmComb1 || flag.lcmComb2 || flag.lcmComb3
    %--- metabolite name ---
    for bCnt = 1:lcm.combN
        xlswrite(xlsPath,cellstr(lcm.combLabels{bCnt}),'analysis',sprintf('B%d',5+lcm.fit.appliedN+bCnt));
    end
    
    %--- min/max row indices ---
    minRow = 5+lcm.fit.appliedN+1;
    maxRow = 5+lcm.fit.appliedN+lcm.combN;
    
    %--- amplitude / concentration ---
    xlswrite(xlsPath,lcm.combScale','analysis',sprintf('C%d:C%d',minRow,maxRow));

    %--- amplitude CRLB ---
    xlswrite(xlsPath,lcm.fit.combCrlbAmp(lcm.combCrlbPos)','analysis',sprintf('D%d:D%d',minRow,maxRow));

    %--- row handling for additional fitting parameters ---
    colCnt = 4;                             % init row counter

    %--- exponential line broadening (LB) ---
    if flag.lcmAnaLb && ~flag.lcmLinkLb
        %--- LB CRLB ---
        colCnt = colCnt + 3;    
        xlswrite(xlsPath,lcm.fit.combCrlbLb(lcm.combCrlbPos)','analysis',sprintf('%s%d:%s%d',...
                 alphabet(colCnt),minRow,alphabet(colCnt),maxRow));
    end

    %--- Gaussian line broadening (GB) ---
    if flag.lcmAnaGb && ~flag.lcmLinkGb
        %--- GB CRLB ---
        colCnt = colCnt + 3;    
        xlswrite(xlsPath,lcm.fit.combCrlbGb(lcm.combCrlbPos)','analysis',sprintf('%s%d:%s%d',...
                 alphabet(colCnt),minRow,alphabet(colCnt),maxRow));
    end

    %--- frequency shift ---
    if flag.lcmAnaShift && ~flag.lcmLinkShift
        %--- shift CRLB ---
        colCnt = colCnt + 3;    
        xlswrite(xlsPath,lcm.fit.combCrlbShift(lcm.combCrlbPos)','analysis',sprintf('%s%d:%s%d',...
                 alphabet(colCnt),minRow,alphabet(colCnt),maxRow));
    end
    
    %--- combination shift ---
    combShift = lcm.combN;
else
    combShift = 0;                  % no combinations included
end


%--------------------------------------------------------------------------
%---    G L O B A L     P A R A M E T E R S                             ---
%--------------------------------------------------------------------------
% if any global paramater
if (flag.lcmAnaLb && flag.lcmLinkLb) || (flag.lcmAnaGb && flag.lcmLinkGb) || ...
   (flag.lcmAnaShift && flag.lcmLinkShift) || (flag.lcmAnaPhc0 && flag.lcmLinkPhc0) || ...
   (flag.lcmAnaPhc1 && flag.lcmLinkPhc1)

    %--- label ---
    rowCnt = lcm.fit.appliedN + combShift + 8;     
    xlswrite(xlsPath,{'global parameters:'},'analysis',sprintf('A%d',rowCnt));
    rowCnt = rowCnt + 1;
    xlswrite(xlsPath,{'parameter','value','CRLB','Hessian','unit'},'analysis',sprintf('A%d',rowCnt));
    
    % in original order
    if flag.lcmAnaLb && flag.lcmLinkLb
        rowCnt = rowCnt + 1;     
        xlswrite(xlsPath,{'LB',lcm.anaLb(1),lcm.fit.crlbLb,lcm.anaLbErr(1),'Hz'},'analysis',sprintf('A%d',rowCnt));
    end
    if flag.lcmAnaGb && flag.lcmLinkGb
        rowCnt = rowCnt + 1;     
        xlswrite(xlsPath,{'GB',lcm.anaGb(1),lcm.fit.crlbGb,lcm.anaGbErr(1),'Hz'},'analysis',sprintf('A%d',rowCnt));
    end
    if flag.lcmAnaShift && flag.lcmLinkShift
        rowCnt = rowCnt + 1;     
        xlswrite(xlsPath,{'Shift',lcm.anaShift(1),lcm.fit.crlbShift,lcm.anaShiftErr(1),'Hz'},'analysis',sprintf('A%d',rowCnt));
    end
    if flag.lcmAnaPhc0
        rowCnt = rowCnt + 1;     
        xlswrite(xlsPath,{'PHC0',lcm.anaPhc0,lcm.fit.crlbPhc0,lcm.anaPhc0Err,'deg'},'analysis',sprintf('A%d',rowCnt));
    end
    if flag.lcmAnaPhc1
        rowCnt = rowCnt + 1;     
        xlswrite(xlsPath,{'PHC1',lcm.anaPhc1,lcm.fit.crlbPhc1,lcm.anaPhc1Err,'deg'},'analysis',sprintf('A%d',rowCnt));
    end
end


%--------------------------------------------------------------------------
%---    L C M     S T R U C T U R E                                     ---
%--------------------------------------------------------------------------
% %--- write lcm structure to xls ---           WRITE ALL
% xlswrite(xlsPath,{'LCM STRUCTURE'},'lcm','A1');
% lcmFields  = fields(lcm);
% nLcmFields = length(lcmFields);
% for lcmCnt = 1:nLcmFields
%     xlswrite(xlsPath,{lcmFields{lcmCnt},eval(['lcm.' lcmFields{lcmCnt}])},'lcm pars',sprintf('A%d',lcmCnt+3));
% end
%--- write lcm structure to xls ---
% xlswrite(xlsPath,{'DATA AND ANALYSIS INFO'},'info','A1');
% rowCnt = 2;             % init row counter
% if isfield(lcm,'dataPathMat')
%     rowCnt = rowCnt + 1;
%     xlswrite(xlsPath,{'data',lcm.dataPathMat},'info',sprintf('A%d',rowCnt));
% end
% if isfield(lcm,'basisPath')
%     rowCnt = rowCnt + 1;
%     xlswrite(xlsPath,{'basis',lcm.basisPath},'info',sprintf('A%d',rowCnt));
% end
% if isfield(flag,'lcmRealComplex')
%     rowCnt = rowCnt + 1;
%     if flag.lcmRealComplex          % real part only
%         xlswrite(xlsPath,{'Analysis mode: real-valued'},'info',sprintf('A%d',rowCnt));
%     else                            % complex signal
%         xlswrite(xlsPath,{'Analysis mode: complex-valued'},'info',sprintf('A%d',rowCnt));
%     end
% end

% if isfield(lcm,'basisPath')
%     rowCnt = rowCnt + 1;
%     xlswrite(xlsPath,{'basis',lcm.basisPath},'info',sprintf('A%d',rowCnt));
% end

% %--- write lcm structure to xls ---
% xlswrite(xlsPath,{'LCM.BASIS STRUCTUgRE'},'lcm.basis','A1');
% lcmBasisFields  = fields(lcm.basis);
% nLcmBasisFields = length(lcmBasisFields);
% for lcmCnt = 1:nLcmBasisFields
%     xlswrite(xlsPath,{lcmBasisFields{lcmCnt},eval(['lcm.basis.' lcmBasisFields{lcmCnt}])},'lcm.basis',sprintf('A%d',lcmCnt+3));
% end

% %--- write lcm structure to xls ---
% xlswrite(xlsPath,{'LCM.FIT STRUCTURE'},'lcm fit pars','A1');
% lcmFitFields  = fields(lcm.fit);
% nLcmFitFields = length(lcmFitFields);
% for lcmCnt = 1:nLcmFitFields
%     xlswrite(xlsPath,{lcmFitFields{lcmCnt},eval(['lcm.fit.' lcmFitFields{lcmCnt}])},'lcm.fit',sprintf('A%d',lcmCnt+3));
% end


% 
% %--- write correlation matrix and CRLB to xls ---
% if isfield(lcm.fit,'crlb') && isfield(lcm.fit,'corr') && 0              % disabled for now...
%     xlswrite(xlsPath,{'CRLB ANALYSIS'},'CRLB','A1');
%     sizeCrlb = size(lcm.fit.crlb);
%     lcmFitFields  = fields(lcm.fit);
%     nLcmFitFields = length(lcmFitFields);
%     for lcmCnt = 1:nLcmFitFields
%         xlswrite(xlsPath,{lcmFitFields{lcmCnt},eval(['lcm.fit.' lcmFitFields{lcmCnt}])},'CRLB',sprintf('A%d',lcmCnt+3));
%     end
% end

%--- info printout ---
fprintf('LCM results written to file:\n%s\n%s\n',xlsPath);

%--- update success flag ---
f_succ = 1;

end
