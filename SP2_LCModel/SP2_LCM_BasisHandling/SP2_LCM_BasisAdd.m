%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_LCM_BasisAdd
%% 
%%  Function to add metabolite to LCM basis set.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm fm

FCTNAME = 'SP2_LCM_BasisAdd';


%--- init success flag ---
f_done = 0;

%--- consistency check ---
if lcm.basis.n+1>lcm.basis.nLim
    fprintf('Maximum number of basis functions reached.\nFurther extension is not allowed.\n');
    return
end

%--- (generic) duplicate of last metabolite ---
if isnumeric(lcm.basis.data) || lcm.basis.n==0          % start new basis, init lcm.basis.data with 0 value || all previous fields removed
    lcm.basis.data = {};
    lcm.basis.n    = 1;
    lcm.basis.data{lcm.basis.n}{1} = 'metab';       
    lcm.basis.data{lcm.basis.n}{2} = 1.5;       
    lcm.basis.data{lcm.basis.n}{3} = 0.025;
    if isfield(lcm,'nspecC')
        lcm.basis.data{lcm.basis.n}{4} = complex(zeros(lcm.nspecC,1));
    else
        lcm.basis.data{lcm.basis.n}{4} = complex(zeros(16384,1));
    end
    lcm.basis.data{lcm.basis.n}{5} = '';
    lcm.basis.reorder(1)           = 1;
else                                                    % extend existing basis
    nFields = length(lcm.basis.data{1});                % number of fields
    for fCnt = 1:nFields                                % array fields
        lcm.basis.data{lcm.basis.n+1}{fCnt} = lcm.basis.data{lcm.basis.n}{fCnt};
    end

    %--- parameter update ---
    lcm.basis.n       = length(lcm.basis.data);         % number of metabolites
    lcm.basis.reorder = 1:lcm.basis.n;                  % init reordering vector

    %--- remove previous data ---
    lcm.basis.data{lcm.basis.n}{1} = 'metab';       
    lcm.basis.data{lcm.basis.n}{4} = 0*lcm.basis.data{lcm.basis.n}{4};
end

%--- window update ---
SP2_LCM_BasisWinUpdate

%--- add analysis flag ---
lcm.fit.select(lcm.basis.n) = 0;                    % note that the fit default is OFF
lcm.fit.applied  = find(lcm.fit.select);
lcm.fit.appliedN = length(lcm.fit.applied);

%--- basic assessment ---
lcm.basis.ptsMin    = 1e6;                          % length of shortest FID
lcm.basis.ptsMax    = 0;                            % length of longest FID
lcm.basis.fidLength = zeros(1,lcm.basis.n);         % metabolite-specific FID length
lcm.basis.reorder   = 1:lcm.basis.n;                % init reordering vector
for bCnt = 1:lcm.basis.n
    % FID length
    lcm.basis.fidLength(bCnt) = length(lcm.basis.data{bCnt}{4});
    
    % update shortest
    if lcm.basis.fidLength(bCnt)<lcm.basis.ptsMin
        lcm.basis.ptsMin = lcm.basis.fidLength(bCnt);
    end
    
    % update longest
    if lcm.basis.fidLength(bCnt)>lcm.basis.ptsMax
        lcm.basis.ptsMax = lcm.basis.fidLength(bCnt);
    end
end

%--- info printout ---
fprintf('\nBasis set characteristics:\n');
fprintf('1) # of metabolites:  %.0f\n',lcm.basis.n);
fprintf('2) sweep width:       %.1f Hz\n',lcm.basis.sw_h);
fprintf('3) Larmor frequency:  %.3f MHz\n',lcm.basis.sf);
fprintf('4) reference frequ.:  %.3f ppm\n',lcm.basis.ppmCalib);
fprintf('5) Shortest FID:      %.0f pts\n',lcm.basis.ptsMin);
fprintf('6) Longest FID:       %.0f pts\n\n',lcm.basis.ptsMax);

%--- update analysis detail window ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end

%--- update success flag ---
f_done = 1;

