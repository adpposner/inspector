function [adjustedDelays] = SP2_MARSS_AdjustDelays(delays,TE,TM,flagSequence,flagOrigin)
%Function written by Karl Landheer on January 14th, 2020 to adjust the
%delays depending on the TE/TM for STEAM/PRESS for MARSS in INSPECTOR

%The default values for TE are 30 ms for PRESS, 20 ms for STEAM and TM is
%10 ms for GE/Siemens and 16 ms for Philips. TE and TM should be in ms,
%whereas delays is in seconds.

switch flagSequence
    case 1 %STEAM
        switch flagOrigin
            case 1 %GE
                delays(1) = delays(1) + (TE-20)/2/1E3;
                delays(3) = delays(3) + (TE-20)/2/1E3;
                delays(2) = delays(2) + (TM-10)/1E3;
            case 2 %Siemens
                delays(1) = delays(1) + (TE-20)/2/1E3;
                delays(3) = delays(3) + (TE-20)/2/1E3;
                delays(2) = delays(2) + (TM-10)/1E3;
            case 3 %Philips
                delays(1) = delays(1) + (TE-20)/2/1E3;
                delays(3) = delays(3) + (TE-20)/2/1E3;
                delays(2) = delays(2) + (TM-16)/1E3;
        end
    case 2 %PRESS
        switch flagOrigin
            case 1 %GE
                if (TE < 50.4) %GE increments t_12 and t_3r linearly until a TE of 50.4 ms after which it only increases t_3r
                    delays(1) = delays(1) + (TE-30)/4/1E3;
                    delays(3) = delays(3) + (TE-30)/4/1E3;
                else
                    delays(1) = delays(1) + 5.1/1E3;
                    delays(3) = delays(3) + 5.1/1E3 + (TE-50.4)/2/1E3;
                end
            case 2 %Siemens
                delays(3) = delays(3) + (TE-30)/2/1E3;
            case 3 %Philips
                delays(3) = delays(3) + (TE-30)/2/1E3; %to be verified
        end
        delays(2) = delays(2) + (TE-30)/2/1E3;  %middle TE always has to be increased by 1/2 TE for spin-echo refocusing
    case 3 %SLASER
        switch flagOrigin
            case 1 %GE
                delays(4) = delays(4) + (TE-30.002)/2/1E3;
                delays(5) = delays(5) + (TE-30.002)/2/1E3;
            case 2 %Siemens
                delays(4) = delays(4) + (TE-20.1)/2/1E3;
                delays(5) = delays(5) + (TE-20.1)/2/1E3;
        end
end
adjustedDelays = delays;