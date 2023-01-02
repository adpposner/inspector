%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [procpar, f_read] = SP2_Data_VnmrReadProcpar(varargin)
%%
%%  Function to read Varian's VNMR parameter file 'procpar'
%%
%%  10-2011, Ch. Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME   = 'SP2_Data_VnmrReadProcpar';

parNumber = 0;          % default: both groups per parameter are returned


%--- file path assignment ---
% as:
% 1) the full path of the parameter file (1 function argument)
% 2) assign set of values per parameter to be read: 0: 1st&2nd (default), 1: 1st, 2: 2nd
narg = nargin;
if narg==1
    file      = SP2_Check4StrR( varargin{1} );
elseif narg==2
    file      = SP2_Check4StrR( varargin{1} );
    parNumber = SP2_Check4NumR( varargin{2} );
    if parNumber<0
        fprintf('%s -> Parameter Number (parNumber) <0 is not allowed...\n',FCTNAME)
        return
    end
    if parNumber>2
        fprintf('%s -> Parameter Number (parNumber) >2 is not allowed...\n',FCTNAME)
        return
    end
else
    fprintf('%s -> More than 2 input arguments are not allowed...',FCTNAME)
    return
end

%--- consistency check ---
if ~SP2_CheckFileExistenceR(file)
    return
end

