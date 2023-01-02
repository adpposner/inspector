%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcAndPlotUpdate
%% 
%%  global loggingfile processing update function.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_ProcAndPlotUpdate';


%--- check figure existence: processing necessary? ---
if isfield(proc,'fhFid1Orig') || isfield(proc,'fhFid2Orig') || ...
   isfield(proc,'fhFid1') || isfield(proc,'fhFid2') || ...
   isfield(proc,'fhSpec1') || isfield(proc,'fhSpec2') || ...
   isfield(proc,'fhFidSuper') || isfield(proc,'fhSpecSuper') || ...
   isfield(proc,'fhFidSum') || isfield(proc,'fhFidDiff') || ...
   isfield(proc,'fhSpecSum') || isfield(proc,'fhSpecDiff')
   
    %--- data processing ---
    if flag.procUpdateCalc
        if ~SP2_Proc_ProcComplete
            fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
            return
        end
    end
    
    %--- figure update ---
    if ~SP2_Proc_FigureUpdate
        fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
        return
    end
end        
