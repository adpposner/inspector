%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec,f_succ] = SP2_Data_DicomReadFid(dataSpec)
%%
%%  Function to read DICOM fid data files.
%%
%%  10-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_DicomReadFid';


%--- success flag init ---
f_succ = 0;

%--- file consistency ---
if ~SP2_CheckFileExistenceR(dataSpec.fidFile)
    return
end


%     dcmPars  = dicominfo(dcmNames{iCnt});
%     dcmData = dicomread(dcmNames{iCnt});



%--- read data from DICOM file ---
fid = fopen(dataSpec.fidFile);

% advance the field to the appropriate place
% in the file
% field_length = dicom_move(fd, '7FE1', '1010');

% field_size = field_length / 4;

% we can use fread to read data in as floats
% [fid, fid_size] = fread(fd, field_size, 'float32','ieee-le');
 
% [fid,byteRead] = fread(fid,1024,'uint8');            % measurement-specific data length
[fid,byteRead] = fread(fid,2*1024,'uint32=>single');            % measurement-specific data length


dataSpec.nspecC = 1024;
dataSpec.nRcvrs = 1;
dataSpec.nr     = 128;
dataSpec.fid = complex(zeros(dataSpec.nspecC,dataSpec.nRcvrs,dataSpec.nr)); 


% for nrCnt = 1:dataSpec.nr                           % dataSpec.nr
%     for chCnt = 1:dataSpec.nRcvrs
%         dataSpec.fid(:,chCnt,nrCnt) = complex(data(1:2:end),data(2:2:end));
%     end
% end


% if( fid_size ~= field_size )
%      fprintf('\nWarning: field size was %d and %d elements were read.', field_size, fid_size);
% end
% 
% real_part = zeros(length(fid)/2, 1);
% imag_part = real_part;
% 
% % sort into two columns or make complex
% k = 1;
% for n = 1:1:length(fid)
%     if mod(n,2)
%         real_part(k) = fid(n);
%     else
%         imag_part(k) = fid(n);
%         k = k + 1;
%     end
% end
% 
% complex_fid = real_part + j*imag_part;
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Advance to the point in the file where the target group and
% % element are and return the length of the field.
% % Orginally:
% % Greg Reynolds 26-January-2005.
% % Vastly updated:
% % Greg Reynolds 17-June-2005.
% %
% % Now with in-sequence data support.
% 
% function length = dicom_move(fd, strGroup, strElement)
% 
% fprintf('\nSearching for target element (%s, %s)...', strGroup, strElement');
% 
% % these are all the VRs that have length 2
% VR_short_length = struct('strings', ...
%     {'AE', 'AS', 'AT', 'CS', 'DA', 'DS', 'DT', ...
%         'FL', 'FD', 'IS', 'LO', 'LT', 'OF', 'PN', 'SH', ...
%         'SL', 'ST', 'SS', 'TM', 'UI', 'UL', 'US' });
% 
% dims = size(VR_short_length);
% number_of_short_vrs = dims(2);
% 
% % these are all the VRs so that we can establish implicit VRs
% % without lots of DICOM knowledge
% VRs = struct('strings', ...
%     {'AE', 'AS', 'AT','CS', 'DA', 'DS', 'DT', 'FL', ...
%         'FD', 'IS', 'LO', 'LT', 'OB', 'OF', 'OW', 'PN', ...
%         'SH', 'SL', 'SQ', 'ST', 'SS', 'TM', 'UI', 'UL', ...
%         'UN', 'US', 'UT'});
% 
% dims = size(VRs);
% number_of_vrs = dims(2);
% 
% done = 0;
% 
% while ~done,   
%    
%    current_tag = fread(fd, 2, 'uint16','l');
%    current_vr = fread(fd, 2, 'schar','l');   
%     
%    if feof(fd)
%        done = 1;
%        length = 0;
%        fprintf('\nReached end of file without match.');
%        break;
%    else               
%         strGroupCurrent = sprintf('%X', current_tag(1));
%         strElementCurrent = sprintf('%X', current_tag(2));
%         strVRCurrent = sprintf('%c', current_vr);
% 
%         % first of all, check with this is an implicit VR
%         explicit_vr = 0;
%         for n = 1:1:number_of_vrs
%             if strcmp(VRs(n).strings, strVRCurrent)
%                 explicit_vr = 1;
%                 break;
%             end
%         end
%         
%         % it was an implicit VR
%         if explicit_vr == 0
%             
%             % adjust the file pointer back the two-bytes we tentatively
%             % read in as being the VR
%             fseek(fd, -2, 'cof');
%             
%             % possibly need to read in zero padding here?
%             current_length = fread(fd, 1, 'uint32','l');
% 
%             % if the length is undefined, just drop out and move
%             % to next element...
%             if ~strcmp(sprintf('%X', current_length), 'FFFFFFFF')
% 
%                 if strcmp(strGroupCurrent, strGroup)
%                     if strcmp(strElementCurrent, strElement)
%                         length = current_length;
%                         done = 1;
%                         break;
%                     end
%                 end
%                 
%                 if done == 0
%                     fread(fd, current_length, 'uchar','l');      
%                 end
%             end
%             
%         % it was an explicit VR
%         else                       
%             size_length = 4;        
%             
%             % check to see whether it has a short length
%             for n = 1:1:number_of_short_vrs
%                 if strcmp(VR_short_length(n).strings, strVRCurrent)
%                     size_length = 2;
%                 end
%             end
%             
%             % note that implicit VRs always have 32-bit length
%             if size_length == 2
%                 current_length = fread(fd, 1, 'uint16','l');
%             else
%                 zeropadding = fread(fd, 2, 'uchar','l');
%                 current_length = fread(fd, 1, 'uint32','l');	    
%             end           
%             
%             % now see if this was the field we wanted
%             if strcmp(strGroupCurrent, strGroup)
%                 if strcmp(strElementCurrent, strElement)
%                     length = current_length;
%                     done = 1;
%                     break;
%                 end
%             end
%                                    
%             % some implicit VRs, e.g. an SQ can have undefined
%             % length if they have 32-bit length, so if that
%             % isn't the case, proceed and read, otherwise just
%             % skip to the next element            
%             if ~strcmp(sprintf('%X', current_length), 'FFFFFFFF')   
%                 % it wasn't, so advance pointer
%                 if done == 0
%                     fread(fd, current_length, 'uchar','l');
%                 end
%             end	
%         end    
%     end
% end
% 
% %--- version check ---
% fprintf('%s ->\nFunctionality not yet supported. Program aborted.\n',FCTNAME)
% return

%--- success flag update ---
f_succ = 1;
