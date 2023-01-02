%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  function SP2_Batch_SerialLcm4Kelley_STEAM_metab
%%
%%  Serial LCModel analysis of Tecfidera data.
%% 
%%  Note that the function assumes a windows system.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag mm proc fm lcm data

analysisDir = 'C:\Users\juchem\publications\Yale\2016\MRS_Tecfidera\analysis\';                     % result directory, individual protons
studyCell   = {'hc2\hc2-1\PFC\hc2_1_pfc_STEAM_metab',...
               'hc2\hc2-2\PFC\hc2_2_pfc_STEAM_metab'};
f_mcs       = 1;
           
           
FCTNAME = 'SP2_Batch_SerialLcm4Kelley_STEAM_metab';

          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
studyN = length(studyCell);             % number of metabolite spin systems (incl. individual moeities)


%--- consistency checks ---
if ~SP2_CheckDirAccessR(analysisDir)
    return
end

%--- path handling  ---
studyCellFull = {};
spxProtCell   = {};
for sCnt = 1:studyN
    %--- study directories ---
    studyCellFull{sCnt} = [analysisDir studyCell{sCnt} '\']; 
    if ~SP2_CheckDirAccessR(studyCellFull{sCnt})
        return
    end
    
    %--- SPX protocols ---
    spxProtCell{sCnt} = [studyCellFull{sCnt} 'SPX.mat']; 
    if ~SP2_CheckFileExistenceR(spxProtCell{sCnt})
        return
    end
end

%--- check if INSPECTOR is open ---
if ~isfield(mm,'cut') || ~isfield(proc,'alignPolyOrder')
    INSPECTOR
end

%--- serial SPX LCModel analysis ---
for sCnt = 1:studyN
    %--- info printout ---
    fprintf('\n\nANALYSIS %.0f OF %.0f:\nProtocol: %s\n\n',sCnt,studyN,studyCell{sCnt})
    
    %--- protocol path handling ---
    SP2_Data_DataMain
    set(fm.data.protPath,'String',spxProtCell{sCnt})
    if ~SP2_Data_ProtocolPathUpdate
        return
    end
    if ~SP2_Data_ProtocolLoad
        return
    end
       
    %--- LCM page ---
    SP2_LCM_LCModelMain
    if ~SP2_LCM_SpecDataAndParsAssign
        return
    end
    if ~SP2_LCM_LcmBasisLoad
        return
    end
    
    %--- parameter handling ---
%     flag.lcmLinkLb = 1;
%     lcm.fit.lbMax  = 20*ones(1,lcm.fit.nLim);
%     set(fm.lcm.anaPolyOrder,'String','2')
%     if ~SP2_LCM_AnaPolyOrderUpdate
%         return
%     end
    

    %--- LCM calculation ---
    if ~SP2_LCM_AnaDoAnalysis(1)
        return
    end
    if ~SP2_LCM_AnaSaveXls
        return
    end
    if ~SP2_LCM_AnaSaveSummaryFigure
        return
    end
    if ~SP2_LCM_AnaSaveSuperposFigure
        return
    end
    if ~SP2_LCM_AnaSaveSpxFigures
        return
    end
    if ~SP2_LCM_AnaSaveCorrFigures
        return
    end
    
    %--- Monte-Carlo Simulation ---
    if f_mcs
        %--- general parameter settings ---
        flagLcmSaveJpeg  = flag.lcmSaveJpeg;
        flag.lcmSaveJpeg = 1;

        % set MC parameters
        set(fm.lcm.anaMCarloN,'String','100')
        SP2_LCM_MCarloNUpdate
        % lcm.mc.n = 100;
        
%         fm.lcm.anaMCarloN      = uicontrol('Style','Edit','Position', [20 155 40 20],'String',sprintf('%.0f',lcm.mc.n),...
%                                    'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_MCarloNUpdate',...
%                                    'TooltipString',sprintf('Number of Monte-Carlo computations'),'FontSize',pars.fontSize);
        
        % run MC simuation 
        if ~SP2_LCM_AnaDoMonteCarloInVivo 
            return
        end
        
        %--- restore parameter settings ---
        flag.lcmSaveJpeg  = flagLcmSaveJpeg;        
    end

    %--- update protocol file ---
    dataProtPathMat = data.protPathMat;
    SP2_Exit_ExitFct(data.protPathMat,0)
    INSPECTOR(dataProtPathMat)
end

%--- info printout ---
fprintf('%s completed.\n',FCTNAME)


