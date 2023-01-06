function [] = plotSmoothed(signal, linewidth,bw)

freq = linspace(-bw/2,bw/2,length(signal));
B0 = 3; %GE 3T
% B0 = 2.895; %Siemens 3T
% B0 = 7.0014; %Varian 7T
referencePeak = 4.65;
% referencePeak = referencePeak-9.3010;
% referencePeak = 0;
gamma = 267.513; 
Npoints = length(signal);

%move them all to different place
t = transpose((0:(Npoints-1))/bw);
signal = signal.*exp(1i*referencePeak*t*B0*gamma);
            
            
            
% B0 = 2.894950103353842; %Siemens
% B0 = 7;
freqCentre = 267.513/2/pi*B0;
signal = squeeze(signal);
% signal = signal.*exp(-1i*phase(signal(1))*ones(length(signal),1)); %phase it

x = 0:(length(signal)-1);
y = transpose(exp(-x*linewidth/bw*pi));


bestPhase = 0; %min FID
% bestPhase = 5.4; %for Christoph sLASER NEW
% bestPhase = -pi/2;
% bestPhase = 0.5; %this is for STEAMSiemens
% bestPhase = 4.15; %this is for Philips STEAM
% bestPhase = 3.4; %this is for Philips PRESS
% bestPhase = 4.1; %this is the new one for PRESSSiemens
% bestPhase = pi;
% spread = -0.2:0.05:0.2

% for ii = bestPhase
for ii = 0
    figure;
    phasedSignal = signal*exp(1i*ii);
    a = real(fftshift(fft(phasedSignal.*y)));
%     a = a/max(a);%normalize
%     a = a/1675; %scale for NAA
%     a = a/6357; %scale for Cr
%     a = a/603.6; %scale for gaba
%     a =  a/1683; %scale for sum
    plot(freq/freqCentre,a); title(num2str(ii))
    %         plot(1:length(phasedSignal),real(fftshift(fft(phasedSignal.*y)))); title(num2str(ii))
    set(gca, 'XDir','reverse')
    %     xlim([0 5])    
     xlabel('Frequency [ppm]'); ylabel('Signal [au]'); %xlim([2 3.4]) %xlim([1.6 3.3])
%      xlim([1.7 3.2])
%     ylim([min(a)-(max(a)-min(a))*0.1 max(a)+(max(a)-min(a))*0.1])
%     ylim([-0.1 1.05])
end

% figure;plot(x/bw,signal.*y)
% hold all; plot(x/bw,abs(signal.*y))
end
