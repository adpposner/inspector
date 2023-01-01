%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_MetabCharStrUpdate
%% 
%%  Update function for singlet grid to be simulated.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Syn_MetabCharStrUpdate';


%--- initial string assignment ---
synMetabCharStr = get(fm.syn.metabCharEntry,'String');

%--- consistency check ---
if any(synMetabCharStr=='''') || any(synMetabCharStr==';') || ...
   any(synMetabCharStr=='(') || any(synMetabCharStr==')') || ...
   isempty(synMetabCharStr)
    fprintf('\nSinglet characteristics are to be assigned as comma-separated list of vectors\n')
    fprintf('for the entries for 1) frequency [ppm], 2) amplitude [a.u.], linewidth [Hz]\n')
    fprintf('example 1, [1 2 3]: 1 ppm, amplitude 2, FWHM 3 Hz\n')
    fprintf('example 2, [1 100 10], [2 100 10], [3 100 10]: 1/2/3 ppm, amplitude 100, FWHM 10 Hz\n\n')
    set(fm.syn.metabCharEntry,'String',syn.metabCharStr)
    return
end

%--- string to cell conversion ---
synMetabCharCell = eval(['{' synMetabCharStr '}']);
synMetabCharN    = length(synMetabCharCell);
fprintf('\n')
for mCnt = 1:synMetabCharN
   if length(synMetabCharCell{mCnt}(:))==3
       fprintf('Singlet %.0f: %.3f ppm / amp %.0f a.u. / lb %.1f Hz\n',mCnt,...
               synMetabCharCell{mCnt}(1),synMetabCharCell{mCnt}(2),synMetabCharCell{mCnt}(3))
   else
       fprintf('Number of entries of singlet #%.0f~=3. Assignment of singlet grid failed.\n',mCnt)
       set(fm.syn.metabCharEntry,'String',syn.metabCharStr)
       return
   end
end

%--- assign parameters ---
syn.metabCharStr  = synMetabCharStr;
syn.metabCharCell = synMetabCharCell;
syn.metabCharN    = synMetabCharN;
set(fm.syn.metabCharEntry,'String',syn.metabCharStr)

%--- info printout ---
if synMetabCharN==1
    fprintf('1 singlet successfully defined\n')
else
    fprintf('%.0f singlets successfully defined\n',syn.metabCharN)
end



