%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_RunMARSS(pulseStruct)
%%
%%  function written by Karl Landheer as a simulation tool to generate basis
%%  sets to be used for linear combination modeling for NMR experiments
%%  First written on April 10th, 2018
%%  All rights reserved, Columbia University
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag marss

FCTNAME = 'SP2_MARSS_RunMARSS';

%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
% filename = 'MARSSinput.mat';
% pulseStruct = readFile(filename)
% if flag.verbose
%     pulseStruct = readFilem(MARSSInputTmpPath)
% else
%     pulseStruct = readFilem(MARSSInputTmpPath);
% end


% load(MARSSInputTmpPath)
% load('metabList.mat');
if SP2_CheckFileExistenceR(marss.spinSys.libPath)
    load(marss.spinSys.libPath)
else
    fprintf('\n%s ->\nSpin system library not found. Program aborted.\n\n',FCTNAME);
    return
end    
    
Npoints = pulseStruct.Npoints;
x = pulseStruct.x;
y = pulseStruct.y;
z = pulseStruct.z;
bandwidth = pulseStruct.bandwidth;
outputDirectory = pulseStruct.outputDirectory;

tic
metabolites = pulseStruct.metabolites;
numberOfMetabolites = size(metabolites,2);
numberOfPhaseCyclingSteps = size(pulseStruct.phaseShifts,1);
%this is all just book keeping, most of these are grabbed from "Proton NMR
%chemical shifts and coupling constants for brain metabolites"
for ii = 1:numberOfMetabolites %loop over all metabolites
    boolFound = false;
    for kk = 1:length(metabList)
        if (strcmp(metabolites{ii},'Water')) %special case for water because its center frequency may be changed more easily
            thisMetab = []; thisMetab.name = 'Water'; thisMetab.Omega{1} = pulseStruct.referencePeak; thisMetab.numberOfProtons = 1; thisMetab.J{1} = 0;
            for jj = 1:numberOfPhaseCyclingSteps
                thisSignalGenerate = [];
                thisSignalGenerate{1} = 1/numberOfPhaseCyclingSteps*thisMetab.numberOfProtons(1)*densitySimulateTestNov30(bandwidth,Npoints,pulseStruct,thisMetab.Omega{1},thisMetab.J{1},x,y,z,pulseStruct.phaseShifts(jj,:),jj);
            end
            boolFound = true;
            break
        else
            if (strcmp(metabolites{ii},metabList{kk}.name)) %the metabolite name and name from metablist list match
                boolFound = true;
                thisMetab = metabList{kk};
                thisSignalGenerate = [];
                for mm = 1:length(thisMetab.numberOfProtons) %initialize
                    thisSignalGenerate{mm} = 0;
                end
                %                     thisSignalGenerate{mm} = 0;
                for jj = 1:numberOfPhaseCyclingSteps %loop through phase cycling steps
                    for mm = 1:length(thisMetab.numberOfProtons)
                        %simulate the signal
                        thisSignalGenerate{mm} = thisSignalGenerate{mm} + 1/numberOfPhaseCyclingSteps*thisMetab.numberOfProtons(mm)*densitySimulateTestNov30(bandwidth,Npoints,pulseStruct,thisMetab.Omega{mm},thisMetab.J{mm},x,y,z,pulseStruct.phaseShifts(jj,:),jj);
                    end
                end
                for mm = 1:length(thisMetab.numberOfProtons)
                    for tt = length(thisMetab.Omega{mm}):-1:1 %loop through to remove signals from ppm = 88 or 99 (nitrogen or phosphorus)
                        if (thisMetab.Omega{mm}(tt) == 88 || thisMetab.Omega{mm}(tt) == 99) %they're to be discarded
                            if (pulseStruct.autoMean)
                                thisSignalGenerate{mm}(:,tt) = [];
                            else
                                thisSignalGenerate{mm}(:,:,:,:,tt) = [];
                            end
                        end
                    end
                end
                if (strcmp(metabolites{ii},'Val')) %special case for valine to reduce it from an 8-spin system to a 4-spin system without effecting spectrum
                    boolFound = true;
                    if (pulseStruct.autoMean)
                        thisSignalGenerate{1}(:,3:4) = 3*thisSignalGenerate{1}(:,3:4); %boost up by factor of 3
                    else
                        thisSignalGenerate{1}(:,:,:,:,3:4) = 3*thisSignalGenerate{1}(:,:,:,:,3:4); %boost up by factor of 3
                    end
                end
            end
        end
    end
    if (boolFound)
        signal{ii} = catCell(pulseStruct.dimsize,thisSignalGenerate); %concatenate all moieties
        disp([thisMetab.name ' is done simulating'])
    else
        error(['The metabolite ' metabolites{ii} ' was not found in metabList, check to make sure name is correct'])
    end
