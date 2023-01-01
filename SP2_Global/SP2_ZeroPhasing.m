%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [specPhased, ph0, f_succ] = SP2_ZeroPhasing(specOrig)
%
% function [specPhased,ph0] = zeroPhasing(specOrig)
% zero order phasing of single spectrum by global maximum search. The zero order phased (complex) spectrum, as well as the determined
% phase value are returned
% 3-2005, Christoph Juchem
%

FCTNAME  = 'SP2_ZeroPhasing';


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
ANGTORAD = pi/180;
degFrac  = 1;               % degree fraction, reciproce degree resolution, 1: 1deg resolution, 2: 0.5deg resolution, 3: 1/3deg resolution...


specOrig = SP2_Check4rowVecR(specOrig);             % check data format (numeric, row vector)
if isreal(specOrig)
    fprintf('%s -> spectrum to be phased must be complex ...',FCTNAME)
    return
end
if mod(degFrac,1)~=0
    fprintf('%s -> <degFrac> must be assigned an integer value ...',FCTNAME)
    return
end


specSize  = size(specOrig);                                 % determine spectrum size
datArray  = repmat(specOrig,360*degFrac,1);                 % reformat to matrix according to phase resolution
zeroPhase = [0:1/degFrac:360-1/degFrac];                    % phasing vector according to phase resolution
zeroArray = repmat(zeroPhase,specSize(2),1);                % reformat phasing vector to matrix
datArray = datArray .* exp(i*zeroArray'*pi/180);            % calculate phased spectra
[maxVecVal,maxVecInd] = max(real(datArray),[],2);           % get real part maximum values
[maxVal,maxInd] = max(maxVecVal);                           % get global maximum and its position
ph0 = zeroPhase(maxInd);                                    % calculate zero order phase value
specPhased = specOrig .* exp(i*ph0*pi/180);

%--- update success flag ---
f_succ = 1;
