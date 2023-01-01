%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaSaveSpecs
%%
%%  Save SPX LCModel result spectra to file.
%%
%%  05-2016, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_AnaSaveSpecs';


%--- init success flag ---
f_succ = 0;

%--- check existence of LCM analysis ---
if ~isfield(lcm.fit,'resid')
    fprintf('No LCModel analysis found. Perform first.\n')
    return
end

%--- check directory access ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    fprintf('Directory for spectral data export is not accessible. Program aborted.\n')
    return
end

%--- path handling: result directory ---
resultDir = SP2_SlashWinLin([lcm.expt.dataDir 'SPX_LcmData\']);
if ~SP2_CheckDirAccessR(resultDir)
    [f_succ,msg,msgId] = mkdir(resultDir);
    if f_succ
        fprintf('Directory <%s> created.\n',resultDir)
    else
        fprintf('Directory creation failed. Program aborted.\n%s\n\n',msg)
        return
    end
end

%--- general parameter assignment ---
exptDat.sf     = lcm.sf;
exptDat.sw_h   = lcm.sw_h;
exptDat.nspecC = lcm.fit.nspecC;

%--- fit sum ---
exptDat.fid = ifft(ifftshift(lcm.fit.sumSpec,1),[],1);
filePath    = [resultDir 'SPX_SumSpec.mat'];
save(filePath,'exptDat')
fprintf('\nSpectral fit written to\n%s\n',filePath);

%--- fit residual ---
exptDat.fid = ifft(ifftshift(lcm.fit.resid,1),[],1);
filePath    = [resultDir 'SPX_Residual.mat'];
save(filePath,'exptDat')
fprintf('Fit residual written to\n%s\n',filePath);

%--- baseline fit ---
if flag.lcmAnaPoly && flag.lcmUpdProcBasis && isfield(lcm.fit,'polySpec') && flag.lcmPlotInclBase
    exptDat.fid = ifft(ifftshift(lcm.fit.polySpec,1),[],1);
    filePath    = [resultDir 'SPX_Baseline.mat'];
    save(filePath,'exptDat')
    fprintf('Baseline written to\n%s\n',filePath);
end


%--- metabolite selection ---
if flag.lcmShowSelAll           % selection
    if any(lcm.showSel<1)
        fprintf('%s ->\nMinimum metabolite number <1 detected!\n',FCTNAME)
        return
    end
    if any(lcm.showSel>lcm.fit.appliedFitN)
        fprintf('%s ->\nAt least one metabolite number exceeds number of\nfitted spectral components (%.0f metabs)\n',...
                FCTNAME,lcm.fit.appliedFitN)
        return
    end
    if isempty(lcm.showSel)
        fprintf('%s ->\nEmpty metabolite selection detected.\nMinimum: 1 metabolite!\n',FCTNAME)
        return
    end
end

%--- dimension handling ---
if flag.lcmShowSelAll           % spectrum selection
    nMetab = lcm.showSelN;
else                            % all metabolites
    nMetab = lcm.fit.appliedFitN;
end 

%--- serial saving of individual, selected spectral fits ---
for bCnt = 1:nMetab
    %--- data extraction: individual LCM traces ---
    % note that here the same ppmCalib is used as the spectra are already aligned
    if flag.lcmShowSelAll                       % metabolite selection
        %--- metabolite only ---
        exptDat.fid = ifft(ifftshift(lcm.fit.spec(:,lcm.showSel(bCnt)),1),[],1);
        filePath    = [resultDir sprintf('SPX_%s.mat',lcm.basis.data{lcm.fit.applied(lcm.showSel(bCnt))}{1})];
        save(filePath,'exptDat')
        fprintf('Metabolite %.0f <%s> written to\n%s\n',lcm.showSel(bCnt),lcm.basis.data{lcm.fit.applied(lcm.showSel(bCnt))}{1},filePath);
        
        %--- metabolite + baseline ---
        if flag.lcmAnaPoly && flag.lcmUpdProcBasis && isfield(lcm.fit,'polySpec') && flag.lcmPlotInclBase
            exptDat.fid = ifft(ifftshift(lcm.fit.polySpec+lcm.fit.spec(:,lcm.showSel(bCnt)),1),[],1);
            filePath    = [resultDir sprintf('SPX_%s+base.mat',lcm.basis.data{lcm.fit.applied(lcm.showSel(bCnt))}{1})];
            save(filePath,'exptDat')
            fprintf('Metabolite %.0f <%s> + baseline written to\n%s\n',lcm.showSel(bCnt),lcm.basis.data{lcm.fit.applied(lcm.showSel(bCnt))}{1},filePath);
        end
    else                                        % all metabolites
        %--- metabolite only ---
        exptDat.fid = ifft(ifftshift(lcm.fit.spec(:,bCnt),1),[],1);
        filePath    = [resultDir sprintf('SPX_%s.mat',lcm.basis.data{lcm.fit.applied(bCnt)}{1})];
        save(filePath,'exptDat')
        fprintf('Metabolite %.0f <%s> written to\n%s\n',bCnt,lcm.basis.data{lcm.fit.applied(bCnt)}{1},filePath);

        %--- metabolite + baseline ---
        if flag.lcmAnaPoly && flag.lcmUpdProcBasis && isfield(lcm.fit,'polySpec') && flag.lcmPlotInclBase
            exptDat.fid = ifft(ifftshift(lcm.fit.polySpec+lcm.fit.spec(:,bCnt),1),[],1);
            filePath    = [resultDir sprintf('SPX_%s+base.mat',lcm.basis.data{lcm.fit.applied(bCnt)}{1})];
            save(filePath,'exptDat')
            fprintf('Metabolite %.0f <%s> + baseline written to\n%s\n',bCnt,lcm.basis.data{lcm.fit.applied(bCnt)}{1},filePath);
        end
    end
end

%--- update success flag ---
f_succ = 1;




