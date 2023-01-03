classdef SP2_Data_StudyTypeEnum

enumeration
        Invalid (0),Varian,Bruker,GE,SiemensRda,SiemensDat,DIMCOMIMA,DICOM,PhilipsRaw,PhilipsCollapsed
    end

    methods(Static) 
        function sType = getStudyType(fidFile,fidDir)
            sType = SP2_Data_StudyTypeEnum.Invalid;
            if strcmp(fidDir(end-4:end-1),'fid')
                fprintf('Data format: Varian\n');
                sType = SP2_Data_StudyTypeEnum.Varian;
            elseif strcmp(fidFile,'fid') || strcmp(fidFile,'fid.refscan') || ...  % Bruker
                strcmp(fidFile,'rawdata.job0') || strcmp(fidFile,'rawdata.job1')
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