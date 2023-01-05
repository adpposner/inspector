%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisWinUpdate
%% 
%%  LCM basis window update
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm

FCTNAME = 'SP2_LCM_BasisWinUpdate';


%--- metabolite name ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n
        eval(['set(fm.lcm.basis.name' sprintf('%02i',mCnt) ',''String'',''-'');'])
    else
        eval(['set(fm.lcm.basis.name' sprintf('%02i',mCnt) ',''String'',''' lcm.basis.data{mCnt}{1} ''');'])
    end
end

% %--- T1 ---
% for mCnt = 1:lcm.basis.nLim
%     if mCnt>lcm.basis.n
%         eval(['set(fm.lcm.basis.t1' sprintf('%02i',mCnt) ',''String'',''-'');'])
%     else
%         eval(['set(fm.lcm.basis.t1' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.basis.data{mCnt}{2}) ''');'])
%     end
% end
% 
% %--- T2 ---
% for mCnt = 1:lcm.basis.nLim
%     if mCnt>lcm.basis.n
%         eval(['set(fm.lcm.basis.t2' sprintf('%02i',mCnt) ',''String'',''-'');'])
%     else
%         eval(['set(fm.lcm.basis.t2' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.3f',lcm.basis.data{mCnt}{3}) ''');'])
%     end
% end

%--- comment ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n
        eval(['set(fm.lcm.basis.com' sprintf('%02i',mCnt) ',''String'',''-'');'])
    else
        eval(['set(fm.lcm.basis.com' sprintf('%02i',mCnt) ',''String'',''' lcm.basis.data{mCnt}{5} ''');'])
    end
end

%--- show/assign/delete ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n
        eval(['set(fm.lcm.basis.show' sprintf('%02i',mCnt) ',''Enable'',''off'');'])
        eval(['set(fm.lcm.basis.assign' sprintf('%02i',mCnt) ',''Enable'',''off'');'])
        eval(['set(fm.lcm.basis.delete' sprintf('%02i',mCnt) ',''Enable'',''off'');'])
    else
        eval(['set(fm.lcm.basis.show' sprintf('%02i',mCnt) ',''Enable'',''on'');'])
        eval(['set(fm.lcm.basis.assign' sprintf('%02i',mCnt) ',''Enable'',''on'');'])
        eval(['set(fm.lcm.basis.delete' sprintf('%02i',mCnt) ',''Enable'',''on'');'])
    end
end

%--- reordering ---
for mCnt = 1:lcm.basis.nLim
    if mCnt>lcm.basis.n
        eval(['set(fm.lcm.basis.reorder' sprintf('%02i',mCnt) ',''String'',''-'');'])
    else
        eval(['set(fm.lcm.basis.reorder' sprintf('%02i',mCnt) ',''String'',''' sprintf('%.0f',lcm.basis.reorder(mCnt)) ''');'])
    end
end

%--- reference frequency ---
set(fm.lcm.basis.ppmCalib,'String',num2str(lcm.basis.ppmCalib))
