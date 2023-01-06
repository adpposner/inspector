%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [header, f_succ] = SP2_Data_GEReadHeader(file)
%%
%%  Function to read MRS data header of GE data.
%%
%%  Revision 14.300
%%  1) Camilo de la Fuente, MX
%%
%%  Revision 15.001
%%  1) Camilo de la Fuente, MX
%% 
%%  Revision 20.007
%%  1) Karl (Toronto, Ph.D.)
%% 
%%  Revision 24.000
%%  1) NYSPI (until 10/2018)
%% 
%%  Revision 28.002
%%  1) NIB (added 02/2022)
%% 
%%  10/2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_GEReadHeader';

%--- init success flag ---
f_succ = 0;

%--- init header ---
header = {};

%--- RDBM revision ---
fileID = fopen(file,'r','l');
header.rdbmRev = SP2_RoundToNthDigit(fread(fileID,1,'float32'),3);
fclose(fileID);

%--- RDBM check ---
if header.rdbmRev~=14.300 && header.rdbmRev~=15.001 && header.rdbmRev~=24.000 && ...
   header.rdbmRev~=26.002 && header.rdbmRev~=27.001 && header.rdbmRev~=28.002
    fprintf('%s ->\nRevision %.3f currently not supported. Program aborted.\n',FCTNAME,header.rdbmRev)
    fprintf('Contact Christoph Juchem (cwj2112@columbia.edu) for more a solution\n')
    return
end

%--- header size ---
switch header.rdbmRev
    case 7
        header.pFormat     = 39984;
        header.headerSizes = [2048 4096 4096 20480 2052 2052 2048 0 1040 1028 1044];
    case 8 
        header.pFormat     = 60464;
        header.headerSizes = [2048 4096 4096 40960 2052 2052 2048 0 1040 1028 1044];
    case 9
        header.pFormat     = 61464;
        header.headerSizes = [2048 4096 4096 40960 2052 2052 2048 0 1040 1536 1536];
    case 10
        header.pFormat     = 65560;
        header.headerSizes = [2048 4096 4096 45056 2052 2052 2048 0 1040 1536 1536];
    case 11
        header.pFormat     = 66072;
        header.headerSizes = [2048 4096 4096 45056 2052 2052 2048 0 1040 2048 1536];
    case 14
        header.pFormat     = 135704;
        header.headerSizes = [2048 16384 16384 90112 2052 2052 2048 0 1040 2048 1536];
    case 14.1
        header.pFormat     = 135704;
        header.headerSizes = [2048 16384 16384 90112 2052 2052 2048 0 1040 2048 1536];
    case 14.2
        header.pFormat     = 142356;
        header.headerSizes = [2048 16384 16384 98304 2052 2052 2048 0 1040 2048 2048];
    case 14.3
        header.pFormat     = 145908;
        header.headerSizes = [2048 16384 16384 98304 2052 2052 2048 1500 1040 2048 2048];
    case 15
        header.pFormat     = 145908;
        header.headerSizes = [2048 16384 16384 98304 2052 2052 2048 1500 1040 2048 2048];
    case 15.001
        header.pFormat     = 145908;
        header.headerSizes = [2048 16384 16384 98304 2052 2052 2048 1500 1040 2048 2048];
    case 16
        header.pFormat     = 145908;
        header.headerSizes = [2048 16384 16384 98304 2052 2052 2048 1500 1040 2048 2048];
    case 20.001
        header.pFormat     = 145908;
        header.headerSizes = [2048 16384 16384 98304 2052 2052 2048 1500 1040 2048 2048];
    case 20.002
        header.pFormat     = 145932;
        header.headerSizes = [2048 16384 16384 98304 2052 2052 2048 1500 1040 2048 2048];
    case 20.003
        header.pFormat     = 145932;
        header.headerSizes = [2072 16384 16384 98304 2052 2052 2048 1500 1040 2048 2048];
    case 20.004
        header.pFormat     = 146564;
        header.headerSizes = [2704 16384 16384 98304 2052 2052 2048 1500 1040 2048 2048];
    case 20.005
        header.pFormat     = 149788;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 1500 1960 2560 2448];
    case 20.006
        header.pFormat     = 149788;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 1500 1960 2560 2448];
    case 20.007
        header.pFormat     = 149788;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 1500 1960 2560 2448];
    case 21.001
        header.pFormat     = 150336;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 2048 1960 2560 2448];
    case 24
        header.pFormat     = 157276;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 1500 1960 2560 2448 7488];
    case 25.001
        header.pFormat     = 166172;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 1500 1960 2560 2448 7488 8896];
    case 25.002
        header.pFormat     = 166172;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 1500 1960 2560 2448 7488 8896];
    case 25.003
        header.pFormat     = 167196;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 2524 1960 2560 2448 7488 8896];
    case 25.004
        header.pFormat     = 216348;
        header.headerSizes = [4096 16384 16384 147456 2052 2052 2048 2524 1960 2560 2448 7488 8896];
    case 26.000
        header.pFormat     = 163868;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 2524 1960 2560 2448 7488 5568];
    case 26.001
        header.pFormat     = 164532;
        header.headerSizes = [4096 16384 16384 98304 2052 2052 2048 3188 1960 2560 2448 7488 5568];
    case 26.002
        header.pFormat     = 213684;
        header.headerSizes = [4096 16384 16384 147456 2052 2052 2048 3188 1960 2560 2448 7488 5568];
    case 27.000
        header.pFormat     = 219828;
        header.headerSizes = [4096 16384 16384 147456 2052 2052 2048 3188 1960 2560 2448 13632 5568];
    case 27.001
        header.pFormat     = 228020;
        header.headerSizes = [4096 16384 16384 155648 2052 2052 2048 3188 1960 2560 2448 13632 5568];
    case 28.000             % not yet supported/tested
        header.pFormat     = 228020;
        header.headerSizes = [4096 16384 16384 155648 2052 2052 2048 3188 1960 2560 2448 13632 5568];
    case 28.002
        header.pFormat     = 228020;
        header.headerSizes = [4096 16384 16384 155648 2052 2052 2048 3188 1960 2560 2448 13632 5568];
    case 28.003             % not yet supported/tested
        header.pFormat     = 228020;
        header.headerSizes = [4096 16384 16384 155648 2052 2052 2048 3188 1960 2560 2448 13632 5568];
    otherwise
        fprintf('%s ->\nRevision %.3f not found. Program aborted.\n',FCTNAME,header.rdbmRev)
        return
