%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotAnaFWHM
%% 
%%  FWHM analysis of FID/spectrum.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag data

FCTNAME = 'SP2_Data_PlotAnaFWHM';


%--- init success flag ---
f_succ = 0;

%--- NOT INSTALLED YET ---
fprintf('\nTHIS FUNCTION IS NOT FULLY FUNCTIONAL YET.\n\n',FCTNAME);
return

%--- window creation/update ---
switch flag.dataAna
    case 1              % FID 1
        fprintf('%s -> FWHM analysis of FID 1 is not supported.\n',FCTNAME);
    case 2              % spectrum 1
        if isfield(data,'fhSpec1')
            if ~SP2_Data_PlotSpec1FWHM(0)
                fprintf('%s -> FWHM analysis of spectrum 1 failed.\n',FCTNAME);
            end
        else
            if ~SP2_Data_PlotSpec1FWHM(1)
                fprintf('%s -> FWHM analysis of spectrum 1 failed.\n',FCTNAME);
            end
        end
    case 3              % FID 2
        fprintf('%s -> FWHM analysis of FID 2 is not supported.\n',FCTNAME);
    case 4              % spectrum 2
        if isfield(data,'fhSpec2')
            if ~SP2_Data_PlotSpec2FWHM(0)
                fprintf('%s -> FWHM analysis of spectrum 2 failed.\n',FCTNAME);
            end
        else
            if ~SP2_Data_PlotSpec2FWHM(1)
                fprintf('%s -> FWHM analysis of spectrum 2 failed.\n',FCTNAME);
            end
        end
end

%--- update success flag ---
f_succ = 1;

