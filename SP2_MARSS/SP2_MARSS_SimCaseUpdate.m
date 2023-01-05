%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_SimCaseUpdate
%% 
%%  Update function for vendor + sequence combination.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_MARSS_SimCaseUpdate';


%--- success flag init ---
f_succ = 0;

%--- update vendor-specific sequence selection ---
switch flag.marssSequName
    case 1                  % STEAM
        switch flag.marssSequOrigin
            case 1          % GE
                flag.marssSimCase = 1;
            case 2          % Siemens
                flag.marssSimCase = 2;
            case 3          % Philips
                flag.marssSimCase = 3;
            otherwise
                fprintf('%s ->\nCombination flag.marssSequName=%.0 and flag.marssSequOrigin=%.0f is not supported.\nProgram aborted.\n',...
                        FCTNAME,flag.marssSequName,flag.marssSequOrigin)
                return
        end
    case 2                  % PRESS
        switch flag.marssSequOrigin
            case 1          % GE
                flag.marssSimCase = 4;
            case 2          % Siemens
                flag.marssSimCase = 5;
            case 3          % Philips
                flag.marssSimCase = 6;
            otherwise
                fprintf('%s ->\nCombination flag.marssSequName=%.0 and flag.marssSequOrigin=%.0f is not supported.\nProgram aborted.\n',...
                        FCTNAME,flag.marssSequName,flag.marssSequOrigin)
                return
        end
    case 3                  % sLASER
        switch flag.marssSequOrigin
            case 1          % GE
                flag.marssSimCase = 7;
            case 2          % Siemens
                flag.marssSimCase = 8;
            case 3          % Philips (NOT IMPLEMENTED)
                flag.marssSimCase = 9;
            otherwise
                fprintf('%s ->\nCombination flag.marssSequName=%.0 and flag.marssSequOrigin=%.0f is not supported.\nProgram aborted.\n',...
                        FCTNAME,flag.marssSequName,flag.marssSequOrigin)
                return
        end
    case 4                  % Custom
        flag.marssSimCase = 10;
    otherwise
        fprintf('%s ->\nflag.marssSequName=%.0f is not supported.\nProgram aborted.\n',...
                FCTNAME,flag.marssSequName)
        return
end

%--- update success flag ---
f_succ = 1;






