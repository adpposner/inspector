function [pulseStruct] = determineRFOrder(pulseStruct)

pulseStruct.use1DProjection = true;
orientation = pulseStruct.orientation;
zeropositions = find(pulseStruct.orientation == 0);
xpositions = find(pulseStruct.orientation == 1);
ypositions = find(pulseStruct.orientation == 2);
zpositions = find(pulseStruct.orientation == 3);

numberOfSequenceBlocks = 0;
%determine if there's an x pulse
xpulse = false;
ypulse = false;
zpulse = false;
if (sum(pulseStruct.orientation == 1) > 0)
    xpulse = true;
    numberOfSequenceBlocks = numberOfSequenceBlocks + 1;
end
if (sum(pulseStruct.orientation == 2) > 0)
    ypulse = true;
    numberOfSequenceBlocks = numberOfSequenceBlocks + 1;
end
if (sum(pulseStruct.orientation == 3) > 0)
    zpulse = true;
    numberOfSequenceBlocks = numberOfSequenceBlocks + 1;
end

minx = min(xpositions); maxx = max(xpositions);
miny = min(ypositions); maxy = max(ypositions);
minz = min(zpositions); maxz = max(zpositions);
mintotal = min([minx miny minz]);
maxtotal = max([maxx maxy maxz]);
if (numberOfSequenceBlocks >= 3) %3 slice-selective RF Pulses
    %find first pulse
    if (minx < miny && minx < minz) %x is smallest
        if (miny < minz) % it's x y z
            ordering = [xpositions ypositions zpositions];
            rfOrdering = [1 2 3];
        else %it's x z y
            ordering = [xpositions zpositions ypositions];
            rfOrdering = [1 3 2];
        end
    elseif (miny < minx && miny < minz) %y is smallest
        if (minx < minz) %it's y x z
            ordering = [ypositions xpositions zpositions];
            rfOrdering = [2 1 3];
        else %it's y z x
            ordering = [ypositions zpositions xpositions];
            rfOrdering = [2 3 1];
        end
    else %z is the smallest
        if (minx < miny) %it's z x y
            ordering = [zpositions xpositions ypositions];
            rfOrdering = [3 1 2];
        else %it's z y x
            ordering = [zpositions ypositions xpositions];
            rfOrdering = [3 2 1];
        end
    end
elseif (numberOfSequenceBlocks == 2) %2 slice-selective RF pusles
    if (xpulse && ypulse) %x and y
        if (minx < miny) %x is smallest
            ordering = [xpositions ypositions];
            rfOrdering = [1 2];
        else
            ordering = [ypositions xpositions];
            rfOrdering = [2 1];
        end
    elseif (xpulse && zpulse) %x and z
        if (minx < minz) %x is smallest
            ordering = [xpositions zpositions];
            rfOrdering = [1 3];
        else
            ordering = [zpositions xpositions];
            rfOrdering = [3 1];
        end
    else %y and z
        if (minz < miny) %z is smallest
            ordering = [zpositions ypositions];
            rfOrdering = [3 2];
        else
            ordering = [ypositions zpositions];
            rfOrdering = [2 3];
        end
    end
else (numberOfSequenceBlocks == 1) %1 slice-selective RF pulse
    if (xpulse)
        ordering = xpositions;
        rfOrdering = 1;
    elseif (ypulse)
        ordering = ypositions;
        rfOrdering = 2;
    else
        ordering = zpositions;
        rfOrdering = 3;
    end
end

