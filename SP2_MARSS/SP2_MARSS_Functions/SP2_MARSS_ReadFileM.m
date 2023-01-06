function [pulseStruct] = SP2_MARSS_ReadFileM(filename,autoMean)

eval(['[G amplitudeUnit coherencePathway delays durations rephaseAreas rfOffsets rfPulses phaseShifts] = ' filename(1:end-2) '();']);

% filename

pulseStruct.rfpulses = rfPulses;
pulseStruct.numberOfPulses =  length(rfPulses);
pulseStruct.durations = durations;
pulseStruct.delays = delays;
pulseStruct.gamma = 267.52219; %gyromagnetic ratio proton
% pulseStruct.numberOfMetabolites = length(metabolites);

%fill out offset frequencies
if (exist('coherencePathway','var'))
    pulseStruct.coherencePathway = coherencePathway;
    pulseStruct.filterPathways = true;
else
    pulseStruct.filterPathways = false;
    disp('Warning, you have not input the coherencePathway variable (way to handle unwanted coherence pathways). Either youre handling them with gradients, phase cycling or you likely made a mistake')
end

%fill out the gradients
if (exist('G','var'))
    if (isa(G,'cell')) %gradient waveforms input
        pulseStruct.gradientwave = true;
        gradientWaveformHolder = G;
        Gholder = zeros(length(rfPulses),3);
        for ii = 1:length(G)
            Gholder(ii,:) = sum(G{ii},1); %just to check how things are
        end
        pulseStruct.G = Gholder; %just to check whether 1D / generate propagators can be used
        G = Gholder;
    else
        pulseStruct.gradientwave = false;
        G = reshape(G,pulseStruct.numberOfPulses,3); %G should be N x 3 or 3 x N where N is number of pulses (G(1) is x G(2) is y and G(3) is z)
        pulseStruct.G = G;
    end
else
    pulseStruct.G = zeros(pulseStruct.numberOfPulses,3);
    G = pulseStruct.G;
    pulseStruct.gradientwave = false;
    disp('Warning: no gradients found, using a matrix of zeros')
end

pulseStruct.generatePropagators = true; %determine if you can use propagators
for ii = 1:size(G,1)
    Grow = G(ii,:);
    if (sum(Grow == 0) < 2)
        pulseStruct.generatePropagators = false;
        pulseStruct.use1DProjection = false;
    end
end

%fill out offset frequencies
if (exist('autoMean','var'))
    pulseStruct.autoMean = autoMean;
else
    pulseStruct.autoMean = true;
end

%fill out the calibration frequency
if (exist('referencePeak','var'))
    pulseStruct.referencePeak = referencePeak;
else
    pulseStruct.referencePeak = 4.65; %4.65 ppm otherwise
end

%fill out offset frequencies
if (exist('rfOffsets','var'))
    pulseStruct.offsets = rfOffsets;
else
    pulseStruct.offsets = zeros(pulseStruct.numberOfPulses,1);
end

%just used for proper size handling
if (pulseStruct.autoMean)
    pulseStruct.dimsize = 2;
else
    pulseStruct.dimsize = 5;
end

%fill out rephase areas
if (exist('rephaseAreas','var'))
    pulseStruct.rephaseAreas = rephaseAreas;
else
    pulseStruct.rephaseAreas = zeros(pulseStruct.numberOfPulses,3);
end
pulseStruct.rephaseAreasBefore = zeros(pulseStruct.numberOfPulses,3); %create 0s, fill in if need be


%find orientation of slice-select gradients
if (exist('orientation','var'))
    pulseStruct.orientation = orientation;
else
    if (pulseStruct.generatePropagators)
        for ii = 1:length(rfPulses)
            temp = pulseStruct.G(ii,:);
            if (nnz(temp) == 0)
                pulseStruct.orientation(ii) = 0; %there's no gradient
            else
                pulseStruct.orientation(ii) = find(temp~=0);
            end
        end
    end
end

if (pulseStruct.generatePropagators)
    pulseStruct = determineRFOrder(pulseStruct); %determine if you can use 1D projection and if so fill out the required orientation information
end

if (~autoMean) %you can't use 1D projection if autoMean is used
    pulseStruct.use1DProjection = false;
end

%if you're not using 1D projection method then go back to using the
%original rephase areas
if (~pulseStruct.use1DProjection)
    pulseStruct.rephaseAreas = rephaseAreas;
    pulseStruct.rephaseAreasBefore = zeros(pulseStruct.numberOfPulses,3); %create 0s, fill in if need be
end

