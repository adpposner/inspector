%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  function SP2_Batch_SerialLcm4Tecfidera_JDE_metab
%%
%%  Serial LCModel analysis of Tecfidera data.
%% 
%%  Note that the function assumes a windows system.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag mm proc fm lcm data

analysisDir = 'C:\Users\juchem\publications\Yale\2016\MRS_Tecfidera\analysis\';                 % result directory, individual protons
studyCell   = {'hc2\hc2-1\PFC\hc2_1_pfc_JDE_metab','hc2\hc2-2\PFC\hc2_2_pfc_JDE_metab',...      % hc2
               'hc3\hc3-1\PFC\hc3_1_pfc_JDE_metab','hc3\hc3-2\PFC\hc3_2_pfc_JDE_metab',...      % hc3
               'hc4\hc4-1\PFC\hc4_1_pfc_JDE_metab','hc4\hc4-2\PFC\hc4_2_pfc_JDE_metab',...      % hc4
               'hc5\hc5-1\PFC\hc5_1_pfc_JDE_metab','hc5\hc5-2\PFC\hc5_2_pfc_JDE_metab',...      % hc5
               'hc6\hc6-1\PFC\hc6_1_pfc_JDE_metab','hc6\hc6-2_v2\PFC\hc6_2_pfc_JDE_metab',...   % hc6
               'hc7\hc7-1\PFC\hc7_1_pfc_JDE_metab','hc7\hc7-2\PFC\hc7_2_pfc_JDE_metab',...      % hc7
               'hc8\hc8-1\PFC\hc8_1_pfc_JDE_metab','hc8\hc8-2\PFC\hc8_2_pfc_JDE_metab',...      % hc8
               'hc9\hc9-1\PFC\hc9_1_pfc_JDE_metab','hc9\hc9-2\PFC\hc9_2_pfc_JDE_metab',...      % hc9
               'tf1\tf1-1\PFC\tf1_1_pfc_JDE_metab','tf1\tf1-2\PFC\tf1_2_pfc_JDE_metab',...      % tf1
               'tf1\tf1-3\PFC\tf1_3_pfc_JDE_metab','tf1\tf1-4\PFC\tf1_4_pfc_JDE_metab',...
               'tf1\tf1-5\PFC\tf1_5_pfc_JDE_metab',...
               'tf2\tf2-1\PFC\tf2_1_pfc_JDE_metab','tf2\tf2-2\PFC\tf2_2_pfc_JDE_metab',...      % tf2
               'tf2\tf2-3\PFC\tf2_3_pfc_JDE_metab','tf2\tf2-4\PFC\tf2_4_pfc_JDE_metab',...
               'tf2\tf2-5\PFC\tf2_5_pfc_JDE_metab',...
               'tf3\tf3-1\PFC\tf3_1_pfc_JDE_metab','tf3\tf3-2\PFC\tf3_2_pfc_JDE_metab',...      % tf3
               'tf3\tf3-3\PFC\tf3_3_pfc_JDE_metab','tf3\tf3-4\PFC\tf3_4_pfc_JDE_metab',...
               'tf3\tf3-5\PFC\tf3_5_pfc_JDE_metab',...      
               'tf5\tf5-1\PFC\tf5_1_pfc_JDE_metab','tf5\tf5-2\PFC\tf5_2_pfc_JDE_metab',...      % tf5
               'tf5\tf5-3\PFC\tf5_3_pfc_JDE_metab','tf5\tf5-4\PFC\tf5_4_pfc_JDE_metab',...
               'tf5\tf5-5\PFC\tf5_5_pfc_JDE_metab',...
               'tf6\tf6-1\PFC\tf6_1_pfc_JDE_metab','tf6\tf6-2_v2\PFC\tf6_2_pfc_JDE_metab',...   % tf6
               'tf6\tf6-3\PFC\tf6_3_pfc_JDE_metab','tf6\tf6-4\PFC\tf6_4_pfc_JDE_metab',...
               'tf6\tf6-5\PFC\tf6_5_pfc_JDE_metab',...
               'tf7\tf7-1\PFC\tf7_1_pfc_JDE_metab','tf7\tf7-2\PFC\tf7_2_pfc_JDE_metab',...      % tf7
               'tf7\tf7-3\PFC\tf7_3_pfc_JDE_metab','tf7\tf7-4\PFC\tf7_4_pfc_JDE_metab',...
               'tf8\tf8-1\PFC\tf8_1_pfc_JDE_metab','tf8\tf8-2\PFC\tf8_2_pfc_JDE_metab',...      % tf8
               'tf8\tf8-3\PFC\tf8_3_pfc_JDE_metab','tf8\tf8-4\PFC\tf8_4_pfc_JDE_metab',...
               'tf8\tf8-5\PFC\tf8_5_pfc_JDE_metab'};
           
           
FCTNAME = 'SP2_Batch_SerialLcm4Tecfidera_JDE_metab';

          
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
    flag.lcmLinkLb = 1;
    lcm.fit.lbMax  = 20*ones(1,lcm.fit.nLim);
    
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
    if ~SP2_LCM_AnaSaveSpxFigures
        return
    end
    if ~SP2_LCM_AnaSaveCorrFigures
        return
    end

    %--- update protocol file ---
    dataProtPathMat = data.protPathMat;
    SP2_Exit_ExitFct(data.protPathMat,0)
    INSPECTOR(dataProtPathMat)
end

%--- info printout ---
fprintf('%s completed.\n',FCTNAME)


