%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_Dat2FidFileSelect
%% 
%%  Data selection of metabolite data (i.e. the fid) file
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag data

FCTNAME = 'SP2_Data_Dat2FidFileSelect';


%--- check directory access ---
% if isempty(data.spec2.fidDir)
%     [f_succ,maxPath] = SP2_CheckDirAccessR(pwd);
% else
%     [f_succ,maxPath] = SP2_CheckDirAccessR(data.spec2.fidDir);
% end
% if ~f_succ
%     data.spec2.fidDir = maxPath;
% end
if ~SP2_CheckDirAccessR(data.spec2.fidDir)
    if ispc
        data.spec2.fidDir = 'C:\';
    elseif ismac
        data.spec2.fidDir = '/Users/';
    else
        data.spec2.fidDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(data.spec2.fidDir);
    if ~f_succ
        data.spec2.fidDir = maxPath;
    end
end

%--- browse the fid file ---
[filename, pathname] = uigetfile('*.*','Select spectral data set 2',data.spec2.fidDir);       % select data file
if ~ischar(filename)             % buffer select cancelation
    if ~filename            
        fprintf('%s aborted.\n',FCTNAME);
        return
    end
end
while ~strcmp('fid',filename) && ~strcmp('.7',filename(end-1:end)) && ...
      ~strcmp('.rda',filename(end-3:end)) && ~strcmp('.dcm',filename(end-3:end)) && ...
      ~strcmp('.dat',filename(end-3:end)) && ~strcmp('rawdata.job0',filename) && ...
      ~strcmp('fid.refscan',filename) && ~strcmp('rawdata.job1',filename) && ...
      ~strcmp('.raw',filename(end-3:end)) && ~strcmp('.SDAT',filename(end-4:end)) && ...
      ~strcmp('.IMA',filename(end-3:end))
    fprintf('%s ->\nAssigned file does not have a valid format (<fid>, <fid.refscan>, <rawdata.job0>, <rawdata.job1>, <.7>, <.dat>, <.rda>, <.dcm>, <.raw>, <.SDAT>, <.IMA>), try again...\n',FCTNAME);
    [filename, pathname] = uigetfile('*.*','Select spectral data set 2',data.spec2.fidDir);   % select data file
    if ~ischar(filename)             % buffer select cancelation
        if ~filename            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
end

%--- update paths ---
data.spec2.fidDir  = pathname;           
data.spec2.fidName = filename;     
data.spec2.fidFile = [data.spec2.fidDir data.spec2.fidName];            % update fid path
set(fm.data.spec2FidFile,'String',data.spec2.fidFile)

%--- retrieve data format ---
if strcmp(data.spec2.fidDir(end-4:end-1),'.fid')                        % Varian
    fprintf('Data format: Varian\n');
    flag.dataManu = 1;        
    data.spec2.methFile = [data.spec2.fidDir 'procpar'];                % adopt procpar (/method) file path
    data.spec2.acqpFile = [data.spec2.fidDir 'text'];                   % adopt text (/acqp) file path
elseif strcmp(data.spec2.fidName,'fid') || strcmp(data.spec2.fidName,'fid.refscan') || ... % Bruker
       strcmp(data.spec2.fidName,'rawdata.job0') || strcmp(data.spec2.fidName,'rawdata.job1')                        
    fprintf('Data format: Bruker\n');
    flag.dataManu = 2;     
    data.spec2.methFile = [data.spec2.fidDir 'method'];                 % adopt method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'acqp'];                   % adopt acqp file path
elseif strcmp(data.spec2.fidFile(end-1:end),'.7')                       % GE
    fprintf('Data format: General Electric\n');
    flag.dataManu = 3;
    data.spec2.methFile = [data.spec2.fidDir 'geMeth'];                 % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'geAcq'];                  % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.rda')                     % Siemens
    fprintf('Data format: Siemens (.rda)\n');
    flag.dataManu = 4;
    data.spec2.methFile = [data.spec2.fidDir 'siemMeth'];               % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'siemAcq'];                % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.dcm')                     % DICOM
    fprintf('Data format: DICOM (.dcm)\n');
    flag.dataManu = 5;
    data.spec2.methFile = [data.spec2.fidDir 'dcmMeth'];                % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'dcmAcq'];                 % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.dat')                     % Siemens
    fprintf('Data format: Siemens (.dat)\n');
    flag.dataManu = 6;
    data.spec2.methFile = [data.spec2.fidDir 'siemMeth'];               % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'siemAcq'];                % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.raw')                     % Philips raw
    fprintf('Data format: Philips (.raw)\n');
    flag.dataManu = 7;
    data.spec2.methFile = [data.spec2.fidFile(1:end-4) '.sin'];       % method file path
    data.spec2.acqpFile = [data.spec2.fidFile(1:end-4) '.lab'];         % acqp file path
elseif strcmp(data.spec2.fidFile(end-4:end),'.SDAT')                    % Philips collapsed
    fprintf('Data format: Philips (.SDAT)\n');
    flag.dataManu = 8;
    data.spec2.methFile = [data.spec1.fidFile(1:end-5) '.SPAR'];      % method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'philAcq'];                % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.IMA')                     % DICOM
    fprintf('Data format: DICOM (.IMA)\n');
    flag.dataManu = 9;
    data.spec2.methFile = [data.spec2.fidDir 'dcmMeth'];                % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'dcmAcq'];                 % fake acqp file path
else
    fprintf('%s ->\nData format not valid. File assignment aborted.\n',FCTNAME);
    return
end

%--- update display ---
SP2_Data_DataWinUpdate

%--- check pars file existence
% Varian OR Bruker OR Philips .raw OR Philips .sdat
if flag.dataManu==1 || flag.dataManu==2 || flag.dataManu==7 || flag.dataManu==8           
    if ~SP2_CheckFileExistence(data.spec2.methFile)
        return
    end
end
% Bruker OR Philips .raw
if flag.dataManu==2 || flag.dataManu==7           
    if ~SP2_CheckFileExistence(data.spec2.acqpFile)
        return
    end
end





end
