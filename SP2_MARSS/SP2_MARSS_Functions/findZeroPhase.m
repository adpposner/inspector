function [optimalPhase] = findZeroPhase(signal)
bw = 5000; %broaden to 2 Hz
linewidth = 2;
freq = linspace(-bw/2,bw/2,length(signal));
B0 = 3; %GE 3T
referencePeak = 4.65;
% referencePeak = referencePeak-9.3010;
% referencePeak = 0;
gamma = 267.513; 
Npoints = length(signal);
%move them all to different place
t = transpose((0:(Npoints-1))/bw);
signal = signal.*exp(1i*referencePeak*t*B0*gamma);
x = 0:(length(signal)-1);
y = transpose(exp(-x*linewidth/bw*pi));
signal = signal.*y
spec = fftshift(fft(signal));
maxRealPart = 1E9;
for ii = 0:0.001:2*pi
%     phasedSpec = fftshift(fft(signal*exp(1i*ii)));
    phasedSpec = spec*exp(1i*ii);
%     figure; plot(1:length(phasedSpec),real(phasedSpec)); title(num2str(ii))
%     sum(real(phasedSpec))
%     if (sum(real(phasedSpec)) > maxRealPart)
%         optimalPhase = ii;
%         maxRealPart = sum(real(phasedSpec))/sum(imag(phasedSpec));
%     end
%     if (sum(imag(phasedSpec)) < maxRealPart)
%         optimalPhase = ii;
%         maxRealPart = abs(sum(imag(phasedSpec)))
%     end
end

figure; plot(1:length(phasedSpec),real(spec*exp(1i*optimalPhase)))
