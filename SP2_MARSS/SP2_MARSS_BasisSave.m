%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_BasisSave
%% 
%%  Save basis to file.
%%
%%  11-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss

FCTNAME = 'SP2_MARSS_BasisSave';


%--- init success flag ---
f_succ = 0;

%--- basis structure assignment for export ---
lcmBasis = {};
for bCnt = 1:marss.basis.n
    lcmBasis.data{bCnt}{1} = marss.basis.metabNames{bCnt};       % metab name
    lcmBasis.data{bCnt}{2} = 1.500;                             % T1 (random init, not used)
    lcmBasis.data{bCnt}{3} = 0.025;                             % T2 (random init, not used)
    lcmBasis.data{bCnt}{4} = marss.basis.fidOrig(:,bCnt);       % FID
    lcmBasis.data{bCnt}{5} = '';                                % comment
end
lcmBasis.sw_h       = marss.basis.sw_h;
lcmBasis.sf         = marss.basis.sf;
lcmBasis.ppmCalib   = marss.basis.ppmCalib;    

%--- combine GlucoseA/GlucoseB ---
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
if any(cellfun(cellfind('GlcA'),marss.basis.metabNames)) && any(cellfun(cellfind('GlcB'),marss.basis.metabNames)) && ...
   ~any(cellfun(cellfind('Glc'),marss.basis.metabNames))
    %--- index handling ---
    GlcAInd = find(cellfun(cellfind('GlcA'),marss.basis.metabNames));
    GlcBInd = find(cellfun(cellfind('GlcB'),marss.basis.metabNames));

    %--- replace GlucoseA by weighted sum and rename ---
    lcmBasis.data{GlcAInd}{4} = 0.36*lcmBasis.data{GlcAInd}{4} + 0.64*lcmBasis.data{GlcBInd}{4};
    lcmBasis.data{GlcAInd}{1} = 'Glc';
    lcmBasis.data{GlcAInd}{5} = '0.36*GlcA + 0.64*GlcB';

    %--- remove GlcB ---
    lcmBasisData = {};
    nFields        = length(lcmBasis.data{1});    % number of fields
    for mCnt = 1:marss.basis.n                      % metabolites
        if mCnt<GlcBInd
            for fCnt = 1:nFields                    % array fields
                lcmBasisData{mCnt}{fCnt} = lcmBasis.data{mCnt}{fCnt};
            end
        elseif mCnt>GlcBInd
            for fCnt = 1:nFields                    % array fields
                lcmBasisData{mCnt-1}{fCnt} = lcmBasis.data{mCnt}{fCnt};
            end
        end
    end
    lcmBasis.data = lcmBasisData;
    clear lcmBasisData

    %--- info output ---
    fprintf('\nGlucose anomers combined as 0.36*GlcA + 0.64*GlcB\n')
end

%--- combine GlcA/GlcB or GlucoseA/GlucoseB ---
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
if any(cellfun(cellfind('GlucoseA'),marss.basis.metabNames)) && any(cellfun(cellfind('GlucoseB'),marss.basis.metabNames)) && ...
   ~any(cellfun(cellfind('Glucose'),marss.basis.metabNames))
    %--- index handling ---
    GlcAInd = find(cellfun(cellfind('GlucoseA'),marss.basis.metabNames));
    GlcBInd = find(cellfun(cellfind('GlucoseB'),marss.basis.metabNames));

    %--- replace GlucoseA by weighted sum and rename ---
    lcmBasis.data{GlcAInd}{4} = 0.36*lcmBasis.data{GlcAInd}{4} + 0.64*lcmBasis.data{GlcBInd}{4};
    lcmBasis.data{GlcAInd}{1} = 'Glucose';
    lcmBasis.data{GlcAInd}{5} = '0.36*GlucoseA + 0.64*GlucoseB';

    %--- remove GlcB ---
    lcmBasisData = {};
    nFields        = length(lcmBasis.data{1});    % number of fields
    for mCnt = 1:marss.basis.n                      % metabolites
        if mCnt<GlcBInd
            for fCnt = 1:nFields                    % array fields
                lcmBasisData{mCnt}{fCnt} = lcmBasis.data{mCnt}{fCnt};
            end
        elseif mCnt>GlcBInd
            for fCnt = 1:nFields                    % array fields
                lcmBasisData{mCnt-1}{fCnt} = lcmBasis.data{mCnt}{fCnt};
            end
        end
    end
    lcmBasis.data = lcmBasisData;
    clear lcmBasisData

    %--- info output ---
    fprintf('\nGlucose anomers combined as 0.36*GlucoseA + 0.64*GlucoseB\n')
end

%--- save basis to file ---
save(marss.basis.filePath,'lcmBasis')
fprintf('\nBasis set written to <%s>\n%s\n',marss.basis.fileName,marss.basis.filePath);
clear lcmBasis

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;

