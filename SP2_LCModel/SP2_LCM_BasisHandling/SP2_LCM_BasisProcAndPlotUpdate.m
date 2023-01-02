%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisProcAndPlotUpdate
%% 
%%  global loggingfile processing update function.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm flag

FCTNAME = 'SP2_LCM_BasisProcAndPlotUpdate';


%--- check figure existence: processing necessary? ---
% if isfield(lcm,'fhBasisSpec') && flag.lcmUpdProcBasis, obsolete as
% updating between processed vs. non-processed might be necessary
% independent of processing details
if isfield(lcm,'fhBasisSpec')

    %--- data processing ---
    if flag.lcmUpdateCalc
        if ~SP2_LCM_BasisProcData(lcm.basis.currShow)
            fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
            return
        end
    end
    
    %--- figure update ---
    if ~SP2_LCM_BasisFigureUpdate
        fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
        return
    end
end        