if (numberOfSequenceBlocks == 3)
    if (rfOrdering == [1 2 3])
        zerosToAdd1= min(ypositions)-max(xpositions)-1;
        zerosToAdd2 = min(zpositions)-max(ypositions)-1;
        totalRFOrdering = [min(xpositions):max(xpositions) min(ypositions):max(ypositions) min(zpositions):max(zpositions)];
    end
    if (rfOrdering == [1 3 2])
        zerosToAdd1= min(zpositions)-max(xpositions)-1;
        zerosToAdd2 = min(ypositions)-max(zpositions)-1;
        totalRFOrdering = [min(xpositions):max(xpositions) min(zpositions):max(zpositions) min(ypositions):max(ypositions)];
    end
    if (rfOrdering == [2 1 3])
        zerosToAdd1= min(xpositions)-max(ypositions)-1;
        zerosToAdd2 = min(zpositions)-max(xpositions)-1;
        totalRFOrdering = [min(ypositions):max(ypositions) min(xpositions):max(xpositions) min(zpositions):max(zpositions)];
    end
    if (rfOrdering == [2 3 1])
        zerosToAdd1= min(zpositions)-max(ypositions)-1;
        zerosToAdd2 = min(xpositions)-max(zpositions)-1;
        totalRFOrdering = [min(ypositions):max(ypositions) min(zpositions):max(zpositions) min(xpositions):max(xpositions)];
    end
    if (rfOrdering == [3 1 2])
        zerosToAdd1= min(xpositions)-max(zpositions)-1;
        zerosToAdd2 = min(ypositions)-max(xpositions)-1;
        totalRFOrdering = [min(zpositions):max(zpositions) min(xpositions):max(xpositions) min(ypositions):max(ypositions)];
    end
    if (rfOrdering == [3 2 1])
        zerosToAdd1= min(ypositions)-max(zpositions)-1;
        zerosToAdd2 = min(xpositions)-max(ypositions)-1;
        totalRFOrdering = [min(zpositions):max(zpositions) min(ypositions):max(ypositions) min(xpositions):max(xpositions)];
    end
    rfOrdering = [rfOrdering(1) zeros(1,zerosToAdd1) rfOrdering(2) zeros(1,zerosToAdd2) rfOrdering(3)];
    numberOfSequenceBlocksPlusZero = numberOfSequenceBlocks+zerosToAdd1+zerosToAdd2;
end
if (numberOfSequenceBlocks == 2)
    if (rfOrdering == [1 2])
        zerosToAdd = min(ypositions) - max(xpositions)-1;
        totalRFOrdering = [min(xpositions):max(xpositions) min(ypositions):max(ypositions)];
    end
    if (rfOrdering == [1 3])
        zerosToAdd = min(zpositions) - max(xpositions)-1;
        totalRFOrdering = [min(xpositions):max(xpositions) min(zpositions):max(zpositions)];
    end
    if (rfOrdering == [2 1])
        zerosToAdd = min(xpositions) - max(ypositions)-1;
        totalRFOrdering = [min(ypositions):max(ypositions) min(xpositions):max(xpositions)];
    end
    if (rfOrdering == [2 3])
        zerosToAdd = min(zpositions) - max(ypositions)-1;
        totalRFOrdering = [min(ypositions):max(ypositions) min(zpositions):max(zpositions)];
    end
    if (rfOrdering == [3 1])
        zerosToAdd = min(xpositions) - max(zpositions)-1;
        totalRFOrdering = [min(zpositions):max(zpositions) min(xpositions):max(xpositions)];
    end
    if (rfOrdering == [3 2])
        zerosToAdd = min(ypositions) - max(zpositions)-1;
        totalRFOrdering = [min(zpositions):max(zpositions) min(ypositions):max(ypositions)];
    end
    rfOrdering = [rfOrdering(1) zeros(1,zerosToAdd) rfOrdering(2)];
    numberOfSequenceBlocksPlusZero = numberOfSequenceBlocks+zerosToAdd;
end
if (numberOfSequenceBlocks == 1)
    if (rfOrdering == 1)
        totalRFOrdering = min(xpositions):max(xpositions);
    end
    if (rfOrdering == 2)
        totalRFOrdering = min(ypositions):max(ypositions);
    end
    if (rfOrdering == 3)
        totalRFOrdering = min(zpositions):max(zpositions);
    end
    numberOfSequenceBlocksPlusZero = numberOfSequenceBlocks;
