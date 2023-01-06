function f_succ = SP2_MARSS_SaveSignals(metabolites,signal,outputDirectory,exptDat,autoMean)

% individualSpinFolder = [outputDirectory 'IndividualSpins_for_' inputmat(1:end-4)];
% summedSpinFolder = [outputDirectory 'SummedSpins_for_' inputmat(1:end-4)];
% rawFolder = [outputDirectory 'RawBasis_for_' inputmat(1:end-4)];


%--- init success flag ---
f_succ = 0;

individualSpinFolder = [outputDirectory 'IndividualSpins'];
summedSpinFolder = [outputDirectory 'SummedSpins'];
rawFolder = [outputDirectory 'RawBasis'];

if (autoMean)
    maxFolder = 3;
else
    maxFolder = 2;
end
%deleted IndividualSpins and SummedSpins
for jj = 1:maxFolder
    if (jj == 1)
        myFolder = individualSpinFolder;
    end
    if (jj == 2)
        myFolder = summedSpinFolder;
    end
    if (jj == 3)
        myFolder = rawFolder;
    end
    if(exist(myFolder,'dir'))
        if isdir(myFolder)
            if (jj == 3)
                filePattern = fullfile(myFolder, '*.raw'); %
            else
                filePattern = fullfile(myFolder, '*.mat'); %
            end
            theFiles = dir(filePattern);
            for ii = 1:length(theFiles)
                baseFileName = theFiles(ii).name;
                fullFileName = fullfile(myFolder, baseFileName);
                delete(fullFileName);
            end
        end
        rmdir(myFolder);
    end
end

%remake the directories
mkdir(individualSpinFolder)
mkdir(summedSpinFolder)
if (autoMean)
    mkdir(rawFolder)
end
numberOfMetabolites = size(metabolites,2);
for ii = 1:numberOfMetabolites
    meanSignal = signal{ii};
    exptDat.fid = meanSignal;
    save([individualSpinFolder '\' metabolites{ii} '.mat'],'exptDat')
    if (autoMean)
        exptDat.fid = sum(meanSignal,2);
    else
        exptDat.fid = sum(meanSignal,5);
    end
    save([summedSpinFolder '\' metabolites{ii} '.mat'],'exptDat')
    
    %create raw files only if auto mean is off
    if (autoMean)
        exptDat.fid = conj(exptDat.fid); %needed for LCModel basis
        rawFileName = [rawFolder '\' metabolites{ii} '.raw'];
        convertExptDatToRaw(rawFileName,exptDat);
    end
end

%--- update success flag ---
f_succ = 1;

end
