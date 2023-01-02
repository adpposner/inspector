%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_ProcAndPlotUpdate
%% 
%%  global loggingfile processing update function.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile syn flag

FCTNAME = 'SP2_Syn_ProcAndPlotUpdate';


%--- check figure existence: processing necessary? ---
if isfield(syn,'fhSynFidOrig') || isfield(syn,'fhSynFid') || ...
   isfield(syn,'fhSynSpec') 
   
    %--- data processing ---
    if flag.synUpdateCalc
        switch flag.synSource
            case 1              % noise
                if ~SP2_Syn_DoSimNoise
                    return
                end
            case 2              % singlets
                if ~SP2_Syn_DoSimSinglets(1)        % use current metab cell assignment
                    return
                end
            case 3              % individual metabolite
                if ~SP2_Syn_DoSimMetabSingle
                    return
                end
            case 4              % brain metabolites
                if ~SP2_Syn_DoSimMetabBrain
                    return
                end
            case 5              % Processing page export
                if ~SP2_Syn_DoLoadProc
                    return
                end
            case 6              % LCM page export
                if ~SP2_Syn_DoLoadLCM
                    return
                end
        end
    end
    
    %--- figure update ---
    if ~SP2_Syn_FigureUpdate
        fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
        return
    end
end        