end

%--- format assignment ---
header.headerN       = length(header.headerSizes);              % number of data headers
header.headerSizeTot = sum(header.headerSizes);                 % combined header size
header.endian        = 'ieee-le';                               % so far

%--- read headers ---
[fileID,msg] = fopen(file,'r',header.endian);
if fileID==-1
    fprintf('%s ->\nOpening data file failed\n%s\n. Program aborted.\n',FCTNAME,msg);
    return
end

%--- header size ---
switch header.rdbmRev
    case 14.300                       
        %--- read header parameters ---
        %--- RDB header ---
        fseek(fileID,0,'bof');                              % pointer placement
        fseek(fileID,16,'cof');                             % before date (pos 16)
        header.scanDate    = deblank(fread(fileID,[1 10],'*char'));
        header.scanTime    = deblank(fread(fileID,[1 8],'*char'));
        fseek(fileID,34,'cof');                             % before nSlices (pos 68)
        header.nSlices     = fread(fileID,1,'uint16');
        header.nEchoes     = fread(fileID,1,'int16');
        header.nAverages   = fread(fileID,1,'int16');
        header.nFrames     = fread(fileID,1,'int16');
        fseek(fileID,4,'cof');                              % before frameBytes (pos 80)
        header.frameBytes  = fread(fileID,1,'uint16');
        header.numberBytes = fread(fileID,1,'int16');
        fseek(fileID,18,'cof');                             % before nspecC (pos 102)
        header.nspecC      = fread(fileID,1,'uint16');
        header.nr          = fread(fileID,1,'int16')-1;
        fseek(fileID,94,'cof');                             % before dab (pos 200)
        header.dab(1)      = fread(fileID,1,'int16');
        header.dab(2)      = fread(fileID,1,'int16');
        fseek(fileID,12,'cof');                             % before user0-19 (pos 216) 
        for uCnt = 1:20
            eval(['header.user' num2str(uCnt-1) ' = fread(fileID,1,''float32'');'])
        end
        fseek(fileID,72,'cof');                             % before sw (pos 368) 
        header.sw         = fread(fileID,1,'float32');
        fseek(fileID,8,'cof');                              % before voxel size (pos 380) 
        header.fovX       = fread(fileID,1,'float32');
        header.fovY       = fread(fileID,1,'float32');
        header.fovZ       = fread(fileID,1,'float32');
        header.posX       = fread(fileID,1,'float32');
        header.posY       = fread(fileID,1,'float32');
        header.posZ       = fread(fileID,1,'float32');
        fseek(fileID,36,'cof');                            % before Larmor (pos 440) 
        header.freq = fread(fileID, 1, 'uint32');
        % fseek(fileID,2426,'cof');                          % before # water refs (pos 2870) 
        % header.nexForUnacquiredEncodes = fread(fileID, 1, 'int16');
        % only introduced in release 16.000
        header.nexForUnacquiredEncodes = 0;
        
        %--- PSC header ---
