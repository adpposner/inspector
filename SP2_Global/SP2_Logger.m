
classdef SP2_Logger

    properties(Constant)
        SP2_INFO=0;
        SP2_WARN=1;
        SP2_ERROR=2;
        SP2_ALL = 3;
    end

    properties
        verbosityLevel;
        fileLogHandle;
    end

    methods(Access=private)
        function obj = SP2_Logger()
            obj.verbosityLevel = SP2_Logger.SP2_ALL;
        end
    end

    methods(Static)
        function obj = getInstance()
            persistent theInstance;
            if isempty(theInstance)
                theInstance = SP2_Logger();
            end
                obj = theInstance;
        end

        function log(varargin)
            obj = SP2_Logger.getInstance();
            if isempty(obj.fileLogHandle)
                obj.fileLogHandle = fopen("logfile.txt","w");
            end
            fprintf(obj.fileLogHandle,varargin{:});
        end
    end

    methods
        function setVerbosity(V_Level)
            verbosityLevel = V_Level;
        end


    end
end