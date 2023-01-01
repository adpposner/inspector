%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MM_FunExpT1fixCreateFile(fileDir,fileName,fitDim)
%% 
%%  Automatic creation of fitting function file.
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MM_FunExpT1fixCreateFile';


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
fprintf(unit,'global mm\n\n');
for dimCnt = 1:fitDim
    if dimCnt==1                    % 1st run
        if dimCnt==fitDim           % single case
            fprintf(unit,'f = a(1) * (1 - exp(-x/mm.anaTOne(1)));\n');
        else                        % all other cases
            fprintf(unit,'f = a(1) * (1 - exp(-x/mm.anaTOne(1))) + ...\n');
        end
    else                            % all other runs
    	if dimCnt==fitDim
            fprintf(unit,'    a(%.0f) * (1 - exp(-x/mm.anaTOne(%.0f)));\n',dimCnt,dimCnt);
        else
            fprintf(unit,'    a(%.0f) * (1 - exp(-x/mm.anaTOne(%.0f))) + ...\n',dimCnt,dimCnt);
        end
    end
end
fclose(unit);

%--- info printout ---
fprintf('File <%s.m> created.\n',fileName)
    
%--- update success flag ---
f_succ = 1;
