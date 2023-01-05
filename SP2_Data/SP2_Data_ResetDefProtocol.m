%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ResetDefProtocol
%% 
%%  Reset SPEC paraemeter set to default values
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars

FCTNAME = 'SP2_Data_ResetDefProtocol';

%--- check ---
button = questdlg('Do you really want to reset the INSPECTOR default protocol?',...
'Continue Reset','Yes','No','No');
if strcmp(button,'No')
    return
end

%--- check file existence ---
if ~SP2_CheckFileExistenceR(pars.usrDefFile)
    fprintf('%s ->\nNo default protocol found. Program aborted.\n',FCTNAME);
    return
end

%--- keep path ---
parsUsrDefFile = pars.usrDefFile;

%--- exit SPEC ---
SP2_Exit_ExitFct

%--- delete default protocol ---
delete(parsUsrDefFile)

%--- restart SPEC / create new default protocol ---
INSPECTOR
