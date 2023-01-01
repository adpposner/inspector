%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitSelectUpdate(nMetab)
%% 
%%  Include/exclude individual metabolite in/from LCM analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab)
    return
end

%--- disable metabolites that exceed the basis size ---
lcm.fit.select((1:lcm.basis.nLim)>lcm.basis.n) = 0;

%--- update selection vector ---
if nMetab>lcm.basis.n
    eval(['lcm.fit.select(' num2str(nMetab) ') = 0;'])
else
    eval(['lcm.fit.select(' num2str(nMetab) ') = get(fm.lcm.fit.select' sprintf('%02i',nMetab) ',''Value'');'])
end

%--- update applied vector ---
lcm.fit.applied  = find(lcm.fit.select);
lcm.fit.appliedN = length(lcm.fit.applied);
 
%--- update window ---
SP2_LCM_FitDetailsWinUpdate