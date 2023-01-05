%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_T1T2_DoTConstAnalysis
%%
%%  Multi-exponential analysis of T1/T2 time constants.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2 flag

FCTNAME = 'SP2_T1T2_DoTConstAnalysis';


%--- init read flag ---
f_succ = 0;

%--- check data existence ---
if flag.t1t2AnaData<4           % experimental data (FIDs or spectra)
    if ~isfield(t1t2,'spec')
        if ~SP2_T1T2_DataLoadAndReco
            return
        end
    end
end

%--- T1 / T2 selection ---
if flag.t1t2AnaData<4               % experimental data (FIDs or spectra)
    if t1t2.expType==1
        if ~SP2_T1T2_DoT1Analysis
            return
        end
    else
        if ~SP2_T1T2_DoT2Analysis
            return
        end
    end
elseif flag.t1t2AnaData==4          % direct assignment: T1
    if ~SP2_T1T2_DoT1Analysis
        return
    end
else                                % direct assignment: T2
    if ~SP2_T1T2_DoT2Analysis
        return
    end
end 
    
%--- update read flag ---
f_succ = 1;
