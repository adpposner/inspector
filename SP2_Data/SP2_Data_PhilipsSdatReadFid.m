%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec, f_succ] = SP2_Data_PhilipsSdatReadFid(dataSpec)
%%
%%  Function to read MR spectroscopy data in Siemens' SDAT data format (rda).
%%
%%  05/2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_Data_PhilipsSdatReadFid';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if 2==exist(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fSize  = thedir.bytes;
else
    fprintf('%s -> File %s doesn''nt exist\n\n',FCTNAME,dataSpec.fidFile)
    return
end
    
%--- file handling ---
% [fid, msg] = fopen(dataSpec.fidFile,'r',byteOrder);
% [fid, msg] = fopen(dataSpec.fidFile,'r','ieee-le');         % little endian for linux
[fid, msg] = fopen(dataSpec.fidFile,'r','ieee-le');         % little endian for linux
if fid <= 0
    fprintf('%s ->\nOpening %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
end

%--- read data from file ---
datRaw       = SP2_Loc_FreadVAXG(fid,2*dataSpec.nspecC,'float32');
dataSpec.fid = double(complex(datRaw(1:2:end-1),datRaw(2:2:end)));       % convert to complex

%--- consistency check here ---
fprintf('%s ->\n%s read.\n',FCTNAME,dataSpec.fidFile)

%--- update success flag ---
f_succ = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    L O C A L     F U N C T I O N S                                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function numVax = SP2_Loc_FreadVAXG(fid, number, method)
% FREADVAXG Converts a number read in IEEE-LE format to its VAXG
% floating point representation.
%
% Usage:
%    fid = fopen('file.vaxg', 'r', 'ieee-le');
%    num = freadVAXG(fid, numElements, 'format')
%
% 'format' options are the same as FREAD.
%
%  The function is intended to be called by the user.
%
%   See also UINT32LE_TO_VAXF, UINT64LE_TO_VAXG, FREADVAXD

%   Copyright 2009 The MathWorks, Inc.

switch method   
    case {'float32','single'}
      rawUINT32 = fread(fid,number,'uint32=>uint32');
      numVax = SP2_Loc_Uint32le_to_VAXF( rawUINT32 );
      
    case {'float64','double'}
      rawUINT32 = fread(fid,2*number,'uint32=>uint32');%read 2 32bit numbers
      numVax = SP2_Loc_Uint64le_to_VAXG(rawUINT32);
      
    case {'float'}
      if intmax == 2147483647 %32bit OS float is 32 bits
	     rawUINT32 = fread(fid,  number,'uint32=>uint32');
         numVax = SP2_Loc_Uint32le_to_VAXF(rawUINT32);
      else
         rawUINT32 = fread(fid,2*number,'uint32=>uint32');%read 2 32bit numbers
         numVax = SP2_Loc_Uint64le_to_VAXG(rawUINT32);      
      end
      
    otherwise
    numVax = fread(fid, number, method);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ floatVAXF ] = SP2_Loc_Uint32le_to_VAXF( uint32le )
%UINT32LE_TO_VAXF Converts from IEEE-LE (UINT32) to VAXF (single precision)
%  This function takes a raw 32bit unsigned integer (little endian)
%  and converts it into the equivalent floating point number it represents
%  in the VAXF file format for floating point numbers. The VAXF format is
%  the single precision format used with both the VAXD and VAXG 
%  double precision formats and files. 
%  http://www.opengroup.org/onlinepubs/9629399/chap14.htm#tagfcjh_20
%
%   See also UINT64LE_TO_VAXG, UINT64LE_TO_VAXD, FREADVAXD, FREADVAXG

%   Copyright 2009-2011 The MathWorks, Inc. 

%% Define floating value properties for VAX architecture
% The generic equation for a floating point number is:
% (-1)^double(S) * (F+C) * A^(double(E)-B);
% Different operating systems and file formats utilize different values
% for A, B, and C. F, E, and S are computed from the appropriate bits in
% the number as stored on disk.

    A = 2   ;%VAX specific
    B = 128 ;%VAX specific
    C = 0.5 ;%VAX specific

%% Convert raw unsigned number into right answer
% Flip the upper and lower bits (based on how Vax data storage format)
% VAX      <-----WORD1-----><-----WORD2----->
% IEEE-LE  <-----WORD2-----><-----WORD1----->

    word2  = bitshift(bitshift(uint32le,  0), -16);%mask FFFF0000
    word1  = bitshift(bitshift(uint32le, 16), -16);%mask 0000FFFF
    vaxInt = bitor(bitshift(word1,16), bitshift(word2, 0));
    
% Pull out the sign, exponent, and fractional component
% VAX FLOAT BYTES  <-----WORD1----><-----WORD2---->
% VAX FLOAT BITS   0123456789ABCDEF0123456789ABCDEF
% Sign Exp Fract   SEEEEEEEEFFFFFFFFFFFFFFFFFFFFFFF

    S = bitshift(bitshift(vaxInt , 0), -31);%2147483648=hex2dec('80000000')
    E = bitshift(bitshift(vaxInt , 1), -24);%2139095040=hex2dec('7F800000')
    F = bitshift(bitshift(vaxInt , 9),  -9);%   8388607=hex2dec('007FFFFF')

% Construct the floating point number from SEF (Sign, Exp, Fract)
% Formula valid for non-zero values only (zeros fixed in next step)
% http://www.codeproject.com/KB/applications/libnumber.aspx
% http://www.opengroup.org/onlinepubs/9629399/chap14.htm#tagfcjh_20

    M = C+double(F)./16777216;%VAX Specific 16777216=2^24
    floatVAXF = (-1).^double(S) .* M .* A.^(double(E)-B);%Generic

% Add in zeros (if E and S are zero, doubleVAXF should be set to zero)

    zerosIndex = (E == 0 & S == 0);%logical index of all zeros
    floatVAXF(zerosIndex) = 0;
    