end
if (numberOfSequenceBlocks == 0)
    numberOfSequenceBlocksPlusZero = 0;
end

numberOfSequenceBlocks = numberOfSequenceBlocksPlusZero;

hitNonZero = false;
%add in zeros at beginning
if (exist('rfOrdering','var'))
    for ii = 1:length(orientation)
        if (orientation(ii) >= 1)
            hitNonZero = true;
        end
        if ((orientation(ii) == 0) && ~hitNonZero)
            numberOfSequenceBlocks = numberOfSequenceBlocks+1;
            rfOrdering = [0 rfOrdering];
        end
    end
end

hitNonZero = false;
%add in zeros at end
for ii = length(orientation):-1:1
    if (orientation(ii) >= 1)
        hitNonZero = true;
    end
    if ((orientation(ii) == 0) && ~hitNonZero)
        numberOfSequenceBlocks = numberOfSequenceBlocks+1;
        if (exist('rfOrdering','var'))
            rfOrdering = [rfOrdering 0];
        else
            rfOrdering = 0;
        end
    end
end

if (exist('ordering','var'))
    if (~issorted(ordering)) %it's monotonically increasing
        pulseStruct.use1DProjection = false; %you can't use 1D projection
    end
else
    pulseStruct.use1DProjection = true;
end

G = pulseStruct.G;
rephaseAreas = pulseStruct.rephaseAreas;
for ii = 1:size(G,1)
    Grow = G(ii,:);
    rephaseRow = rephaseAreas(ii,:);
    if (sum(rephaseRow ~= 0) > 1)
        pulseStruct.use1DProjection = false;
        break
    end
    if (sum((Grow ~= 0) == (rephaseRow ~= 0)) < 3)
        if ((sum(Grow == 0) < 3) && (sum(rephaseRow == 0) < 3))
            pulseStruct.use1DProjection = false;
            break
        end
    end
end

%determine if you can do the trick to transfer gradients
rephaseAreasBefore = pulseStruct.rephaseAreasBefore;
for ii = 1:(size(G,1)-1)
    rephaseRow = rephaseAreas(ii,:);
    rephaseRowLogical = rephaseRow ~= 0;
    orientationRest = orientation(ii+1:end);
    orientationNoZero = orientationRest(orientationRest > 0);
    if (sum(rephaseRowLogical) == 2) %there's 2 elements in this, see if you can transfer one to rephaseAreasBefore
        for jj = 1:3
            if (rephaseRowLogical(jj) == 1 && orientationNoZero(1) == jj) %it's an x element can transfer to x element
                rephaseAreasBefore(ii+1,jj) = rephaseRow(1,jj);
                rephaseAreas(ii,jj) = 0;
                pulseStruct.use1DProjection = true;
            end
        end
    end
end
pulseStruct.rephaseAreasBefore = rephaseAreasBefore;
pulseStruct.rephaseAreas = rephaseAreas;

%go through and make sure you can use 1D
for ii = 1:size(G,1)
    Grow = G(ii,:);
    rephaseRow = rephaseAreas(ii,:);
    if (sum(rephaseRow ~= 0) > 1)
        pulseStruct.use1DProjection = false;
        break
    end
end

%determine if everythings non-selective
allZeros = true;
for ii = 1:size(G,1)
    Grow = G(ii,:);
    if (sum(abs(Grow)) > 0)
        allZeros = false;
    end
end
if (allZeros)
    numberOfSequenceBlocks = 1;
    rfOrdering = zeros(size(G,1),1);
end

if (pulseStruct.use1DProjection) %determine which RF pulses to use for which pulses
    pulseStruct.xPulseLocations = xpositions;
    pulseStruct.yPulseLocations = ypositions;
    pulseStruct.zPulseLocations = zpositions;
    pulseStruct.numberOfSequenceBlocks = numberOfSequenceBlocks;
    pulseStruct.rfOrdering = rfOrdering;
end
