%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_FormatList2Mat( datStruct )
%%
%%  Reorganizes serially sampled k-space points and pads them into a full
%%  cartesian grid.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_FormatList2Mat';


%--- init success flag ---
f_succ = 0;

%--- reorder list data to their corresponding k-space positions ---
if datStruct.aver>1
    % matrix init
    datStruct.fidksp = complex(zeros(datStruct.nspecC,datStruct.nEncR,datStruct.nEncP,datStruct.aver,datStruct.nRcvrs));
    
    % k-space-specific FID summation
    for rcvrCnt = 1:datStruct.nRcvrs
        for nvCnt = 1:datStruct.nEnc
            datStruct.fidksp(:,datStruct.encTableR(nvCnt)+round(datStruct.nEncR/2),...
                             datStruct.encTableP(nvCnt)+round(datStruct.nEncP/2),rcvrCnt) = ...
            datStruct.fidksp(:,datStruct.encTableR(nvCnt)+round(datStruct.nEncR/2),...
                             datStruct.encTableP(nvCnt)+round(datStruct.nEncP/2),rcvrCnt) + ...
            datStruct.fidkspvec(:,nvCnt,rcvrCnt);
        end
    end
else
    % matrix init
    datStruct.fidksp = complex(zeros(datStruct.nspecC,datStruct.nEncR,datStruct.nEncP,datStruct.nRcvrs));
    
    % k-space assignment
    for rcvrCnt = 1:datStruct.nRcvrs
        for nvCnt = 1:datStruct.nEnc
            datStruct.fidksp(:,datStruct.encTableR(nvCnt)+round(datStruct.nEncR/2),...
                             datStruct.encTableP(nvCnt)+round(datStruct.nEncP/2),rcvrCnt) = ...
                             datStruct.fidkspvec(:,nvCnt,rcvrCnt);
    %                         fprintf('%.0f: [%.0f %.0f]\n',nvCnt,datStruct.encTableR(nvCnt)+round(datStruct.nEncR/2),...
    %                                 datStruct.encTableP(nvCnt)+round(datStruct.nEncP/2))
        end
    end
end

%--- update success flag ---
f_succ = 1;
end
