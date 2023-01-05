%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaDoCalcCRLB( f_plot )
%%
%%  Calculate CRLBs of LCModel analysis.
%%  Literature:
%%  1) CavasillaS00a (JMR)
%%  2) CavasillaS01a (NMR Biomed, main resource)
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_LCM_AnaDoCalcCRLB';

flag.debug = 0;

%--- init success flag ---
f_succ = 0;

%--- CRLB calculation of individual metabolites ---
fprintf('\nCRLB analysis of individual metabolites:\n');
if ~SP2_LCM_AnaDoCalcCRLB_Individual( f_plot )
    fprintf('\nCRLB analysis of individual metabolites failed!!!\n\n');
    return
end

%--- CRLB considering metabolite combinations ---
if flag.lcmComb1 || flag.lcmComb2 || flag.lcmComb3
    fprintf('\nCRLB analysis of including metabolite combinations:\n');
    if ~SP2_LCM_AnaDoCalcCRLB_Combined( f_plot )
        fprintf('\nCRLB analysis of metabolite combinations failed!!!\n\n');
        return
    end
end

%--- update success flag ---
f_succ = 1;




