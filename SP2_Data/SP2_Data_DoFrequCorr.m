%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_DoFrequCorr
%% 
%%  Apply frequency corrections.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_DoFrequCorr';


%--- processing parameters ---
ZFFAC = 16;         % zero-filling factor
LB    = 0;          % exponential line broadening, not implemented yet

%--- init success flag ---
f_done = 0;

%--- check data existence ---
if ~isfield(data.spec1,'fid')
    if ~SP2_Data_Dat1FidFileLoad
        return
    end
end

%--- frequency correction ---
phVec = 0:(data.spec1.nspecC-1);                  % base phase vector
corrHz = zeros(data.spec1.nRcvrs,data.spec1.nr);        % frequency correction matrix
for rcvrCnt = 1:data.spec1.nRcvrs
    for nrCnt = 1:data.spec1.nr
        %--- spectral FFT ---
        datSpec = abs(fftshift(fft(data.spec1.fid(:,rcvrCnt,nrCnt),ZFFAC*data.spec1.nspecC)));
        
        %--- extraction of frequency window ---
        [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(data.ppmMin,data.ppmMax,...
                                                                       data.ppmCalib,data.spec1.sw,datSpec);
        
        %--- point vs. interpolated maximum determination ---
        if flag.dataFrequCorr                   % single maximum point
            %--- max point determination ---
            [maxVal,maxInd] = max(specZoom);
        else                                    % interpolated/modeled peak maximum
            fprintf('%s -> NOT YET IMPLEMENTED!!!!!!!\n',FCTNAME);
            return
        end

        %--- frequency correction ---
        % note that the absolute index positions do not matter here since
        % shift are obtained relative to a reference with the same index offset
        if rcvrCnt==1 && nrCnt==1
            maxIndFirst = maxInd;           % keep first value as reference
        else
            % relative frequency correction
            corrHz(rcvrCnt,nrCnt) = (maxInd-maxIndFirst)*data.spec1.sw_h/(ZFFAC*data.spec1.nspecC);
            % phase correction per point
            phPerPt = corrHz(rcvrCnt,nrCnt)*data.spec1.dwell*data.spec1.nspecC*(pi/180)/(2*pi);
            % apply phase (i.e. frequency) correction
            data.spec1.fid(:,rcvrCnt,nrCnt) = data.spec1.fid(:,rcvrCnt,nrCnt) .* exp(-1i*phPerPt*phVec');
        end
    end
end    

%--- info printout ---
fprintf('%s:\n',FCTNAME);
fprintf('SD.: Receivers %sHz, total %.1fHz\n',SP2_Vec2PrintStr(std(corrHz,0,2)',2),...
        std(reshape(corrHz,1,data.spec1.nRcvrs*data.spec1.nr)))
    
%--- update success flag ---
f_done = 1;
