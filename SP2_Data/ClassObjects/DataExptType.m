classdef DataExptType < uint32

    enumeration
        Invalid (0)
        MRSReg (1)
        SatRec (2)
        JDE (3) 
        stability (4)
        T1T2 (5)
        MRSI (6)
        JDEArray (7)
    end

    methods(Static) 
        function sType = getExptType()
        end

        function opts = experimentList()
            opts = {'Regular MRS','Sat.-Recovery','JDE - 1st & last','Stability (QA)','T1 / T2','MRSI','JDE - Array'};
            %%%%%%OLD VALUE%%%%%
            %data.expTypeDisplCell  = {'Regular MRS','JDE - 1st & last','JDE - 2nd & last','JDE - Array','Sat.-Recovery','Stability (QA)','T1 / T2','MRSI'};
        end
    end

end