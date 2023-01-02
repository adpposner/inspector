%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotAnaAverage
%% 
%%  Visualization update of FID/spectrum average.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag data

FCTNAME = 'SP2_Data_PlotAnaAverage';


%--- init success flag ---
f_succ = 0;

%--- window creation/update ---
switch flag.dataAna
    case 1              % FID 1
        fprintf('\nTHIS FUNCTION IS NO IMPLEMENTED YET!!!...\n\n');
        return
        
        if isfield(data,'fhFid1Average')
            if ~SP2_Data_PlotFid1Average(0)
                fprintf('%s -> Plotting of FID 1 failed.\n',FCTNAME);
            end
        else
            if ~SP2_Data_PlotFid1Average(1)
                fprintf('%s -> Plotting of FID 1 failed.\n',FCTNAME);
            end
        end
    case 2              % spectrum 1
        if isfield(data,'fhSpec1Average')
            if ~SP2_Data_PlotSpec1Average(0)
                fprintf('%s -> Plotting of spectrum 1 failed.\n',FCTNAME);
            end
        else
            if ~SP2_Data_PlotSpec1Average(1)
                fprintf('%s -> Plotting of spectrum 1 failed.\n',FCTNAME);
            end
        end
    case 3              % FID 2
        fprintf('\nTHIS FUNCTION IS NO IMPLEMENTED YET!!!...\n\n');
        return
        
        if isfield(data,'fhFid2Average')
            if ~SP2_Data_PlotFid2Average(0)
                fprintf('%s -> Plotting of FID 2 failed.\n',FCTNAME);
            end
        else
            if ~SP2_Data_PlotFid2Average(1)
                fprintf('%s -> Plotting of FID 2 failed.\n',FCTNAME);
            end
        end
    case 4              % spectrum 2
        if isfield(data,'fhSpec2Average')
            if ~SP2_Data_PlotSpec2Average(0)
                fprintf('%s -> Plotting of spectrum 2 failed.\n',FCTNAME);
            end
        else
            if ~SP2_Data_PlotSpec2Average(1)
                fprintf('%s -> Plotting of spectrum 2 failed.\n',FCTNAME);
            end
        end
end

%--- update success flag ---
f_succ = 1;

