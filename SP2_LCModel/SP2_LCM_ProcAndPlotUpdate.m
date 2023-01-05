%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ProcAndPlotUpdate
%% 
%%  global processing update function.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_ProcAndPlotUpdate';


%--- check figure existence: processing necessary? ---
if flag.lcmUpdProcTarget
    if isfield(lcm,'fhLcmFidOrig') || isfield(lcm,'fhLcmFid') || ...
       isfield(lcm,'fhLcmSpec')

        %--- data processing ---
        if flag.lcmUpdateCalc
            if ~SP2_LCM_ProcLcmData
                fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
                return
            end
        end
    end        
end

%--- figure update ---
if isfield(lcm,'fhLcmFidOrig') || isfield(lcm,'fhLcmFid') || ...
   isfield(lcm,'fhLcmSpec')

    %--- figure update ---
    if ~SP2_LCM_FigureUpdate
        fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
        return
    end
end        