%         fseek(fileID,sum(header.headerSizes(1:7)),'bof');          
%         fseek(fileID,320,'cof');                           % before linear shims (pos 141640) 
%         header.xshim = fread(fileID,1,'int16');
%         header.yshim = fread(fileID,1,'int16');
%         header.zshim = fread(fileID,1,'int16');
        header.xshim = 0;
        header.yshim = 0;
        header.zshim = 0;

        %--- series header ---
        fseek(fileID,sum(header.headerSizes(1:9)),'bof');   % pos 141812
        fseek(fileID,592,'cof');                            % before protocol (pos 142404) 
        header.protocol = deblank(fread(fileID,[1 25],'*char'));

        %--- image header ---
        fseek(fileID,sum(header.headerSizes(1:10)),'bof');  % pos 143860
        fseek(fileID,72,'cof');                             % before scan duration (pos 143932)
        header.scanDur  = fread(fileID,1,'float32');
        fseek(fileID,16,'cof');                             % before nex (pos 143952)
        header.nex      = fread(fileID,1,'float32');
        fseek(fileID,124,'cof');                            % before user24 (pos 144080)
        header.user24   = fread(fileID,1,'float32');
        fseek(fileID,488,'cof');                            % before tr (pos 144572)
        header.tr       = fread(fileID,1,'int32');
        header.ti       = fread(fileID,1,'int32');
        header.te       = fread(fileID,1,'int32');
        header.te2      = fread(fileID,1,'int32');
        fseek(fileID,590,'cof');                            % before psdiname (pos 145178)
        header.sequence = deblank(fread(fileID,[1 13],'*char'));

    case 15.001                       
        %--- read header parameters ---
        %--- RDB header ---
        fseek(fileID,0,'bof');                              % pointer placement
        fseek(fileID,16,'cof');                             % before date (pos 16)
        header.scanDate    = deblank(fread(fileID,[1 10],'*char'));
        header.scanTime    = deblank(fread(fileID,[1 8],'*char'));
        fseek(fileID,34,'cof');                             % before nSlices (pos 68)
        header.nSlices     = fread(fileID,1,'uint16');
        header.nEchoes     = fread(fileID,1,'int16');
        header.nAverages   = fread(fileID,1,'int16');
        header.nFrames     = fread(fileID,1,'int16');
        fseek(fileID,4,'cof');                              % before frameBytes (pos 80)
        header.frameBytes  = fread(fileID,1,'uint16');
        header.numberBytes = fread(fileID,1,'int16');
        fseek(fileID,18,'cof');                             % before nspecC (pos 102)
        header.nspecC      = fread(fileID,1,'uint16');
        header.nr          = fread(fileID,1,'int16')-1;
        fseek(fileID,94,'cof');                             % before dab (pos 200)
        header.dab(1)      = fread(fileID,1,'int16');
        header.dab(2)      = fread(fileID,1,'int16');
        fseek(fileID,12,'cof');                             % before user0-19 (pos 216) 
        for uCnt = 1:20
            eval(['header.user' num2str(uCnt-1) ' = fread(fileID,1,''float32'');'])
        end
        fseek(fileID,72,'cof');                             % before sw (pos 368) 
        header.sw         = fread(fileID,1,'float32');
        fseek(fileID,8,'cof');                              % before voxel size (pos 380) 
        header.fovX       = fread(fileID,1,'float32');
        header.fovY       = fread(fileID,1,'float32');
        header.fovZ       = fread(fileID,1,'float32');
        header.posX       = fread(fileID,1,'float32');
        header.posY       = fread(fileID,1,'float32');
        header.posZ       = fread(fileID,1,'float32');
        fseek(fileID,36,'cof');                            % before Larmor (pos 440) 
        header.freq = fread(fileID, 1, 'uint32');
        fseek(fileID,2426,'cof');                          % before # water refs (pos 2870) 
        % header.nexForUnacquiredEncodes = fread(fileID, 1, 'int16');
        header.nexForUnacquiredEncodes = 0;

        %--- PSC header ---
