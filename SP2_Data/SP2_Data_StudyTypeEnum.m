classdef SP2_Data_StudyTypeEnum < uint32

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
        function sType = getStudyType(fidFile,fidName,fidDir)
            sType = SP2_Data_StudyTypeEnum.Invalid;
            if strcmp(fidDir(end-4:end-1),'fid')
                fprintf('Data format: Varian\n');
                sType = SP2_Data_StudyTypeEnum.Varian;
            elseif strcmp(fidName,'fid') || strcmp(fidName,'fid.refscan') || ...  % Bruker
                strcmp(fidName,'rawdata.job0') || strcmp(fidName,'rawdata.job1')
                fprintf('Data format: Bruker\n');
                sType = SP2_Data_StudyTypeEnum.Bruker;
            elseif endswith(fidFile,'.7')
                fprintf('Data format: General Electric\n');
                sType = SP2_Data_StudyTypeEnum.GE;
            elseif endswith(fidFile,'.rda')             % Siemens
                fprintf('Data format: Siemens (.rda)\n');
                sType = SP2_Data_StudyTypeEnum.SiemensRda;
            elseif endswith(fidFile,'.dcm')             % DICOM
                fprintf('Data format: DICOM\n');
                sType = SP2_Data_StudyTypeEnum.DICOM;
            elseif endswith(fidFile,'.dat')             % Siemens
                fprintf('Data format: Siemens (.dat)\n');
                sType = SP2_Data_StudyTypeEnum.SiemensDat;
            elseif endswith(fidFile,'.raw')             % Philips raw
                fprintf('Data format: Philips (.raw)\n');
                sType = SP2_Data_StudyTypeEnum.PhilipsRaw;
            elseif endswith(fidFile,'.SDAT')            % Philips collapsed
                fprintf('Data format: Philips (.SDAT)\n');
                sType = SP2_Data_StudyTypeEnum.PhilipsCollapsed;
            elseif endswith(fidFile,'.IMA')             % DICOM
                fprintf('Data format: DICOM (.IMA)\n');
                sType = SP2_Data_StudyTypeEnum.DICOMIMA;
            else
                fprintf('%s ->\nData format not valid. File assignment aborted.\n',FCTNAME);
                return
            end
        end
    end

end