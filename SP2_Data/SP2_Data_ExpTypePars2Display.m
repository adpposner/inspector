%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ExpTypePars2Display
%% 
%%  Assignment of data.expTypeDisplay based on flag.dataEditNo and flag.dataExpType.
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag data

FCTNAME = 'SP2_Data_ExpTypePars2Display';


%--- parameter assignment ---
switch flag.dataExpType
    case 1                              % Regular MRS
        data.expTypeDisplay = 1;
    case 2                              % saturation-recovery
        data.expTypeDisplay = 5;
    case 3                              % JDE
        if flag.dataEditNo==1           % 1st and last
            data.expTypeDisplay = 2; 
        else                            % 2nd and last
            data.expTypeDisplay = 3;
        end
    case 4                              % stability
        data.expTypeDisplay = 6;
    case 5                              % T1 / T2
        data.expTypeDisplay = 7;
    case 6                              % MRSI
        data.expTypeDisplay = 8;
    case 7                              % JDE - array
        data.expTypeDisplay = 4;        
end
    
%--- info printout ---
% if flag.verbose
%     fprintf('%s ->\nflag.dataExpType = %.0f\nflag.dataEditNo  = %.0f\n',...
%             FCTNAME,flag.dataExpType,flag.dataEditNo)
% end

