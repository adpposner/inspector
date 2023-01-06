%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ExpTypeDisplay2Pars
%% 
%%  Assignment of flag.dataEditNo and flag.dataExpType based on data.expTypeDisplay.
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_ExpTypeDisplay2Pars';


%--- parameter assignment ---
switch data.expTypeDisplay
    case 1                              % Regular MRS
        flag.dataExpType = 1;
    case 2                              % JDE - 1st and last
        flag.dataExpType = 3;
        flag.dataEditNo  = 1;
    case 3                              % JDE - 2nd and last
        flag.dataExpType = 3;
        flag.dataEditNo  = 2;
    case 4                              % JDE - array
        flag.dataExpType = 7;
    case 5                              % saturation-recovery
        flag.dataExpType = 2;
    case 6                              % stability
        flag.dataExpType = 4;
    case 7                              % T1 / T2
        flag.dataExpType = 5;
    case 8                              % MRSI
        flag.dataExpType = 6;
end

%--- info printout ---
% if flag.verbose
%     fprintf('%s ->\nflag.dataExpType = %.0f\nflag.dataEditNo  = %.0f\n',...
%             FCTNAME,flag.dataExpType,flag.dataEditNo)
% end


end
