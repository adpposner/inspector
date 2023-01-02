%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [fnames, f_succ] = SP2_GetAllFiles(varargin)
%
% function fnames = fgetAllFiles(varargin)
% returns the file paths of all files from the current and all subdirectories
% Christoph Juchem, 11-2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
if nargin==0
    directory = cd;        % retrieve current directory
elseif nargin==1
    directory = SP2_Check4StrR( varargin{1} );
else
    fprintf('%s -> nargin=%i not allowed!...',FCTNAME,nargin);
    return
end

d = dir(directory);

fnames = {};
numMatches = 0;
for i=1:length(d)
    if ~d(i).isdir
        numMatches = numMatches + 1;
        fnames{numMatches} = fullfile(directory,d(i).name);
    % note: this could result in a recursion limit error if it tries to 
    % follow symbolic links that loop back on themselves...
    elseif d(i).isdir && ~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..')
        fnames = [fnames SP2_GetAllFiles(fullfile(directory,d(i).name))];
        numMatches = length(fnames);
    end
end 

%--- update success flag ---
f_succ = 1;