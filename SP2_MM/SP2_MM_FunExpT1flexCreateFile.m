%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MM_FunExpT1flexCreateFile(fileDir,fileName,fitDim)
%% 
%%  Automatic creation of fitting function file with flexible T1's.
%%
%%  10-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MM_FunExpT1flexCreateFile';


%--- init success flag ---
f_succ = 0;

%--- check directory access ---
if ~SP2_CheckDirAccessR(fileDir)
    return
end
   
%--- file creation ---
filePath = [fileDir fileName '.m'];
[unit,msg] = fopen(filePath,'w');
if unit==-1
    fprintf('%s ->\nFile opening failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end

fprintf(unit,'%%\n');
fprintf(unit,'%% Automatically generated fit function\n');
fprintf(unit,'%% created %s\n',datestr(now));
fprintf(unit,'%%\n');
fprintf(unit,'function f = %s(a,x)\n\n',fileName);
for dimCnt = 1:2:2*fitDim
    if dimCnt==1                        % first run
        if dimCnt==2*fitDim-1           
            fprintf(unit,'f = a(1) * (1 - exp(-x/a(2)));\n');      % single case
        else
            fprintf(unit,'f = a(1) * (1 - exp(-x/a(2))) + ...\n');
        end
    else                                % all later runs
        if dimCnt==2*fitDim-1
            fprintf(unit,'    a(%.0f) * (1 - exp(-x/a(%.0f)));\n',dimCnt,dimCnt+1);
        else
            fprintf(unit,'    a(%.0f) * (1 - exp(-x/a(%.0f))) + ...\n',dimCnt,dimCnt+1);
        end
    end
end
fclose(unit);

%--- info printout ---
fprintf('File <%s.m> created.\n',fileName)
    
%--- update success flag ---
f_succ = 1;
