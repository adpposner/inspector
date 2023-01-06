%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitDetailsWinUpdate
%% 
%%  Update function of LCM fitting details.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm pars flag

FCTNAME = 'SP2_LCM_FitDetailsWinUpdate';


%--- check existence of window ---
if ~isfield(fm,'lcm')
    return
end
if ~isfield(fm.lcm,'fit')
    return
end

%--- consistency check ---
lcm.anaLb    = min(max(lcm.fit.lbMin,lcm.anaLb),lcm.fit.lbMax);
lcm.anaGb    = min(max(lcm.fit.gbMin,lcm.anaGb),lcm.fit.gbMax);
lcm.anaShift = min(max(lcm.fit.shiftMin,lcm.anaShift),lcm.fit.shiftMax);

%--- absolute metabolite counter
for mCnt = 1:lcm.fit.nLim
    if mCnt<=lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['set(fm.lcm.fit.mCnt' sprintf('%02i',mCnt) ',''String'',''' sprintf('(%.02i)',mCnt) ''',' ...
                 '''Color'',pars.fgTextColor);'])
        else
            eval(['set(fm.lcm.fit.mCnt' sprintf('%02i',mCnt) ',''String'',''' sprintf('(%.02i)',mCnt) ''',' ...
                 '''Color'',pars.bgTextColor);'])
        end
    else
        eval(['set(fm.lcm.fit.mCnt' sprintf('%02i',mCnt) ',''String'',''' sprintf(' ') ''',' ...
             '''Color'',pars.bgTextColor);'])
    end
end

%--- metabolite name ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                 % no basis function
        eval(['set(fm.lcm.fit.name' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Color'',' SP2_Vec2PrintStr(pars.bgTextColor) ');'])
    elseif lcm.fit.select(mCnt)         % selected
        eval(['set(fm.lcm.fit.name' sprintf('%02i',mCnt) ',''String'',''' SP2_PrVersionUscore(lcm.basis.data{mCnt}{1}) ''',' ...
              '''Color'',' SP2_Vec2PrintStr(pars.fgTextColor) ');'])
    else                                % not selected
        eval(['set(fm.lcm.fit.name' sprintf('%02i',mCnt) ',''String'',''' SP2_PrVersionUscore(lcm.basis.data{mCnt}{1}) ''',' ...
              '''Color'',' SP2_Vec2PrintStr(pars.bgTextColor) ');'])
    end
end

%--- selection counter ---
sCnt = 0;       % select counter
for mCnt = 1:lcm.fit.nLim
    if lcm.fit.select(mCnt)
        sCnt = sCnt+1;
        eval(['set(fm.lcm.fit.count' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.02i:',sCnt) ''',' ...
              '''Color'',pars.fgTextColor);'])
    else
        eval(['set(fm.lcm.fit.count' sprintf('%02i',mCnt) ',''String'','' -'',' ...
              '''Color'',pars.bgTextColor);'])
    end
end

%--- metabolite selection flags ---
for mCnt = 1:lcm.basis.nLim
    eval(['set(fm.lcm.fit.select' sprintf('%02i',mCnt) ',''Value'',lcm.fit.select(' num2str(mCnt) '));'])
end

%--- minimum Lorentzian line broadening ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.lbMin' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaLb        % selected
        eval(['set(fm.lcm.fit.lbMin' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.lbMin(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.lbMin' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.lbMin(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- current Lorentzian line broadening ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.anaLb' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaLb        % selected
        eval(['set(fm.lcm.fit.anaLb' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.anaLb(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.anaLb' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.anaLb(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- maximum Lorentzian line broadening ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.lbMax' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaLb        % selected
        eval(['set(fm.lcm.fit.lbMax' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.lbMax(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.lbMax' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.lbMax(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- minimum Gaussian line broadening ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.gbMin' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaGb        % selected
        eval(['set(fm.lcm.fit.gbMin' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.gbMin(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.gbMin' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.gbMin(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- current Gaussian line broadening ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.anaGb' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaGb        % selected
        eval(['set(fm.lcm.fit.anaGb' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.anaGb(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.anaGb' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.anaGb(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- maximum Gaussian line broadening ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.gbMax' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaGb        % selected
        eval(['set(fm.lcm.fit.gbMax' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.gbMax(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.gbMax' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.gbMax(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- minimum frequency shift ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.shiftMin' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaShift     % selected
        eval(['set(fm.lcm.fit.shiftMin' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.shiftMin(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.shiftMin' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.shiftMin(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- current frequency shift ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.anaShift' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaShift     % selected
        eval(['set(fm.lcm.fit.anaShift' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.anaShift(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.anaShift' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.anaShift(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- maximum frequency shift ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.shiftMax' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt) && flag.lcmAnaShift     % selected
        eval(['set(fm.lcm.fit.shiftMax' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.shiftMax(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.shiftMax' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.shiftMax(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end

%--- last / link LB buttons ---
if flag.lcmAnaLb            % selected
    set(fm.lcm.fit.lbMinLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.lbAnaLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.lbMaxLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.lbMinLast,'Enable','on')
    set(fm.lcm.fit.anaLbLast,'Enable','on')
    set(fm.lcm.fit.lbMaxLast,'Enable','on')
    set(fm.lcm.fit.anaLbReset,'Enable','on')
    set(fm.lcm.fit.linkLb,'Enable','on')
else                        % disabled
    set(fm.lcm.fit.lbMinLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.lbAnaLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.lbMaxLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.lbMinLast,'Enable','off')
    set(fm.lcm.fit.anaLbLast,'Enable','off')
    set(fm.lcm.fit.lbMaxLast,'Enable','off')
    set(fm.lcm.fit.anaLbReset,'Enable','off')
    set(fm.lcm.fit.linkLb,'Enable','off')
end

%--- last / link GB buttons ---
if flag.lcmAnaGb            % selected
    set(fm.lcm.fit.gbMinLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.gbAnaLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.gbMaxLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.gbMinLast,'Enable','on')
    set(fm.lcm.fit.anaGbLast,'Enable','on')
    set(fm.lcm.fit.gbMaxLast,'Enable','on')
    set(fm.lcm.fit.anaGbReset,'Enable','on')
    set(fm.lcm.fit.linkGb,'Enable','on')
else                        % disabled
    set(fm.lcm.fit.gbMinLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.gbAnaLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.gbMaxLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.gbMinLast,'Enable','off')
    set(fm.lcm.fit.anaGbLast,'Enable','off')
    set(fm.lcm.fit.gbMaxLast,'Enable','off')
    set(fm.lcm.fit.anaGbReset,'Enable','off')
    set(fm.lcm.fit.linkGb,'Enable','off')
end

%--- last / link shift buttons ---
if flag.lcmAnaShift         % selected
    set(fm.lcm.fit.shiftMinLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.shiftAnaLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.shiftMaxLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.shiftMinLast,'Enable','on')
    set(fm.lcm.fit.anaShiftLast,'Enable','on')
    set(fm.lcm.fit.shiftMaxLast,'Enable','on')
    set(fm.lcm.fit.anaShiftReset,'Enable','on')
    set(fm.lcm.fit.linkShift,'Enable','on')
else                        % disabled
    set(fm.lcm.fit.shiftMinLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.shiftAnaLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.shiftMaxLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.shiftMinLast,'Enable','off')
    set(fm.lcm.fit.anaShiftLast,'Enable','off')
    set(fm.lcm.fit.shiftMaxLast,'Enable','off')
    set(fm.lcm.fit.anaShiftReset,'Enable','off')
    set(fm.lcm.fit.linkShift,'Enable','off')
end


% %--- frequency variation ---
% for mCnt = 1:lcm.basis.nLim
%     if mCnt>lcm.basis.n                                 % no basis function
%         eval(['set(fm.lcm.fit.frequVar' sprintf('%02i',mCnt) ',''String'',''-'',' ...
%               '''Enable'',''Off'');'])
%     elseif lcm.fit.select(mCnt) && flag.lcmAnaShift     % selected
%         eval(['set(fm.lcm.fit.frequVar' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.frequVar(mCnt)) ''',' ...
%               '''Enable'',''On'');'])
%     else                                                % not selected
%         eval(['set(fm.lcm.fit.frequVar' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.2f',lcm.fit.frequVar(mCnt)) ''',' ...
%               '''Enable'',''Off'');'])
%     end
% end
% 
% %--- current frequency shift ---
% for mCnt = 1:lcm.basis.nLim
%     if mCnt>lcm.basis.n                                 % no basis function
%         eval(['set(fm.lcm.fit.anaShift' sprintf('%02i',mCnt) ',''String'',''-'',' ...
%               '''Enable'',''Off'');'])
%     elseif lcm.fit.select(mCnt) && flag.lcmAnaShift     % selected
%         eval(['set(fm.lcm.fit.anaShift' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.anaShift(mCnt)) ''',' ...
%               '''Enable'',''On'');'])
%     else                                                % not selected
%         eval(['set(fm.lcm.fit.anaShift' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.anaShift(mCnt)) ''',' ...
%               '''Enable'',''Off'');'])
%     end
% end

%--- current scaling ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n                                 % no basis function
        eval(['set(fm.lcm.fit.anaScale' sprintf('%02i',mCnt) ',''String'',''-'',' ...
              '''Enable'',''Off'');'])
    elseif lcm.fit.select(mCnt)                         % selected
        eval(['set(fm.lcm.fit.anaScale' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.4f',lcm.anaScale(mCnt)) ''',' ...
              '''Enable'',''On'');'])
    else                                                % not selected
        eval(['set(fm.lcm.fit.anaScale' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.4f',lcm.anaScale(mCnt)) ''',' ...
              '''Enable'',''Off'');'])
    end
end


%--- combinations ---
if flag.lcmComb1
    set(fm.lcm.fit.comb1Str,'Enable','on')
else
    set(fm.lcm.fit.comb1Str,'Enable','off')
end
if flag.lcmComb2
    set(fm.lcm.fit.comb2Str,'Enable','on')
else
    set(fm.lcm.fit.comb2Str,'Enable','off')
end
if flag.lcmComb3
    set(fm.lcm.fit.comb3Str,'Enable','on')
else
    set(fm.lcm.fit.comb3Str,'Enable','off')
end


%--- variation ranges (for assignment) --- 
if flag.lcmAnaLb || flag.lcmAnaGb || flag.lcmAnaShift
    set(fm.lcm.fit.anaVarLab,'Color',pars.fgTextColor)
else
    set(fm.lcm.fit.anaVarLab,'Color',pars.bgTextColor)
end
if flag.lcmAnaLb
    set(fm.lcm.fit.anaLbVarMinLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.anaLbVarMin,'Enable','on')
    set(fm.lcm.fit.anaLbVarMinApply,'Enable','on')
    set(fm.lcm.fit.anaLbVarMaxLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.anaLbVarMax,'Enable','on')
    set(fm.lcm.fit.anaLbVarMaxApply,'Enable','on')
else
    set(fm.lcm.fit.anaLbVarMinLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.anaLbVarMin,'Enable','off')
    set(fm.lcm.fit.anaLbVarMinApply,'Enable','off')
    set(fm.lcm.fit.anaLbVarMaxLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.anaLbVarMax,'Enable','off')
    set(fm.lcm.fit.anaLbVarMaxApply,'Enable','off')
end
if flag.lcmAnaGb
    set(fm.lcm.fit.anaGbVarMinLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.anaGbVarMin,'Enable','on')
    set(fm.lcm.fit.anaGbVarMinApply,'Enable','on')
    set(fm.lcm.fit.anaGbVarMaxLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.anaGbVarMax,'Enable','on')
    set(fm.lcm.fit.anaGbVarMaxApply,'Enable','on')        
else
    set(fm.lcm.fit.anaGbVarMinLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.anaGbVarMin,'Enable','off')
    set(fm.lcm.fit.anaGbVarMinApply,'Enable','off')
    set(fm.lcm.fit.anaGbVarMaxLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.anaGbVarMax,'Enable','off')
    set(fm.lcm.fit.anaGbVarMaxApply,'Enable','off')
end
if flag.lcmAnaShift                                       
    set(fm.lcm.fit.anaShiftVarMinLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.anaShiftVarMin,'Enable','on')
    set(fm.lcm.fit.anaShiftVarMinApply,'Enable','on')
    set(fm.lcm.fit.anaShiftVarMaxLab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.anaShiftVarMax,'Enable','on')
    set(fm.lcm.fit.anaShiftVarMaxApply,'Enable','on')
else    
    set(fm.lcm.fit.anaShiftVarMinLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.anaShiftVarMin,'Enable','off')
    set(fm.lcm.fit.anaShiftVarMinApply,'Enable','off')
    set(fm.lcm.fit.anaShiftVarMaxLab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.anaShiftVarMax,'Enable','off')
    set(fm.lcm.fit.anaShiftVarMaxApply,'Enable','off')
end

%--- polynomial baseline: parameter update ---
set(fm.lcm.fit.polyAmp0,'String',sprintf('%.1f',lcm.anaPolyCoeff(11)))
set(fm.lcm.fit.polyAmp1,'String',sprintf('%.1f',lcm.anaPolyCoeff(10)))
set(fm.lcm.fit.polyAmp2,'String',sprintf('%.1f',lcm.anaPolyCoeff(9)))
set(fm.lcm.fit.polyAmp3,'String',sprintf('%.1f',lcm.anaPolyCoeff(8)))
set(fm.lcm.fit.polyAmp4,'String',sprintf('%.1f',lcm.anaPolyCoeff(7)))
set(fm.lcm.fit.polyAmp5,'String',sprintf('%.1f',lcm.anaPolyCoeff(6)))

%--- polynomial baseline: field/button handling ---
if flag.lcmAnaPoly                                      % 0 order
    set(fm.lcm.fit.polyAmp0Lab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.polyAmp0,'Enable','on')
    set(fm.lcm.fit.polyAmp0Reset,'Enable','on')
    set(fm.lcm.fit.polyAmpAllReset,'Enable','on') 
else
    set(fm.lcm.fit.polyAmp0Lab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.polyAmp0,'Enable','off')
    set(fm.lcm.fit.polyAmp0Reset,'Enable','off') 
    set(fm.lcm.fit.polyAmpAllReset,'Enable','off') 
end
if flag.lcmAnaPoly && lcm.anaPolyOrder>0                % 1st order
    set(fm.lcm.fit.polyAmp1Lab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.polyAmp1,'Enable','on')
    set(fm.lcm.fit.polyAmp1Reset,'Enable','on')
else
    set(fm.lcm.fit.polyAmp1Lab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.polyAmp1,'Enable','off')
    set(fm.lcm.fit.polyAmp1Reset,'Enable','off')
end
if flag.lcmAnaPoly && lcm.anaPolyOrder>1                % 2nd order
    set(fm.lcm.fit.polyAmp2Lab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.polyAmp2,'Enable','on')
    set(fm.lcm.fit.polyAmp2Reset,'Enable','on')
else
    set(fm.lcm.fit.polyAmp2Lab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.polyAmp2,'Enable','off')
    set(fm.lcm.fit.polyAmp2Reset,'Enable','off')
end
if flag.lcmAnaPoly && lcm.anaPolyOrder>2                % 3rd order
    set(fm.lcm.fit.polyAmp3Lab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.polyAmp3,'Enable','on')
    set(fm.lcm.fit.polyAmp3Reset,'Enable','on')
else
    set(fm.lcm.fit.polyAmp3Lab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.polyAmp3,'Enable','off')
    set(fm.lcm.fit.polyAmp3Reset,'Enable','off')
end
if flag.lcmAnaPoly && lcm.anaPolyOrder>3                % 4th order
    set(fm.lcm.fit.polyAmp4Lab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.polyAmp4,'Enable','on')
    set(fm.lcm.fit.polyAmp4Reset,'Enable','on')
else
    set(fm.lcm.fit.polyAmp4Lab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.polyAmp4,'Enable','off')
    set(fm.lcm.fit.polyAmp4Reset,'Enable','off')
end
if flag.lcmAnaPoly && lcm.anaPolyOrder>4                % 5th order
    set(fm.lcm.fit.polyAmp5Lab,'Color',pars.fgTextColor)
    set(fm.lcm.fit.polyAmp5,'Enable','on')
    set(fm.lcm.fit.polyAmp5Reset,'Enable','on')
else
    set(fm.lcm.fit.polyAmp5Lab,'Color',pars.bgTextColor)
    set(fm.lcm.fit.polyAmp5,'Enable','off')
    set(fm.lcm.fit.polyAmp5Reset,'Enable','off')
end

%--- PHC0 ---
set(fm.lcm.fit.phc0,'String',sprintf('%.1f',lcm.anaPhc0))
if flag.lcmAnaPhc0
    set(fm.lcm.fit.phc0,'Enable','on')
    set(fm.lcm.fit.phc0Reset,'Enable','on')
else
    set(fm.lcm.fit.phc0,'Enable','off')
    set(fm.lcm.fit.phc0Reset,'Enable','off')
end

%--- PHC1 ---
set(fm.lcm.fit.phc1,'String',sprintf('%.1f',lcm.anaPhc1))
if flag.lcmAnaPhc1
    set(fm.lcm.fit.phc1,'Enable','on')
    set(fm.lcm.fit.phc1Reset,'Enable','on')
else
    set(fm.lcm.fit.phc1,'Enable','off')
    set(fm.lcm.fit.phc1Reset,'Enable','off')
end

%--- (selected) flag update of LCM parameter selection ---    
set(fm.lcm.fit.lb,'Value',flag.lcmAnaLb)
set(fm.lcm.fit.gb,'Value',flag.lcmAnaGb)
set(fm.lcm.fit.shift,'Value',flag.lcmAnaShift)
set(fm.lcm.fit.polynomial,'Value',flag.lcmAnaPoly)
set(fm.lcm.fit.phc0Flag,'Value',flag.lcmAnaPhc0)
set(fm.lcm.fit.phc1Flag,'Value',flag.lcmAnaPhc1)
















end
