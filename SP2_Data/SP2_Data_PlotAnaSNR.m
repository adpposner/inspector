%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotAnaSNR
%% 
%%  Analysis of FID/spectral SNR.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_PlotAnaSNR';


%--- init success flag ---
f_succ = 0;

%--- NOT INSTALLED YET ---
fprintf('\nTHIS FUNCTION IS NOT FULLY FUNCTIONAL YET.\n\n',FCTNAME)
return

%--- window creation/update ---
switch flag.dataAna
    case 1              % FID 1
        if isfield(data,'fhFid1')
            if ~SP2_Data_PlotFid1SNR(0)
                fprintf('%s -> SNR analysis of FID 1 failed.\n',FCTNAME)
            end
        else
            if ~SP2_Data_PlotFid1SNR(1)
                fprintf('%s -> SNR analysis of FID 1 failed.\n',FCTNAME)
            end
        end
    case 2              % spectrum 1
        if isfield(data,'fhSpec1')
            if ~SP2_Data_PlotSpec1SNR(0)
                fprintf('%s -> SNR analysis of spectrum 1 failed.\n',FCTNAME)
            end
        else
            if ~SP2_Data_PlotSpec1SNR(1)
                fprintf('%s -> SNR analysis of spectrum 1 failed.\n',FCTNAME)
            end
        end
    case 3              % FID 2
        if isfield(data,'fhFid2')
            if ~SP2_Data_PlotFid2SNR(0)
                fprintf('%s -> SNR analysis of FID 2 failed.\n',FCTNAME)
            end
        else
            if ~SP2_Data_PlotFid2SNR(1)
                fprintf('%s -> SNR analysis of FID 2 failed.\n',FCTNAME)
            end
        end
    case 4              % spectrum 2
        if isfield(data,'fhSpec2')
            if ~SP2_Data_PlotSpec2SNR(0)
                fprintf('%s -> SNR analysis of spectrum 2 failed.\n',FCTNAME)
            end
        else
            if ~SP2_Data_PlotSpec2SNR(1)
                fprintf('%s -> SNR analysis of spectrum 2 failed.\n',FCTNAME)
            end
        end
end

%--- update success flag ---
f_succ = 1;