%         fseek(fileID,sum(header.headerSizes(1:7)),'bof');          
%         fseek(fileID,320,'cof');                           % before linear shims (pos 141640) 
%         header.xshim = fread(fileID,1,'int16');
%         header.yshim = fread(fileID,1,'int16');
%         header.zshim = fread(fileID,1,'int16');
        header.xshim = 0;
        header.yshim = 0;
        header.zshim = 0;

        %--- series header ---
        fseek(fileID,sum(header.headerSizes(1:9)),'bof');   % pos 141812
        fseek(fileID,592,'cof');                            % before protocol (pos 142404) 
        header.protocol = deblank(fread(fileID,[1 25],'*char'));

        %--- image header ---
        fseek(fileID,sum(header.headerSizes(1:10)),'bof');  % pos 143860
        fseek(fileID,72,'cof');                            % before scan duration (pos 143932)
        header.scanDur  = fread(fileID,1,'float32');
        fseek(fileID,16,'cof');                             % before nex (pos 143952)
        header.nex      = fread(fileID,1,'float32');
        fseek(fileID,124,'cof');                            % before user24 (pos 144080)
        header.user24   = fread(fileID,1,'float32');
        fseek(fileID,488,'cof');                            % before tr (pos 144572)
        header.tr       = fread(fileID,1,'int32');
        header.ti       = fread(fileID,1,'int32');
        header.te       = fread(fileID,1,'int32');
        header.te2      = fread(fileID,1,'int32');
        fseek(fileID,590,'cof');                            % before psd_iname (pos 145178)
        header.sequence = deblank(fread(fileID,[1 13],'*char'));

    case 24.000                       
        %--- read header parameters ---
        %--- RDB header ---
        fseek(fileID,0,'bof');                              % pointer placement
        fseek(fileID,16,'cof');                             % before date (pos 16)
        header.scanDate    = deblank(fread(fileID,[1 10],'*char'));
        header.scanTime    = deblank(fread(fileID,[1 8],'*char'));
        fseek(fileID,34,'cof');                             % before nSlices (pos 68)
        header.nSlices     = fread(fileID,1,'uint16');
        header.nEchoes     = fread(fileID,1,'int16');
        header.nAverages   = fread(fileID,1,'int16');
        header.nFrames     = fread(fileID,1,'int16');
        fseek(fileID,4,'cof');                              % before frameBytes (pos 80)
        header.frameBytes  = fread(fileID,1,'uint16');
        header.numberBytes = fread(fileID,1,'int16');
        fseek(fileID,18,'cof');                             % before nspecC (pos 102)
        header.nspecC      = fread(fileID,1,'uint16');
        header.nr          = fread(fileID,1,'int16')-1;
        fseek(fileID,94,'cof');                             % before dab (pos 200)
        header.dab(1)      = fread(fileID,1,'int16');
        header.dab(2)      = fread(fileID,1,'int16');
        fseek(fileID,12,'cof');                             % before user0-19 (pos 216) 
        for uCnt = 1:20
            eval(['header.user' num2str(uCnt-1) ' = fread(fileID,1,''float32'');'])
        end
        fseek(fileID,72,'cof');                             % before sw (pos 368) 
        header.sw         = fread(fileID,1,'float32');
        fseek(fileID,8,'cof');                              % before voxel size (pos 380) 
        header.fovX       = fread(fileID,1,'float32');
        header.fovY       = fread(fileID,1,'float32');
        header.fovZ       = fread(fileID,1,'float32');
        header.posX       = fread(fileID,1,'float32');
        header.posY       = fread(fileID,1,'float32');
        header.posZ       = fread(fileID,1,'float32');
        fseek(fileID,36,'cof');                            % before Larmor (pos 440) 
        header.freq = fread(fileID, 1, 'uint32');
        fseek(fileID,2426,'cof');                          % before # water refs (pos 2870) 
        header.nexForUnacquiredEncodes = fread(fileID, 1, 'int16');

        %--- PSC header ---
        fseek(fileID,sum(header.headerSizes(1:7)),'bof');          
        fseek(fileID,320,'cof');                           % before linear shims (pos 141640) 
        header.xshim = fread(fileID,1,'int16');
        header.yshim = fread(fileID,1,'int16');
        header.zshim = fread(fileID,1,'int16');

        %--- series header ---
        fseek(fileID,sum(header.headerSizes(1:9)),'bof');   % pos 144780
        fseek(fileID,1068,'cof');                           % before protocol (pos 145848) 
        header.protocol = deblank(fread(fileID,[1 25],'*char'));

        %--- image header ---
        fseek(fileID,sum(header.headerSizes(1:10)),'bof');  % pos 147340
        fseek(fileID,312,'cof');                            % before scan duration (pos 147652)
        header.scanDur  = fread(fileID,1,'float32');
        fseek(fileID,16,'cof');                             % before nex (pos 147672)
        header.nex      = fread(fileID,1,'float32');
        fseek(fileID,124,'cof');                            % before user24 (pos 147800)
        header.user24   = fread(fileID,1,'float32');
        fseek(fileID,592,'cof');                            % before tr (pos 148396)
        header.tr       = fread(fileID,1,'int32');
        header.ti       = fread(fileID,1,'int32');
        header.te       = fread(fileID,1,'int32');
        header.te2      = fread(fileID,1,'int32');
        fseek(fileID,606,'cof');                            % before psdiname (pos 149018)
        header.sequence = deblank(fread(fileID,[1 13],'*char'));
    
    case 26.002                       
        %--- read header parameters ---
        %--- RDB header ---
        fseek(fileID,0,'bof');                              % pointer placement
        fseek(fileID,92,'cof');                             % before date (pos 92)
        header.scanDate    = deblank(fread(fileID,[1 10],'*char'));
        header.scanTime    = deblank(fread(fileID,[1 8],'*char'));      % after: pos 110
        fseek(fileID,34,'cof');                             % before nSlices (pos 144)
        header.nSlices     = fread(fileID,1,'uint16');
        header.nEchoes     = fread(fileID,1,'int16');
        header.nAverages   = fread(fileID,1,'int16');
        header.nFrames     = fread(fileID,1,'int16');       % after: pos 152
        fseek(fileID,4,'cof');                              % before frameBytes (pos 156)
        header.frameBytes  = fread(fileID,1,'uint16');
        header.numberBytes = fread(fileID,1,'int16');       % after: pos 160
        fseek(fileID,18,'cof');                             % before nspecC (pos 178)
        header.nspecC      = fread(fileID,1,'uint16');
        header.nr          = fread(fileID,1,'int16')-1;     % after: pos 182
        fseek(fileID,82,'cof');                             % before dab (pos 264)
        header.dab(1)      = fread(fileID,1,'int16');
        header.dab(2)      = fread(fileID,1,'int16');       % after: pos 268
        fseek(fileID,12,'cof');                             % before user0-19 (pos 280) 
        for uCnt = 1:20
            eval(['header.user' num2str(uCnt-1) ' = fread(fileID,1,''float32'');'])
        end                                                 % after 360
        fseek(fileID,72,'cof');                             % before sw (pos 432) 
        header.sw         = fread(fileID,1,'float32');      % after pos 436
        fseek(fileID,8,'cof');                              % before voxel size (pos 444) 
        header.fovX       = fread(fileID,1,'float32');
        header.fovY       = fread(fileID,1,'float32');
        header.fovZ       = fread(fileID,1,'float32');
        header.posX       = fread(fileID,1,'float32');
        header.posY       = fread(fileID,1,'float32');
        header.posZ       = fread(fileID,1,'float32');     % after pos 468
        fseek(fileID,20,'cof');                            % before Larmor (pos 488) 
        header.freq = fread(fileID, 1, 'uint32');          % after pos 492
        fseek(fileID,1314,'cof');                          % before # water refs (pos 1806) 
        header.nexForUnacquiredEncodes = fread(fileID, 1, 'int16');     % after 1808

        %--- PSC header ---
        % fseek(fileID,sum(header.headerSizes(1:7)),'bof');          
        % fseek(fileID,320,'cof');                           % before linear shims (pos xxx) 
        % header.xshim = fread(fileID,1,'int16');
        % header.yshim = fread(fileID,1,'int16');
        % header.zshim = fread(fileID,1,'int16');
        header.xshim = 0;
        header.yshim = 0;
        header.zshim = 0;

        %--- series header ---
        fseek(fileID,sum(header.headerSizes(1:9)),'bof');   % pos 195620
        fseek(fileID,348,'cof');                            % before table position (pos 195968) 
        header.tablePos = fread(fileID,1,'float32');        % after 195972
        fseek(fileID,630,'cof');                            % before protocol (pos 196602) 
        header.sequDesc = deblank(fread(fileID,[1 65],'*char'));
        header.system   = deblank(fread(fileID,[1 9],'*char'));         % after 196676
        fseek(fileID,12,'cof');                            % before protocol (pos 196688) 
        header.protocol = deblank(fread(fileID,[1 25],'*char'));  % after 196713

        %--- image header ---
        fseek(fileID,sum(header.headerSizes(1:10)),'bof');  % pos 198180
        fseek(fileID,312,'cof');                            % before scan duration (pos 198492)
        header.scanDur  = fread(fileID,1,'float32');        % after 198496
        fseek(fileID,16,'cof');                             % before nex (pos 198512)
        header.nex      = fread(fileID,1,'float32');        % after 198516
        fseek(fileID,124,'cof');                            % before user24 (pos 198640)
        header.user24   = fread(fileID,1,'float32');        % after 198644
        fseek(fileID,592,'cof');                            % before tr (pos 199236)
        header.tr       = fread(fileID,1,'int32');
        header.ti       = fread(fileID,1,'int32');
        header.te       = fread(fileID,1,'int32');
        header.te2      = fread(fileID,1,'int32');          % after 199252
        fseek(fileID,606,'cof');                            % before psdiname (pos 199858)
        header.sequence = deblank(fread(fileID,[1 13],'*char'));    % after 199871
        
    case 27.001                       
        %--- read header parameters ---
        %--- RDB header ---
        fseek(fileID,0,'bof');                              % pointer placement
        fseek(fileID,92,'cof');                             % before date (pos 92)
        header.scanDate    = deblank(fread(fileID,[1 10],'*char'));
        header.scanTime    = deblank(fread(fileID,[1 8],'*char'));      % after: pos 110
        fseek(fileID,34,'cof');                             % before nSlices (pos 144)
        header.nSlices     = fread(fileID,1,'uint16');
        header.nEchoes     = fread(fileID,1,'int16');
        header.nAverages   = fread(fileID,1,'int16');
        header.nFrames     = fread(fileID,1,'int16');       % after: pos 152
        fseek(fileID,4,'cof');                              % before frameBytes (pos 156)
        header.frameBytes  = fread(fileID,1,'uint16');
        header.numberBytes = fread(fileID,1,'int16');       % after: pos 160
        fseek(fileID,18,'cof');                             % before nspecC (pos 178)
        header.nspecC      = fread(fileID,1,'uint16');
        header.nr          = fread(fileID,1,'int16')-1;     % after: pos 182
        fseek(fileID,82,'cof');                             % before dab (pos 264)
        header.dab(1)      = fread(fileID,1,'int16');
        header.dab(2)      = fread(fileID,1,'int16');       % after: pos 268
        fseek(fileID,12,'cof');                             % before user0-19 (pos 280) 
        for uCnt = 1:20
            eval(['header.user' num2str(uCnt-1) ' = fread(fileID,1,''float32'');'])
        end                                                 % after 360
        fseek(fileID,72,'cof');                             % before sw (pos 432) 
        header.sw         = fread(fileID,1,'float32');      % after pos 436
        fseek(fileID,8,'cof');                              % before voxel size (pos 444) 
        header.fovX       = fread(fileID,1,'float32');
        header.fovY       = fread(fileID,1,'float32');
        header.fovZ       = fread(fileID,1,'float32');
        header.posX       = fread(fileID,1,'float32');
        header.posY       = fread(fileID,1,'float32');
        header.posZ       = fread(fileID,1,'float32');     % after pos 468
        fseek(fileID,20,'cof');                            % before Larmor (pos 488) 
        header.freq = fread(fileID, 1, 'uint32');          % after pos 492
        fseek(fileID,1314,'cof');                          % before # water refs (pos 1806) 
        header.nexForUnacquiredEncodes = fread(fileID, 1, 'int16');     % after 1808

        %--- PSC header ---
        fseek(fileID,sum(header.headerSizes(1:7)),'bof');          
        fseek(fileID,320,'cof');                           % before linear shims (pos xxx) 
        header.xshim = fread(fileID,1,'int16');
        header.yshim = fread(fileID,1,'int16');
        header.zshim = fread(fileID,1,'int16');

        %--- series header ---
        fseek(fileID,sum(header.headerSizes(1:9)),'bof');   % pos 144780
        fseek(fileID,1068,'cof');                           % before protocol (pos 145848) 
        header.protocol = deblank(fread(fileID,[1 25],'*char'));

        %--- image header ---
        fseek(fileID,sum(header.headerSizes(1:10)),'bof');  % pos 147340
        fseek(fileID,312,'cof');                            % before scan duration (pos 147652)
        header.scanDur  = fread(fileID,1,'float32');
        fseek(fileID,16,'cof');                             % before nex (pos 147672)
        header.nex      = fread(fileID,1,'float32');
        fseek(fileID,124,'cof');                            % before user24 (pos 147800)
        header.user24   = fread(fileID,1,'float32');
        fseek(fileID,592,'cof');                            % before tr (pos 148396)
        header.tr       = fread(fileID,1,'int32');
        header.ti       = fread(fileID,1,'int32');
        header.te       = fread(fileID,1,'int32');
        header.te2      = fread(fileID,1,'int32');
        fseek(fileID,606,'cof');                            % before psdiname (pos 149018)
        header.sequence = deblank(fread(fileID,[1 13],'*char'));
           
    case 28.002                       % NIB, 02/2022
        %--- read header parameters ---
        %--- RDB header ---
        fseek(fileID,0,'bof');                              % pointer placement
        fseek(fileID,92,'cof');                             % before date (pos 92)
        header.scanDate    = deblank(fread(fileID,[1 10],'*char'));     % after: pos 102
        header.scanTime    = deblank(fread(fileID,[1 8],'*char'));      % after: pos 110
        fseek(fileID,34,'cof');                             % before nSlices (pos 144)
        header.nSlices     = fread(fileID,1,'uint16');
        header.nEchoes     = fread(fileID,1,'int16');
        header.nAverages   = fread(fileID,1,'int16');
        header.nFrames     = fread(fileID,1,'int16');       % after: pos 152
        fseek(fileID,4,'cof');                              % before frameBytes (pos 156)
        header.frameBytes  = fread(fileID,1,'uint16');
        header.numberBytes = fread(fileID,1,'int16');       % after: pos 160
        fseek(fileID,18,'cof');                             % before nspecC (pos 178)
        header.nspecC      = fread(fileID,1,'uint16');
        header.nr          = fread(fileID,1,'int16')-1;     % after: pos 182
        fseek(fileID,82,'cof');                             % before dab (pos 264)
        header.dab(1)      = fread(fileID,1,'int16');
        header.dab(2)      = fread(fileID,1,'int16');       % after: pos 268
        fseek(fileID,12,'cof');                             % before user0-19 (pos 280) 
        for uCnt = 1:20
            eval(['header.user' num2str(uCnt-1) ' = fread(fileID,1,''float32'');'])
        end                                                 % after 360
        fseek(fileID,72,'cof');                             % before sw (pos 432) 
        header.sw         = fread(fileID,1,'float32');      % after pos 436
        fseek(fileID,8,'cof');                              % before voxel size (pos 444) 
        header.fovX       = fread(fileID,1,'float32');
        header.fovY       = fread(fileID,1,'float32');
        header.fovZ       = fread(fileID,1,'float32');
        header.posX       = fread(fileID,1,'float32');
        header.posY       = fread(fileID,1,'float32');
        header.posZ       = fread(fileID,1,'float32');      % after pos 468
        fseek(fileID,20,'cof');                             % before Larmor (pos 488) 
        header.freq = fread(fileID, 1, 'uint32');           % after pos 492
        fseek(fileID,1314,'cof');                           % before # water refs (pos 1806) 
        header.nexForUnacquiredEncodes = fread(fileID, 1, 'int16');     % after 1808

        %--- PSC header ---
        fseek(fileID,sum(header.headerSizes(1:7)),'bof');   % after pos 198664      
        fseek(fileID,320,'cof');                            % before linear shims: pos 198984
        header.xshim = fread(fileID,1,'int16');             % after pos 198986
        header.yshim = fread(fileID,1,'int16');             % after pos 198988
        header.zshim = fread(fileID,1,'int16');             % after pos 198990

        %--- series header ---
        fseek(fileID,sum(header.headerSizes(1:9)),'bof');   % after pos 203812
        fseek(fileID,348,'cof');                            % before pos 204160 
        header.tablePos = fread(fileID,1,'float32');        % after pos 204164
        fseek(fileID,630,'cof');                            % before pos 204794
        header.protocol = deblank(fread(fileID,[1 25],'*char'));    % after pos 204859

        %--- image header ---
        fseek(fileID,sum(header.headerSizes(1:10)),'bof');  % after 206372
        fseek(fileID,312,'cof');                            % before pos 206684
        header.scanDur  = fread(fileID,1,'float32');        % after pos 206688
        fseek(fileID,16,'cof');                             % before pos 206704
        header.nex      = fread(fileID,1,'float32');        % after pos 206708
        fseek(fileID,124,'cof');                            % before user24 pos 206832
        header.user24   = fread(fileID,1,'float32');        % after pos 206836
        fseek(fileID,592,'cof');                            % before tr pos 207428
        header.tr       = fread(fileID,1,'int32');          % after tr pos 207432
        header.ti       = fread(fileID,1,'int32');
        header.te       = fread(fileID,1,'int32');
        header.te2      = fread(fileID,1,'int32');
        fseek(fileID,606,'cof');                            % before psd_iname pos 208050
        header.sequence = deblank(fread(fileID,[1 13],'*char'));
    
    otherwise
        fprintf('%s ->\nRevision %.3f not supported yet. Program aborted.\n',FCTNAME,header.rdbmRev)
        return
