%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MRSI_CreateRectAndCircEncScheme
%% 
%%  Export function (temporal) spectral data.
%%
%%  xxxR: t1, inner loop
%%  xxxP: t2, outer loop
%%
%%  03-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_CreateRectAndCircEncScheme';


%--- MRSI definition ---
mrsiMatrix      = 25;
mrsiCircOffset  = 0.2;

%--- file handling ---
tabdir = 'C:\Users\juchem\Matlab\matlab_cj\INSPECTOR_v2\SP2_MRSI\SP2_MRSI_TablibTmp\';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   P R O G R A M    S T A R T                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- index vector ---
indVec = -floor(mrsiMatrix/2):round(mrsiMatrix/2-1);

%--- file creation ---
fileRectR = sprintf('%sRectangular_R.txt',tabdir);
fileRectP = sprintf('%sRectangular_P.txt',tabdir);
[unitRectR,msg] = fopen(fileRectR,'w');
if unitRectR==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end
[unitRectP,msg] = fopen(fileRectP,'w');
if unitRectP==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end
fileCircR = sprintf('%sCircular_R.txt',tabdir);
fileCircP = sprintf('%sCircular_P.txt',tabdir);
[unitCircR,msg] = fopen(fileCircR,'w');
if unitCircR==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end
[unitCircP,msg] = fopen(fileCircP,'w');
if unitCircP==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end

%--- table creation ---
rectCnt = 0;
circCnt = 0;
fprintf(unitRectR,'t1 =\n');
fprintf(unitRectP,'t2 =\n');
fprintf(unitCircR,'t1 =\n');
fprintf(unitCircP,'t2 =\n');
for pCnt = 1:mrsiMatrix
    for rCnt = 1:mrsiMatrix
        %--- rectangular scheme ---
        rectCnt = rectCnt + 1;
        fprintf(unitRectR,'%.0f\n',indVec(rCnt));
        fprintf(unitRectP,'%.0f\n',indVec(pCnt));
        
        %--- circular scheme ---
        if sqrt(indVec(pCnt)^2+indVec(rCnt)^2)<=(mrsiMatrix-1)/2+mrsiCircOffset
            circCnt = circCnt + 1;
            fprintf(unitCircR,'%.0f\n',indVec(rCnt));
            fprintf(unitCircP,'%.0f\n',indVec(pCnt));
%             fprintf(unitCircR,'%.0f\n',indVec(rCnt));       % double entries
%             fprintf(unitCircP,'%.0f\n',indVec(pCnt));       % double entries
        end
    end
end
fclose(unitRectR);
fclose(unitRectP);
fclose(unitCircR);
fclose(unitCircP);

%--- rename files to include geometry specs ---
movefile(fileRectR,sprintf('%sRectangular%02.0fx%02.0fN%.0f_R.txt',tabdir,mrsiMatrix,mrsiMatrix,rectCnt));
movefile(fileRectP,sprintf('%sRectangular%02.0fx%02.0fN%.0f_P.txt',tabdir,mrsiMatrix,mrsiMatrix,rectCnt));
movefile(fileCircR,sprintf('%sCircular%02.0fx%02.0fN%.0f_R.txt',tabdir,mrsiMatrix,mrsiMatrix,circCnt));
movefile(fileCircP,sprintf('%sCircular%02.0fx%02.0fN%.0f_P.txt',tabdir,mrsiMatrix,mrsiMatrix,circCnt));

%--- info printout ---
fprintf('Rectangular steps: %.0f\n',rectCnt);
fprintf('Circular steps:    %.0f\n',circCnt);
fprintf('%s successfully completed.\n',FCTNAME);

%--- update success flag ---
f_succ = 1;

end
