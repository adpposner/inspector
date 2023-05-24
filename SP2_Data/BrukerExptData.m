classdef BrukerExptData < ExptData

    properties
        dataBrukerFormat uint32

    end

    methods 

        function obj = BrukerExptData(fidFilePath)
            arguments
                fidFilePath {mustBeFile}
            end
            obj.manufacturer = StudyManufacturer.Bruker;
            obj.exptType = DataExptType.Invalid;
            obj.fidFilePath = fidFilePath;
        end

        function [methFile,acqFile] = methAcqFile(obj)
            [fidDir,~,~] = fileparts(obj.fidFilePath);
            methFile = [fidDir filesep 'method'];
            acqFile = [fidDir filesep 'acqp'];
            assert(exist(methFile,'file')==2, 'Method file not found.');
            assert(exist(acqFile,'file')==2, 'Acq file not found.');
        end

        function setFormatType(obj)
            %Need Acq_receiverselect to check for old format
            if endsWith(obj.fidFilePath,'fid') || endsWith(obj.fidFilePath,'refscan')
                obj.dataBrukerFormat = 2;
            elseif endsWith(obj.fidFilePath,'job0') || endsWith(obj.fidFilePath,'job1')
                obj.dataBrukerFormat = 3;
                
            end
        end
    end

end