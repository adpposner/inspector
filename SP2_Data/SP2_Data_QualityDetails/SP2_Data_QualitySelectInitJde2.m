%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualitySelectInitJde2
%% 
%%  Init selection string for 1st (edited) JDE experiment.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm data flag

FCTNAME = 'SP2_Data_QualitySelectInitJde2';


%--- all / select ---
if flag.dataAllSelect               % all NR
    first = 1;
    last  = data.spec1.nr;
    data.quality.selectStr = '';
    for seriesCnt = 1:data.spec1.seriesN
        if seriesCnt==1
            data.quality.selectStr = [num2str(first+1) ':2:' num2str(last)];
        else
            data.quality.selectStr = [data.quality.selectStr ' ' num2str(first+(seriesCnt-1)*data.spec1.nr+1) ':2:' num2str(last+(seriesCnt-1)*data.spec1.nr)];
        end
    end
else
    %--- consistency checks ---
    if length(find(data.selectStr==':'))>1
        fprintf('%s ->\nMore than one colon detected. Program aborted.\n',FCTNAME);
        return
    end
    if any(data.selectStr==' ')
        fprintf('%s ->\nSpace(s) detected in select string on data page. Program aborted.\n',FCTNAME);
        return
    end

    %--- string assignment ---
    if length(find(data.selectStr==':'))==1                 % single colon: single, continuous group of NR
        [firstStr,lastStr] = strtok(data.selectStr,':');
        first = str2num(firstStr);
        last  = str2num(lastStr(2:end));
        data.quality.selectStr = '';
        for seriesCnt = 1:data.spec1.seriesN
            if seriesCnt==1
                data.quality.selectStr = [num2str(first+1) ':2:' num2str(last)];
            else
                data.quality.selectStr = [data.quality.selectStr ' ' num2str(first+(seriesCnt-1)*data.spec1.nr+1) ':2:' num2str(last+(seriesCnt-1)*data.spec1.nr)];
            end
        end
    else                                                    % no colon: single NR selected
        [firstStr,lastStr] = strtok(data.selectStr,':');
        first = str2num(firstStr);
        data.quality.selectStr = '';
        for seriesCnt = 1:data.spec1.seriesN
            if seriesCnt==1
                data.quality.selectStr = [num2str(first+1)];
            else
                data.quality.selectStr = [data.quality.selectStr ' ' num2str(first+(seriesCnt-1)*data.spec1.nr+1)];
            end
        end
    end
end
set(fm.data.qualityDet.selectStr,'String',data.quality.selectStr)

%--- calibration vector assignment ---
data.quality.select  = eval(['[' data.quality.selectStr ']']);      % selection vector assignment
data.quality.selectN = length(data.quality.select);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(data.quality.select)==0)
    fprintf('%s ->\nMultiple assignments of the same experiment detected...\n',FCTNAME);
    return
end
if ~isnumeric(data.quality.select)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if any(data.quality.select<1)
    fprintf('%s ->\nMinimum experiment number <1 detected!\n',FCTNAME);
    return
end
if isfield(data.spec1,'nr') && isfield(data.spec1,'seriesN')
    if any(data.quality.select>data.spec1.nr*data.spec1.seriesN)
        fprintf('%s ->\nMaximum experiment exceeds number of available spectra:\n',FCTNAME);
        fprintf('NR (%.0f) x scans (%.0f) = %.0f\n',data.spec1.nr,data.spec1.seriesN,...
                data.spec1.nr*data.spec1.seriesN)
        return
    end
end
if isempty(data.quality.select)
    fprintf('%s ->\nEmpty calibration vector detected.\nMinimum: 1 calibration experiment!\n',FCTNAME);
    return
end

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);


