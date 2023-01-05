classdef SP2_FileHelper

methods(Static)
    function flag_OS = operatingSystem()
    %persistent flagOS;
    if ispc
        flagOS=0;
    elseif ismac
        flagOS=2;
    elseif isunix
        flagOS=1;
    else
        flagOS=-1;
    end
    flag_OS = flagOS;
    end

    function dd=setGetDefaultDir()
        if ispc
            dd= 'C:\Users\';
        elseif ismac
            dd = '/Users/';
        elseif isunix
            %return '/home/';
            %%RP
            dd =  '/home/russell/MRSData/MartinRestruct/001_Martin/';
        else
            dd = -1;
            %do error
        end
    end

    function pth = inspectorPath()
        persistent basepth;
        if isempty(basepth)
            fms = what('INSPECTOR');
            if isempty(fms) || ~isfield(fms,'path')
                SP2_Logger.log('%s ->\nCouldn''t find the main program file\nCheck folder name/existence <INSPECTOR_v2> and software version...',FCTNAME);
                return
            else
               basepth = [fms.path filesep];
            end
        end
        pth = basepth;
    end

    function [protDir,protFile,protPathMat,protPathTxt] = protocolPaths(protPath)
        [protDir,f,e] = fileparts(protPath);
        protFile = [f e];
        protPathMat = [protPath '.mat'];
        protPathTxt = [protPath '.txt'];
    end

end


end