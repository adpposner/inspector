%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotAnaSuperposition
%% 
%%  Visualization update of superposition FID/spectrum.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_PlotAnaSuperposition';


%--- init success flag ---
f_succ = 0;

%--- window creation/update ---
switch flag.dataAna
    case 1              % FID 1
%         if isfield(data,'fhFid1Super')
%             if ~SP2_Data_PlotFid1Superposition(0)
%                 fprintf('%s -> Plotting of FID 1 failed.\n',FCTNAME);
%             end
%         else
            if ~SP2_Data_PlotFid1Superposition(1)
                fprintf('%s -> Plotting of FID 1 failed.\n',FCTNAME);
            end
%         end
    case 2              % spectrum 1
%         if isfield(data,'fhSpec1Super')
%             if ~SP2_Data_PlotSpec1Superposition(0)
%                 fprintf('%s -> Plotting of spectrum 1 failed.\n',FCTNAME);
%             end
%         else
            if ~SP2_Data_PlotSpec1Superposition(1)
                fprintf('%s -> Plotting of spectrum 1 failed.\n',FCTNAME);
            end
%         end
    case 3              % FID 2
%         if isfield(data,'fhFid2Super')
%             if ~SP2_Data_PlotFid2Superposition(0)
%                 fprintf('%s -> Plotting of FID 2 failed.\n',FCTNAME);
%             end
%         else
            if ~SP2_Data_PlotFid2Superposition(1)
                fprintf('%s -> Plotting of FID 2 failed.\n',FCTNAME);
            end
%         end
    case 4              % spectrum 2
%         if isfield(data,'fhSpec2Super')
%             if ~SP2_Data_PlotSpec2Superposition(0)
%                 fprintf('%s -> Plotting of spectrum 2 failed.\n',FCTNAME);
%             end
%         else
            if ~SP2_Data_PlotSpec2Superposition(1)
                fprintf('%s -> Plotting of spectrum 2 failed.\n',FCTNAME);
            end
%         end
end

%--- update success flag ---
f_succ = 1;

