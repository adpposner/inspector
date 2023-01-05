%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ]  = SP2_MRSI_SpatialFilter(datStruct)
%%
%%  Spatial filter of k-space data matrix.
%% 
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_SpatialFilter';


%--- init success flag ---
f_succ = 0;


%--- defaults & flags --------------------------
Y_CsiCircOffset   = 0.05;          % radius offset for Hamming weighting calculation via radius condition
Y_CsiWeightOffset = 0.00;          % amplitude offset of the CSI weighting function to minimize discretization errors


% CSI LIST CALCULATION ******************************
% gradient scaling, quadratic k-space matrix 					   
% GradMat contains equidistant values from 0 to 2 and is then shifted to the -1/1 range
% to sample the k-space origin, k-space values are shifted 0.5 the sampling grid if a
% list is used (circular, hamming) and the sampling matrix is even
GradMat0 = zeros(datStruct.nEncR,datStruct.nEncR);
GradMat1 = zeros(datStruct.nEncR,datStruct.nEncR);
if mod(datStruct.nEncR,2.0)==0                 % shifted case
    for icnt = 1:datStruct.nEncR
        for jcnt = 1:datStruct.nEncR 
            GradMat0(icnt,jcnt) = (icnt-1)*2/datStruct.nEncR -1;
	        GradMat1(icnt,jcnt) = (jcnt-1)*2/datStruct.nEncR -1;
        end
    end
    dkshift = 1/datStruct.nEncR;               % shift relative to initial matrix */
else			                            % odd datStruct.nEncR
    for icnt = 1:datStruct.nEncR 
        for jcnt = 1:datStruct.nEncR 
            GradMat0(icnt,jcnt) = 2.0*(icnt-1)/(datStruct.nEncR-1) - 1;
	        GradMat1(icnt,jcnt) = 2.0*(jcnt-1)/(datStruct.nEncR-1) - 1;
        end
    end
     dkshift = 0;	                        % no weighting function shift
end

% determination of residual k-space points for circular sampling */
% radius + Y_CsiCircOffset (to include more ambient points), radius=1 */
if mod(datStruct.nEncR,2.0)==0
    YesNoValue = (1-1/(datStruct.nEncR-1)) * (1 + Y_CsiCircOffset); 
else
	YesNoValue = 1 + Y_CsiCircOffset;    
end	

% calculate hamming filter function */
for icnt = 1:datStruct.nEncR
    hammVec(icnt) = 0.54 - 0.46*cos(2*pi*(icnt-1)/(datStruct.nEncR-1));
end
AcqMatrixOrig = zeros(datStruct.nEncR,datStruct.nEncR);
for icnt = 1:datStruct.nEncR
    for jcnt = 1:datStruct.nEncR
	    AcqMatrixOrig(icnt,jcnt) = hammVec(icnt)*hammVec(jcnt);	    % like HammingFilterMult.m */ 
        % restrict to circular scheme */   	
	    % halfdk is used to shift the pattern, when k-space is shifted for odd dimensional matrices */
	    if sqrt(power(GradMat0(icnt,jcnt)+dkshift,2)+power(GradMat1(icnt,jcnt)+dkshift,2)) > YesNoValue
	        AcqMatrixOrig(icnt,jcnt) = 0;
        end
    end
end

%--- apply filter function ---
for rcvrCnt = 1:datStruct.nRcvrs
    for fidCnt = 1:datStruct.nspecC
        datStruct.fidksp(fidCnt,:,:,rcvrCnt) = AcqMatrixOrig .* squeeze(datStruct.fidksp(fidCnt,:,:,rcvrCnt));
    end
end

%--- info printout ---
fprintf('Spatial filter applied (%s).\n',datStruct.name);

%--- update success flag ---
f_succ = 1;



