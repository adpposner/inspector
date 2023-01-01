%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function pars = SP2_DisplPars(parName)
%%
%%  1) Display function of assigned parameter
%%  2) the parameter is return to the workspace for further analysis
%%
%%  Christoph Juchem, 12-2006
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars flag exm syn pass act impt ana reg optn splx expt tosi tosiCom


FCTNAME = 'SP2_DisplPars';

if ~SP2_Check4Str(parName)
    return
end
eval(['pars = ' parName])
