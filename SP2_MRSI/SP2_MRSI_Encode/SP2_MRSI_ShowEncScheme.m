%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ShowEncScheme
%% 
%%  Load phase encoding scheme from file and visualize.
%%
%%  xxxR: t1, inner loop
%%  xxxP: t2, outer loop
%%
%%  03-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_ShowEncScheme';


%--- MRSI definition ---
% encMode    = 'Circular13x13N121';       % Rectangular, Circular or Hamming
encMode    = 'Hamming13x13NA5N233';       % Rectangular, Circular or Hamming
mrsiMatrix = 13;                         % spatial dimension
mrsiTR     = 3;                         % repetition time [sec] for acquisition time estimate

%--- file handling ---
tabdir = 'C:\Users\juchem\Matlab\matlab_cj\INSPECTOR_v2\SP2_MRSI\SP2_MRSI_Tablib\';

%--- display options ---
impline = 3;    % images per line



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   P R O G R A M    S T A R T                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- file creation ---
filePathR = sprintf('%s%s_R.txt',tabdir,encMode);
filePathP = sprintf('%s%s_P.txt',tabdir,encMode);
[fileIdR,msg] = fopen(filePathR,'r');
if fileIdR==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end
[fileIdP,msg] = fopen(filePathP,'r');
if fileIdP==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end

%--- read table 1 (t1) from file: read ---
encCntR = 0;                % init encoding counter: read
encVecR = 0;                % encoding vector
if (fileIdR > 0)
    while (~feof(fileIdR))
        tline = fgetl(fileIdR);
        if ~isempty(tline)                      % check existence
            if isempty(strfind(tline,'='))      % not the 1st line
                encCntR = encCntR+1;
                encVecR(encCntR) = str2double(tline);
            end
        end
    end
    fclose(fileIdR);
else
    fprintf('%s -> <%s> exists but can not be opened...\n',FCTNAME,filePathR);
end

%--- read table 2 (t2) from file: phase ---
encCntP = 0;       % init encoding counter: read
encVecP = 0;                % encoding vector
if (fileIdP > 0)
    while (~feof(fileIdP))
        tline = fgetl(fileIdP);
        if ~isempty(tline)                      % check existence
            if isempty(strfind(tline,'='))      % not the 1st line
                encCntP = encCntP+1;
                encVecP(encCntP) = str2double(tline);
            end
        end
    end
    fclose(fileIdP);
else
    fprintf('%s -> <%s> exists but can not be opened...\n',FCTNAME,filePathR);
end

%--- consistency check ---
if encCntP~=encCntR
    fprintf('Inconsistent number of encoding steps detected %.0f(R) ~= %.0f(P)\n',...
            encCntR,encCntP)
    return
end

%--- shift indices to positive center ---
encVecR = encVecR + round(mrsiMatrix/2);
encVecP = encVecP + round(mrsiMatrix/2);

%--- convert to matrix scheme ---
encMat = zeros(mrsiMatrix,mrsiMatrix);
for encCnt = 1:encCntR
    encMat(encVecR(encCnt),encVecP(encCnt)) = encMat(encVecR(encCnt),encVecP(encCnt)) + 1;
end

% %--- visualization of the encoding matrix ---
% fh = figure;
% set(fh,'Name',sprintf(' MRSI Encoding Scheme: %s_R/P.txt',encMode),...
%     'Color',[1 1 1])
% encMatPlot = zeros(mrsiMatrix+1,mrsiMatrix+1);
% encMatPlot(1:mrsiMatrix,1:mrsiMatrix) = encMat;
% pcolor(encMatPlot)
% set(gca,'XTick',[]);
% set(gca,'YTick',[]);
% set(gca,'DataAspectRatioMode','Manual')
% colormap(gray(2))


%--- plot each niveau of the hamming weighting into separate plot ---
mrsiAver = max(max(encMat));                    % maximum number of k-space repetitions
NoResidD = mod(mrsiAver,impline);               % impline = images per line
NoRowsD  = (mrsiAver-NoResidD)/impline+1;
fig4 = figure;
namestr4 = sprintf(' niveau representation of weigthed acquisition scheme');
set(fig4,'Name',namestr4)
set(fig4,'Color',[1 1 1]);
for PlotCnt = 1:mrsiAver
    subplot(NoRowsD,impline,PlotCnt)
    pAcqMatrix = zeros(mrsiMatrix+1,mrsiMatrix+1);
    pAcqMatrix(1:mrsiMatrix,1:mrsiMatrix) = (encMat>=ones(mrsiMatrix)*PlotCnt);
    pcolor(pAcqMatrix)
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    xlabstr = sprintf('NA=%.0f (%.0f)',PlotCnt,length(find(encMat>=PlotCnt)));
    xlabel(xlabstr);
    set(gca,'DataAspectRatioMode','Manual')
end
colormap(gray(2))

%--- info printout ---
fprintf('Acquisition time (TR %.1f sec): %.0f sec / %.1f min\n',mrsiTR,encCntP*mrsiTR,encCntP*mrsiTR/60);
fprintf('%s successfully completed.\n',FCTNAME);

%--- update success flag ---
f_succ = 1;

end
