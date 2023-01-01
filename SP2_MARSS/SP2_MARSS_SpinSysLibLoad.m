%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_SpinSysLibLoad
%% 
%%  Function to load spin system library from file.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss flag fm

FCTNAME = 'SP2_MARSS_SpinSysLibLoad';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(marss.spinSys.libPath)
    return
end

%--- load data & parameters from file ---
load(marss.spinSys.libPath)

%--- consistency check ---
if ~iscell(metabList)
    fprintf('%s ->\nSelected spin system library file not valid. Program aborted.\n',FCTNAME)
    return
end
if isempty(metabList)
    fprintf('%s ->\nSelected spin system cell is empty. Program aborted.\n',FCTNAME)
    return
end


%--- retrieve details of spin system library ---
marss.spinSys.n        = length(metabList);
marss.spinSys.nameCell = {};
for mCnt = 1:marss.spinSys.n
    %--- check field existence ---
    if ~isfield(metabList{mCnt},'name')
    fprintf('%s ->\nSpin system %.0f lacks a ''name'' field. Program aborted.\n',FCTNAME)
    return
    end
    if ~isfield(metabList{mCnt},'numberOfProtons')
        fprintf('%s ->\nSpin system %.0f (%s) lacks a ''numberOfProtons'' field. Program aborted.\n',...
                FCTNAME,mCnt,metabList{mCnt}.name)
        return
    end
    if ~isfield(metabList{mCnt},'Omega')
        fprintf('%s ->\nSpin system %.0f (%s) lacks an ''Omega'' field. Program aborted.\n',...
                FCTNAME,mCnt,metabList{mCnt}.name)
        return
    end
    if ~isfield(metabList{mCnt},'J')
        fprintf('%s ->\nSpin system %.0f (%s) lacks a ''J'' field. Program aborted.\n',...
                FCTNAME,mCnt,metabList{mCnt}.name)
        return
    end
    
    %--- name field assignment ---
    marss.spinSys.nameCell{mCnt} = metabList{mCnt}.name;
    
    %--- verbose ---
    if flag.verbose
        fprintf('Spin system #%.0f: %s\n',mCnt,marss.spinSys.nameCell{mCnt});
        fprintf('Number of protons: %s\n',SP2_Vec2PrintStr(metabList{mCnt}.numberOfProtons,0))
        fprintf('Omega:\n')
        for oCnt = 1:length(metabList{mCnt}.Omega)
            if length(metabList{mCnt}.Omega{oCnt})>1
                fprintf('%.0f: %s\n',oCnt,SP2_Vec2PrintStr(metabList{mCnt}.Omega{oCnt},5))          
            else
                fprintf('%.0f: %.5f\n',oCnt,metabList{mCnt}.Omega{oCnt})          
            end
        end
        fprintf('J:\n')
        for jCnt = 1:length(metabList{mCnt}.J)
            if length(metabList{mCnt}.J{oCnt})>1
                jMat = metabList{mCnt}.J{oCnt};
                for jMatCnt = 1:length(metabList{mCnt}.J{oCnt})
                    fprintf('%.0f: %s\n',jCnt,SP2_Vec2PrintStr(jMat(jMatCnt,:),5))          
                end
            else
                fprintf('%.0f: %.5f\n',jCnt,metabList{mCnt}.J{oCnt})
            end
        end
        fprintf('\n')
    end
end

%--- update spin system library and basis selection ---
set(fm.marss.spinSysBox,'String',marss.spinSys.nameCell,'Value',[]);

%--- info printout ---
fprintf('\nLibrary of spin systems loaded from\n%s\n',marss.spinSys.libPath)
fprintf('# of metabolites:  %.0f\n',marss.spinSys.n)

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;