%fill out OVERALL PHASE SHIFTS for phase cycling
if (exist('phaseShifts','var'))
    pulseStruct.phaseShifts = phaseShifts;
else
    pulseStruct.phaseShifts = zeros(1,pulseStruct.numberOfPulses+1);
end

if (strcmp(amplitudeUnit,'Hz'))
    scaleFactor = 1;
else
    if (strcmp(amplitudeUnit,'rad'))
        scaleFactor = 1/2/pi;
    else
        if (strcmp(amplitudeUnit,'Gauss'))
            scaleFactor = 4257.747892;
        else
            error('Amplitude is not recognized type, should be "Hz", "rad", or "Gauss" (case sensitive)')
        end
    end
end

for ii = 1:pulseStruct.numberOfPulses %reformat
    thisPulse = pulseStruct.rfpulses{ii};
    if (size(thisPulse,2) < size(thisPulse,1))
        thisPulse = transpose(thisPulse);
    end
    pulseStruct.rfpulses{ii} = thisPulse;
end

for ii = 1:pulseStruct.numberOfPulses %add in phase and scale if necessary to amplitude units of rad
    if((size(pulseStruct.rfpulses{ii},1) == 1) || (size(pulseStruct.rfpulses{ii},1) == 1))  %there's no phase
        pulseStruct.rfpulses{ii} = [pulseStruct.rfpulses{ii}; zeros(1,length(pulseStruct.rfpulses{ii}))]; %add zeros for phase
    end
    temp = pulseStruct.rfpulses{ii};
    temp(1,:) = scaleFactor*temp(1,:);
    pulseStruct.rfpulses{ii} = temp;
end

%add in the offset frequency by adjusting the phase
for ii = 1:pulseStruct.numberOfPulses
    pulse = pulseStruct.rfpulses{ii};
    t = linspace(0,durations(ii),length(pulse));
    phaseBefore = pulse(2,:);
    phaseAfter = phaseBefore + 2*pi*pulseStruct.offsets(ii)*t;
    pulse(2,:) = phaseAfter;
    pulseStruct.rfpulses{ii} = pulse;
    %     figure;plot(1:length(phaseBefore),phaseBefore,1:length(phaseAfter),phaseAfter)
end

%assign gradient waveform to G
if (pulseStruct.gradientwave)
    pulseStruct.G = gradientWaveformHolder;
    for ii = 1:pulseStruct.numberOfPulses
        thisRF = pulseStruct.rfpulses{ii};
        thisG = pulseStruct.G{ii};
        tRF = linspace(0,durations(ii),length(thisRF));
        tG = linspace(0,durations(ii),size(thisG,1));
        if (size(thisG,1) == 1) %if it's a single value make sure to interpolate properly
            tG = [0 durations(ii)];
            thisG = [thisG; thisG];
        end
        if (length(thisRF) > length(thisG)) %interpolate the gradient waveform
            interpG = interp1(tG,thisG,tRF);
            pulseStruct.G{ii} = interpG;
            
        else %interpolate the RF waveform (probably rare?)
            interpRF = interp1(tRF,thisRF,tG);
            pulseStruct.rfpulses{ii} = interpRF;
        end
    end
end

%there's relaxation
if (exist('relaxationTimes','var'))
    size(relaxationTimes,2)
    if (size(relaxationTimes,1) ~= length(pulseStruct.numberOfMetabolites))
        error('The number of relaxation times must be a matrix with the number of rows equal to the number of metabolites and 2 columns (T1 then T2)')
    end
    pulseStruct.relaxationTimes = relaxationTimes;
    pulseStruct.relaxation = true;
    pulseStruct.use1DProjection = false; %can't use 1D projection with relaxation
    pulseStruct.generatePropagators = false; %can't use propagators either
else
    pulseStruct.relaxation = false;
end

if(pulseStruct.use1DProjection)
    disp('Using 1D projection method')
else
    disp('Warning, no 1D projection will be used. This will cause simulations to take a long time. This is because there are slice-selective gradients (G) or gradients between pulses (rephaseAreas) in two or more dimensions simultaneously. Typically orthogonal slices are used in which case you should rotate your gradients to make them orthogonal, if theyre truly non-orthogonal then disregard this message');
end
if(pulseStruct.generatePropagators)
    disp('Using propagator generation method')
else
    disp('Warning, no propagators. This will cause simulations to take a long time. This is because there are slice-selective gradients (G) in two or more dimensions simultaneously. Typically orthogonal slices are used in which case you should rotate your gradients to make them orthogonal, if theyre truly non-orthogonal then disregard this message');
end

end
