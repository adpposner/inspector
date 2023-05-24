classdef StudyManufacturer < uint32

enumeration
    Invalid (0)
    Varian (1)
    Bruker (2)
    GE (3) 
    SiemensRda (4)
    SiemensDat (5)
    DIMCOMIMA (6)
    DICOM (7)
    PhilipsRaw (8)
    PhilipsCollapsed (9)
end
    

    methods(Static) 
        function sType = getStudyType(fidFilePath)
            [dirName,~,~] = fileparts(fidFilePath);
            sType = StudyManufacturer.Invalid;
            if strcmp(dirName(end-4:end-1),'fid')
                fprintf('Data format: Varian\n');
                sType = StudyManufacturer.Varian;
            elseif endsWith(fidFilePath,'fid') ||  endsWith(fidFilePath,'fid.refscan') || ...  % Bruker
            endsWith(fidFilePath,'rawdata.job0') ||  endsWith(fidFilePath,'rawdata.job1')
                fprintf('Data format: Bruker\n');
                sType = StudyManufacturer.Bruker;
            elseif endsWith(fidFilePath,'.7')
                fprintf('Data format: General Electric\n');
                sType = StudyManufacturer.GE;
            elseif endsWith(fidFilePath,'.rda')             % Siemens
                fprintf('Data format: Siemens (.rda)\n');
                sType = StudyManufacturer.SiemensRda;
            elseif endsWith(fidFilePath,'.dcm')             % DICOM
                fprintf('Data format: DICOM\n');
                sType = StudyManufacturer.DICOM;
            elseif endsWith(fidFilePath,'.dat')             % Siemens
                fprintf('Data format: Siemens (.dat)\n');
                sType = StudyManufacturer.SiemensDat;
            elseif endsWith(fidFilePath,'.raw')             % Philips raw
                fprintf('Data format: Philips (.raw)\n');
                sType = StudyManufacturer.PhilipsRaw;
            elseif endsWith(fidFilePath,'.SDAT')            % Philips collapsed
                fprintf('Data format: Philips (.SDAT)\n');
                sType = StudyManufacturer.PhilipsCollapsed;
            elseif endsWith(fidFilePath,'.IMA')             % DICOM
                fprintf('Data format: DICOM (.IMA)\n');
                sType = StudyManufacturer.DICOMIMA;
            else
                fprintf('%s ->\nData format not valid. File assignment aborted.\n',FCTNAME);
                sType = StudyManufacturer.Invalid;
            end
        end
    end

end