%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_QualityCalcFidArrSerial
%%
%%  Calculation of Rx-combined FID array.
%% 
%%  12-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_QualityCalcFidArrSerial';


%--- init success flag ---
f_succ = 0;

%--- data reformating: merge series ---
% from fid(series,nspecC,individual NR) to fid(nspecC, total NR)
% note that this step is outside the above processing module in case
% further corrections have been applied, ie. to make sure the
% latest/current data is used.
% fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 1 3]),data.spec1.nspecC,...
%                        data.spec1.seriesN*data.spec1.nr);

%--- data formating ---
if ndims(data.spec1.fidArrRxComb)==4        % saturation recovery experiment
    %--- 4D to 3D conversion for saturation recovery data ---
    % shuffle phase encode and SR dimension:
    % before <series><nspecC><nv><sarrec>
    % after  <series><nspecC><nr> with <nr>=<nv>*<satrec>, satrec inner loop
    fidArrSerial = permute(data.spec1.fidArrRxComb,[1 2 4 3]);
    if prod(size(fidArrSerial))==data.spec1.seriesN*data.spec1.nspecC*data.spec1.nr
        fidArrSerial = reshape(fidArrSerial,data.spec1.seriesN,data.spec1.nspecC,data.spec1.nr);
    else
        fprintf('\n%s ->\nIncompatible data dimensions in serial array assignment:\n',FCTNAME);
        fprintf('size(data.spec1.fidArrRxComb) = %s\n',SP2_Vec2PrintStr(size(data.spec1.fidArrRxComb),0,1));
        fprintf('Check data consistency and/or reload series.\n\n');
        return
    end
    
    % concatenate multiple series:
    % before <series><nspecC><nr>
    % after  <nspecC><nr*series>
    fidArrSerial = permute(fidArrSerial,[2 3 1]);
    data.spec1.fidArrSerial = reshape(fidArrSerial,data.spec1.nspecC,data.spec1.seriesN*data.spec1.nr);
elseif flag.dataExpType==7                 % JDE array
    if numel(data.spec1.fidArrRxComb)==data.spec1.nspecC*data.spec1.seriesN*data.spec1.nr      % before alignment 
        data.spec1.fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 3 1]),data.spec1.nspecC,...
                                          data.spec1.seriesN*data.spec1.nr);
    else                        % after alignment
        data.spec1.fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 3 1]),data.spec1.nspecC,...
                                          data.spec1.seriesN*data.spec1.nr/data.spec1.t2TeN);
    end
else                                        % all other experiment types
    data.spec1.fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 3 1]),data.spec1.nspecC,...
                                      data.spec1.seriesN*data.spec1.nr);
end

%--- update success flag ---
f_succ = 1;

end