%--- procpar structure init ---
procpar.seqfil = {};              % = PULPROG
procpar.dp = {};                  % ACQ_word_size, 'y' => 'd'ouble 'p'recission, i.e. 32 bits
procpar.ct = {};                  % = NS
procpar.dfreq = {};               % = BF2
procpar.rp = {};                  % = PHC0
procpar.lp = {};                  % = PHC1
procpar.B0 = {};
procpar.ECCorient = {};
procpar.console = {};
procpar.cp = {};
procpar.FOV = {};
procpar.Power = {};
procpar.NR = {};
procpar.ND = {};
procpar.TC = {};
procpar.TR = {};
procpar.TE = {};
procpar.TM = {};
procpar.Tcrush = {};
procpar.TxRx = {};
procpar.WS = {};
procpar.acqdim = {};
procpar.acqcycles = {};
procpar.alfa = {};
procpar.acqtype = {};
procpar.gcoil = {};
procpar.dg = {};
procpar.il = {};                 % interleaved acquisition parameter: 'y', 'n', o
procpar.inc2D = {};              % t1 dwell time in a 3D/4D experiment
procpar.inc3D = {};              % t2 dwell time in a 3D/4D experiment
procpar.exppath = {};
procpar.nf = {};                 % number of FIDs in a pulse sequence
procpar.np = {};                 % number of data points to acquire
procpar.nt = {};                 
procpar.ns = {};                 
procpar.ni = {};
procpar.ni2 = {};
procpar.sfrq = {};               % transmitter frequency mix
procpar.dfrq = {};               % decoupler offset
procpar.fb = {};                 % filter bandwidth
procpar.bs = {};                 % block size
procpar.tof = {};                % transmitter offset
procpar.dof = {};                % decoupler offset
procpar.dhp = {};                % decoupler low power value
procpar.tpwr = {};               % transmitter pulse power
procpar.tpwr1 = {};              % transmitter pulse power
procpar.tpwrf = {};              % transmitter fine linear attenuator for pulse
procpar.dpwr = {};               % decoupler pulse power
procpar.pw = {};                 
procpar.pwpat = {};              
procpar.p1 = {};
procpar.p1pat = {};
procpar.p2pat = {};
procpar.pe_num = {};
procpar.pi = {};
procpar.seqcon = {};
procpar.sw = {};                 % = SW_h
procpar.yz = {};
procpar.z0_ = {};               % note that the VnmrJ parameter to be set is z0, but it is saved to procpar as z0_
procpar.xy = {};
procpar.x2y2 = {};
procpar.x1 = {};
procpar.x3 = {};
procpar.y1 = {};
procpar.xz = {};
procpar.xz2 = {};
procpar.y3 = {};
procpar.z1c = {};
procpar.yz2 = {};
procpar.z2c = {};
procpar.z5 = {};
procpar.z3c = {};
procpar.z4c = {};
procpar.zx2y2 = {};
procpar.zxy = {};
procpar.te1 = {};
procpar.b0delay = {};
procpar.B0delay2 = {};
procpar.B0delay3 = {};
procpar.B0delay4 = {};
procpar.B0delay5 = {};
procpar.b0times = {};
procpar.pss = {};
procpar.orient = {};
procpar.theta = {};
procpar.phi = {};
procpar.thk = {};
procpar.pos1 = {};
procpar.pos2 = {};
procpar.pos3 = {};
procpar.vox1 = {};
procpar.vox2 = {};
procpar.vox3 = {};
procpar.gap = {};
procpar.pss0 = {};
procpar.rcvrs = {};
procpar.gain = {};
procpar.filenameMrsB1Shim = {};
procpar.filenameOVS = {};
procpar.saveSeparately = {};
procpar.nv = {};
procpar.nr = {};                % user-defined nr averaging and phase cycling (different from VnmrJ's NR!)
procpar.csdOffset = {};
procpar.seqtype = {};
procpar.Gslice1 = {};
procpar.Gslice1ref = {};
procpar.Gslice2 = {};
procpar.Gslice3 = {};
procpar.TxFreqExc = {};
procpar.TxFreqRef1 = {};
procpar.TxFreqRef2 = {};
procpar.time_run = {};
procpar.time_complete = {};
procpar.CoarsePwr = {};
procpar.FinePwr = {};
procpar.TcrushTE = {};
procpar.TcrushTM = {};
procpar.Tramp = {};
procpar.GcrushTE = {};
procpar.rof1 = {};
procpar.WSDuration = {};
procpar.WSDuration2 = {};
procpar.TEmin1 = {};
procpar.TEmin2 = {};
procpar.TEmin = {};
procpar.TEbalance1 = {};
procpar.TEbalance2 = {};
procpar.TMmin = {};
procpar.TMbalance = {};
procpar.TImin = {};
procpar.TI = {};
procpar.TI2min = {};
procpar.TI2 = {};
procpar.ss = {};

%--- water suppression ---
procpar.WSModule = {};
procpar.WSDuration = {};
procpar.WSGcrush = {};
procpar.WSOffset = {};
procpar.WSpat = {};
procpar.WSdelay = {};
procpar.pWS = {};
procpar.tpwrWS = {};
procpar.WS = {};

%--- JDE ---
procpar.JDE = {};
procpar.array = {};         % used to alternate JDE frequencies
procpar.arraydim = {};      
procpar.jdepat = {};
procpar.offsetjde = {};
procpar.njde = {};
procpar.pjde = {};
procpar.tpwrjde = {};
procpar.seqtype = {};
procpar.t2Steps = {};
procpar.t2TeExtra = {};
procpar.t2TeExtraBal = {};
procpar.t2DS = {};
procpar.T2offset = {};
procpar.T2offsetVal = {};
procpar.applT2offset = {};

%--- Inversion ---
procpar.Inversion = {};
procpar.p2pat = {};
procpar.TIoffset = {};
procpar.TI = {};
procpar.p2 = {};
procpar.tpwr2 = {};

%--- OVS ---
procpar.OVS = {};
procpar.OVSmode = {};
procpar.OvsInterl = {};
procpar.ovspat1 = {};
procpar.ovssep = {};
procpar.ovsthk = {};
procpar.ovsGlobOffset = {};
procpar.novs = {};
procpar.povs1 = {};
procpar.tpwrovs1 = {};
procpar.tpwrovsVar1 = {};
procpar.tpwrovsVar2 = {};
procpar.tpwrovsVar3 = {};
procpar.tpwrovsVar4 = {};

%--- sLASER timing ---
procpar.sequTimingDur1 = {};
procpar.sequTimingDur2 = {};
procpar.sequTimingDur3 = {};
procpar.sequTimingDur4 = {};
procpar.sequTimingDur5 = {};
procpar.sequTimingDur6 = {};
procpar.sequTimingDur7 = {};
procpar.sequTimingDur8 = {};
procpar.sequTimingDur1Min = {};
procpar.sequTimingDur2Min = {};
procpar.sequTimingDur3Min = {};
procpar.sequTimingDur4Min = {};
procpar.sequTimingDur5Min = {};
procpar.sequTimingDur6Min = {};
procpar.sequTimingDur7Min = {};
procpar.sequTimingDur8Min = {};
procpar.sequTimingBal2 = {};
procpar.sequTimingBal6 = {};
procpar.sequTimingBal7 = {};
procpar.sequTimingBal8 = {};

%--- MRSI ---
procpar.mrsiAver = {};
procpar.nvMrsi = {};
procpar.nvR = {};
procpar.nvP = {};
procpar.nvS = {};
procpar.mrsiDurSec = {};
procpar.mrsiDurMin = {};
procpar.TMrsiEnc = {};
procpar.mrsiEncR = {};
procpar.mrsiEncP = {};
procpar.mrsiEncS = {};
procpar.mrsiTableR = {};
procpar.mrsiTableP = {};
procpar.mrsiTableS = {};
procpar.lro_mrsi = {};
procpar.lpe_mrsi = {};


%--- generation of procpar struct field tags ---
procparNames = fieldnames(procpar);
procparNtags = length(procparNames);

%--- procpar file reading and extraction of the above parameter values ---
% note: both, the 1st and 2nd line per parameter are extracted here
vecVals1st = zeros(1,procparNtags);         % init with 'not found'
vecVals2nd = zeros(1,procparNtags);         % init with 'not found'
fid = fopen(file,'r');
if (fid > 0)
    fprintf('%s ->\nReading <%s>\n',FCTNAME,file);
   
    while (~feof(fid))
        tline = fgetl(fid);
                
        %--- extraction of parameter name ---
        spaceInd = find(tline==' ');
        if ~isempty(spaceInd)
            parName = tline(1:spaceInd(1)-1);
        else
            fprintf('%s -> No spaces found in current line:\n',FCTNAME)
            tline
            return
        end
        
        %--- if parameter is to be retrieved, read and extract value(s) ---
        if isfield(procpar,parName)
            f_numeric = 1;                                              % flag: numerical data
            % 1st line/setting:
            tline1st  = fgetl(fid);                                     % get new line
            spacesTmp = find(tline1st==' ');                            % temp. space position vector
            nVal1st   = str2num(tline1st(1:spacesTmp(1)-1));            % number of values to be read
            % go on reading as long as all values of the particular
            % parameter are read:
            f_break = 1;
            while f_break
                if ~isempty(find(tline1st=='"'))                        % strings
                    if length(find(tline1st=='"'))/2<nVal1st
                        tline1st = [tline1st ' ' fgetl(fid)];
                    else
                        f_break = 0;
                    end
                else                                                    % numeric
                    if length(find(tline1st==' '))<nVal1st
                        tline1st = [tline1st ' ' fgetl(fid)];
                    else
                        f_break = 0;
                    end
                end
            end
            % append space to simplify later value extraction
            if ~strcmp(tline1st(end),' ')
                tline1st = [tline1st ' '];
            end
            spaceInd1st = find(tline1st==' ');                          % find spaces
            quoteInd1st = find(tline1st=='"');                          % find (single) quotes
            nVals1st    = str2num(tline1st(1:spaceInd1st(1)-1));        % number of values to be read
            vecVals1st(find(strcmp(procparNames,parName))) = nVals1st;   % keep number of entries            
            
            % 2nd line/setting:
            tline2nd  = fgetl(fid);                                     % get new line
            spacesTmp = find(tline2nd==' ');                            % temp. space position vector
            nVal2nd   = str2num(tline2nd(1:spacesTmp(1)-1));            % number of values to be read
            % go on reading as long as all values of the particular
            % parameter are read:
            f_break = 1;
            while f_break
                if ~isempty(find(tline2nd=='"'))                        % strings
                    if length(find(tline2nd=='"'))/2<nVal2nd
                        tline2nd = [tline2nd ' ' fgetl(fid)];
                    else
                        f_break = 0;
                    end
                else                                                    % numeric
                    if length(find(tline2nd==' '))<nVal2nd
                        tline2nd = [tline2nd ' ' fgetl(fid)];
                    else
                        f_break = 0;
                    end
                end
            end
            % append space to simplify later value extraction
            
            if ~strcmp(tline2nd(end),' ')
                tline2nd = [tline2nd ' '];
            end
            spaceInd2nd = find(tline2nd==' ');                          % find spaces
            quoteInd2nd = find(tline2nd=='"');                          % find (single) quotes
            nVals2nd    = str2num(tline2nd(1:spaceInd2nd(1)-1));        % number of values to be read
            vecVals2nd(find(strcmp(procparNames,parName))) = nVals2nd;  % keep number of entries            
                                    
            %--- write value(s) to procpar struct: 1) string or 2) numeric ---
            if ~isempty(quoteInd1st) || ~isempty(quoteInd2nd)   
                if nVals1st==0                                          % no entry
                    eval(['procpar.' parName '{1}{icnt}={};'])          % create empty cell
                else                                                    % values found
                    for icnt = 1:nVals1st                               % write values to cell
                       eval(['procpar.' parName '{1}{icnt}=''' tline1st(quoteInd1st(2*icnt-1)+1:quoteInd1st(2*icnt)-1) ''';'])      
                    end
                end
                if nVals2nd>0                                           % only if valid entry
                    for icnt = 1:nVals2nd                               % write values to cell
                       eval(['procpar.' parName '{2}{icnt}=''' tline2nd(quoteInd2nd(2*icnt-1)+1:quoteInd2nd(2*icnt)-1) ''';'])      
                    end
                end
            else
                if nVals1st==0                                          % no entry
                    eval(['procpar.' parName '{1}{icnt}={};'])          % create empty cell
                else                                                    % values found
                    for icnt = 1:nVals1st                               % write values to cell
                        eval(['procpar.' parName '{1}{icnt}=' tline1st(spaceInd1st(icnt)+1:spaceInd1st(icnt+1)-1) ';'])
                    end
                end
                if nVals2nd>0                                          % only if valid entry
                    for icnt = 1:nVals2nd                              % write values to cell
                        eval(['procpar.' parName '{2}{icnt}=' tline2nd(spaceInd2nd(icnt)+1:spaceInd2nd(icnt+1)-1) ';'])      
                    end
                end
            end
        else
            %--- skip lines up to next parameter: fake reading ---
            % 1st value(s):
            tline1st  = fgetl(fid);                                     % get new line
            spacesTmp = find(tline1st==' ');                            % temp. space position vector
            nVal1st   = str2num(tline1st(1:spacesTmp(1)-1));            % number of values to be read
            f_break = 1;
            while f_break
                if ~isempty(find(tline1st=='"'))                        % strings
                    if length(find(tline1st=='"'))/2<nVal1st
                        tline1st = [tline1st ' ' fgetl(fid)];
                    else
                        f_break = 0;
                    end
                else                                                    % numeric
                    if length(find(tline1st==' '))<nVal1st
                        tline1st = [tline1st ' ' fgetl(fid)];
                    else
                        f_break = 0;
                    end
                end
            end
            % 2nd value(s)
            tline2nd  = fgetl(fid);                                     % get new line
            spacesTmp = find(tline2nd==' ');                            % temp. space position vector
            nVal2nd   = str2num(tline2nd(1:spacesTmp(1)-1));            % number of values to be read
            f_break = 1;
            while f_break
                if ~isempty(find(tline2nd=='"'))                        % strings
                    if length(find(tline2nd=='"'))/2<nVal2nd
                        tline2nd = [tline2nd ' ' fgetl(fid)];
                    else
                        f_break = 0;
                    end
                else                                                    % numeric
                    if length(find(tline2nd==' '))<nVal2nd
                        tline2nd = [tline2nd ' ' fgetl(fid)];
                    else
                        f_break = 0;
                    end
                end
            end
        end
    end
    fclose(fid);
    f_read = 1;  
else
   fprintf('%s -> Can not open <%s>\n',FCTNAME,file);
   f_read = 0;
end

%--- selection of value set 1, 2 or both (i.e. as is) ---
if parNumber==1                                             % 1st set of values
    for nCnt = 1:procparNtags                                % all fields
        if vecVals1st(nCnt)>0                               % if field is not empty
            if vecVals1st(nCnt)==1                          % single entry
                eval(['procparTmp.' procparNames{nCnt} '= procpar.' procparNames{nCnt} '{1}{:};'])     
            else                                            % more than 1 field
                eval(['procparTmp.' procparNames{nCnt} '= {};'])
                for iCnt = 1:vecVals1st(nCnt)
                    eval(['procparTmp.' procparNames{nCnt} '{iCnt} = procpar.' procparNames{nCnt} '{1}{iCnt};'])     
                end
            end
        end
    end
    % clear old cell array and create new (structure!) array
    clear procpar
    procpar = procparTmp;
    clear procparTmp
    % note: the removal of empty fields has been inherently done here
elseif parNumber==2                                         % 2nd set of values
   for nCnt = 1:procparNtags                                % all fields
       if vecVals2nd(nCnt)>0                                % if field is not empty
            if vecVals2nd(nCnt)==1                          % single entry
               eval(['procparTmp.' procparNames{nCnt} '= procpar.' procparNames{nCnt} '{2}{:};'])     
            else                                            % more than 1 field
                eval(['procparTmp.' procparNames{nCnt} '= {};'])
                for iCnt = 1:vecVals2nd(nCnt)
                    eval(['procparTmp.' procparNames{nCnt} '{iCnt} = procpar.' procparNames{nCnt} '{2}{iCnt};'])     
                end
            end
        end
    end
    % clear old cell array and create new (structure!) array
    clear procpar
    procpar = procparTmp;
    clear procparTmp
    % note: the removal of empty fields has been inherently done here
else    % both sets of parameters are returned
   %--- removal of empty fields ---
    vec2rm = find(vecVals1st==0 & vecVals2nd==0);     % find empty fields
    for iCnt = 1:length(vec2rm)
        eval(['procpar = rmfield(procpar,''' procparNames{vec2rm(iCnt)} ''');'])
    end
end

%--- receiver handling ---
if any(find(procpar.rcvrs=='n'))
    fprintf('%s -> WARNING: Inactive receiver detected.\n',FCTNAME)
end
procpar.nRcvrs = length(procpar.rcvrs);       % number of receivers
