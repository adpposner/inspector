%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcAndPlotUpdate
%% 
%%  global processing update function.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_ProcAndPlotUpdate';


%--- check figure existence: processing necessary? ---
if isfield(mrsi,'fhFid1Orig') || isfield(mrsi,'fhFid2Orig') || ...
   isfield(mrsi,'fhFid1') || isfield(mrsi,'fhFid2') || ...
   isfield(mrsi,'fhSpec1') || isfield(mrsi,'fhSpec2') || ...
   isfield(mrsi,'fhFidSuper') || isfield(mrsi,'fhSpecSuper') || ...
   isfield(mrsi,'fhFidSum') || isfield(mrsi,'fhFidDiff') || ...
   isfield(mrsi,'fhSpecSum') || isfield(mrsi,'fhSpecDiff')
   
    %--- data processing ---
    if flag.mrsiUpdateCalc
        if ~SP2_MRSI_ProcComplete
            fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
            return
        end
    end
    
    %--- figure update ---
    if ~SP2_MRSI_FigureUpdate
        fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- check figure existence: MRSI ---
% if isfield(mrsi,'fhFid1Img')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowFid1Img(0)
% end
% if isfield(mrsi,'fhFid2Img')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowFid2Img(0)
% end
% if isfield(mrsi,'fhFidDiffImg')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowFidDiffImg(0)
% end
% if isfield(mrsi,'fhSpec1Img')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowSpec1Img(0)
% end
% if isfield(mrsi,'fhSpec2Img')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowSpec2Img(0)
% end
% if isfield(mrsi,'fhSpecDiffImg')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowSpecDiffImg(0)
% end
% if isfield(mrsi,'fhSpec1Mrsi')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowSpec1Mrsi(0)
% end
% if isfield(mrsi,'fhSpec2Mrsi')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowSpec2Mrsi(0)
% end
% if isfield(mrsi,'fhSpecDiffMrsi')
%     % figure update (without reprocessing)
%     SP2_MRSI_ShowSpecDiffMrsi(0)
% end


    
    
    
    