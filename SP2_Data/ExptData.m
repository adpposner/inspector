classdef ExptData < handle

    properties 
        manufacturer(1,1) StudyManufacturer
        exptType(1,1) DataExptType
        fidFilePath(1,:) char
    end


methods
    function obj = ExptData()
        obj.manufacturer = StudyManufacturer.Invalid;
        obj.exptType = DataExptType.Invalid;
    end

    function setExperimentType(obj,tp)
        arguments
            obj ExptData
            tp(1,1) DataExptType
        end
        obj.exptType = tp;
    end

    function setFidFilePath(obj,fidPath)
        arguments
            obj ExptData
            fidPath {mustBeFile}
        end
        obj.fidFilePath = fidPath
        obj.manufacturer = StudyManufacturer.getStudyType(obj.fidFilePath)
    end

end



methods(Static)
    function loadFunc = getLoadFunction()
        supportedarray={{@loadVarianMRS,@loadBrukerMRS,@loadGEMRS,@loadSiemensMRS,@loadSiemensMRS,@loadDICOMMRS,@loadPhilipsMRS}, ...
        {@loadVarianSatRec,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}, ...
        {@loadVarianJDE,@loadBrukerJDE,@loadGEJDE,@loadSiemensJDE,@loadSiemensJDE,@loadDICOMJDE,@loadPhilipsJDE}, ...
        {@loadVarianStab,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}, ...
        {@loadVarianT1T2,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}, ...
        {@loadVarianMRSI,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}, ...
        {@loadVarianJDEArray,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}};
        loadFunc = supportedarray{obj.manufacturer}{obj.exptType};
    end
end

end