end

%--- make sure all parameters exist ---
% to be updated properly in each revision...
if ~isfield(header,'tablePos')
    header.tablePos = 666;
end
if ~isfield(header,'sequDesc')
    header.sequDesc = '';
end
if ~isfield(header,'system')
    header.system = '';
end


% 1st position, pointer position: BOF
% fseek(fileID,0,'bof');                                              % pointer placement
% header.rdb_hdr = SP2_Data_GEReadHeaderRdb(fileID,header);

% 8th position, pointer position: summation 1:7
% fseek(fileID,sum(header.headerSizes(1:7)),'bof');          
% header.psc     = SP2_Data_GEReadHeaderPsc(fileID,header); 

% 10th position, pointer position: summation 1:9
% fseek(fileID,sum(header.headerSizes(1:9)),'bof');          
% header.series = SP2_Data_GEReadHeaderSeries(fileID,header);

% 11th position, pointer position: summmation of 1:10
% fseek(fileID,sum(header.headerSizes(1:10)),'bof');                                              % pointer placement
% header.image  = SP2_Data_GEReadHeaderImage(fileID,header);


%--- close data file ---
if fclose(fileID)==-1
    fprintf('%s ->\nClosing file %s failed\n',FCTNAME,dataSpec.fidFile)
    return
end

%--- update success flag ---
f_succ = 1;



end
