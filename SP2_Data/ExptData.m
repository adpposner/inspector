classdef ExptData

    properties 
        manufacturer(1,1) StudyManufacturer
        exptType(1,1) DataExptType
        
    end


methods
    function obj = ExptData()
        obj.manufacturer = StudyManufacturer.Invalid;
        obj.exptType = DataExptType.Invalid;
    end


    function loadFunc = getLoadFunction(obj)
        supportedarray={{@loadVarianMRS,@loadBrukerMRS,@loadGEMRS,@loadSiemensMRS,@loadSiemensMRS,@loadDICOMMRS,@loadPhilipsMRS}, ...
        {@loadVarianSatRec,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}, ...
        {@loadVarianJDE,@loadBrukerJDE,@loadGEJDE,@loadSiemensJDE,@loadSiemensJDE,@loadDICOMJDE,@loadPhilipsJDE}, ...
        {@loadVarianStab,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}, ...
        {@loadVarianT1T2,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}, ...
        {@loadVarianMRSI,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}, ...
        {@loadVarianJDEArray,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad,@unsupportedLoad}};
        loadFunc = supportedarray{obj.manufacturer}{obj.exptType};
    end

    function setExperimentType(obj,tp)
        arguments
            obj ExptData
            tp(1,1) DataExptType
        end
        obj.exptType = tp;
    end
end

end