end

% %move them all to spectral region (referenced to water probably)
% t = transpose((0:(Npoints-1))/bandwidth);
% for ii = 1:numberOfMetabolites %loop over all metabolites
%     thisSignal = signal{ii};
%     if (pulseStruct.autoMean)
%         jjSize = size(thisSignal,2);
%     else
%         jjSize = size(thisSignal,5);
%     end
%     for jj = 1:jjSize
%         if (pulseStruct.autoMean)
%             thisSignal(:,jj) = thisSignal(:,jj).*exp(-1i*pulseStruct.referencePeak*t*pulseStruct.B0*pulseStruct.gamma);
%         else
%             for xx = 1:size(thisSignal,1)
%                 for yy = 1:size(thisSignal,2)
%                     for zz = 1:size(thisSignal,3)
%                         thisPositionSignal = squeeze(thisSignal(xx,yy,zz,:,:));
%                         thisPositionSignal(:,jj) = thisPositionSignal(:,jj).*exp(-1i*pulseStruct.referencePeak*t*pulseStruct.B0*pulseStruct.gamma);
%                         thisSignal(xx,yy,zz,:,:) = thisPositionSignal;
%                     end
%                 end
%             end
%         end
%     end
%     signal{ii} = 100*thisSignal; %arbitrary of scaling by 10000 for fitting purposes, doesn't matter
% end

boolBroadenBy1Hz = true;
t = transpose((0:(Npoints-1))/bandwidth);
for ii = 1:numberOfMetabolites %loop over all metabolites
    thisSignal = signal{ii};
    if (pulseStruct.autoMean)
        jjSize = size(thisSignal,2);
    else
        jjSize = size(thisSignal,5);
    end
    for jj = 1:jjSize
        if (pulseStruct.autoMean)
            thisSignal(:,jj) = thisSignal(:,jj).*exp(-1i*pulseStruct.referencePeak*t*pulseStruct.B0*pulseStruct.gamma);
            if (boolBroadenBy1Hz)
                thisSignal(:,jj) = thisSignal(:,jj).*exp(-marss.lb*pi*t);      % LB
            end
        else
            for xx = 1:size(thisSignal,1)
                for yy = 1:size(thisSignal,2)
                    for zz = 1:size(thisSignal,3)
                        thisPositionSignal = squeeze(thisSignal(xx,yy,zz,:,:));
                        thisPositionSignal(:,jj) = thisPositionSignal(:,jj).*exp(-1i*pulseStruct.referencePeak*t*pulseStruct.B0*pulseStruct.gamma);
                        if (boolBroadenBy1Hz)
                            thisPositionSignal(:,jj) = thisPositionSignal(:,jj).*exp(-marss.lb*pi*t);  % LB
                        end
                        thisSignal(xx,yy,zz,:,:) = thisPositionSignal;
                    end
                end
            end
        end
    end
    signal{ii} = 100*thisSignal; %arbitrary of scaling by 100 for fitting purposes, doesn't matter
end

%--- output all the data ---
exptDat.sf     = pulseStruct.B0*pulseStruct.gamma/2/pi;
exptDat.sw_h   = bandwidth;
exptDat.nspecC = Npoints;

%--- save metabolite signals to file ---
% saveSignal(metabolites,signal,outputDirectory,filename,exptDat,pulseStruct.autoMean);
if flag.marssSaveIndiv
    if ~SP2_MARSS_SaveSignals(metabolites,signal,outputDirectory,exptDat,pulseStruct.autoMean);
        return
    end
    % save('generatedSignals.mat','signal')
end

%--- timing display ---
toc

%--- data transfer to simulation structure ---
marss.basis.n          = numberOfMetabolites;       % assigned only here
marss.basis.fidOrig    = complex(zeros(marss.nspecCBasic,marss.basis.n));
for bCnt = 1:marss.basis.n
    % signal dims: nspecC, nMoeity
    marss.basis.fidOrig(:,bCnt) = sum(signal{bCnt},2);
end
marss.basis.metabNames = metabolites;
marss.basis.nspecCOrig = marss.nspecCBasic;
marss.basis.nspecC     = marss.nspecCBasic;
marss.basis.sw         = marss.sw;
marss.basis.sw_h       = marss.sw_h;
marss.basis.dwell      = 1/marss.sw_h;
marss.basis.sf         = marss.sf;
marss.basis.ppmCalib   = marss.ppmCalib;

%--- update success flag ---
f_succ = 1;


end
