function [filterMatrix] = createFilterMatrix(Nspins,coherenceOrder) 
%function that returns a filter matrix to remove all coherence orders not
%equal to coherenceOrder

Ip = [0 1; 0 0]; Im = [0 0; 1 0]; Ia = [1 0; 0 0]; Ib = [0 0; 0 1];
I(:,:,1) = Ip;
I(:,:,2) = Im;
I(:,:,3) = Ia;
I(:,:,4) = Ib;
%generate all basis
counter = ones(Nspins,1);
filterMatrix = zeros(2^Nspins,2^Nspins);
coherence = zeros(4^Nspins,1);
inputMat = zeros(2,2,Nspins);

for ii = 1:(4^Nspins) %loop over all possible operators
    coherence(ii) = 0;
    for jj = 1:Nspins %loop over spins to create mat
        inputMat(:,:,jj) = I(:,:,counter(jj));
        if (counter(jj) == 1)
            coherence(ii) = coherence(ii) + 1;
        end
        if (counter(jj) == 2)
            coherence(ii) = coherence(ii) - 1;
        end
    end
    counter(end) = counter(end)+1;
    for jj = Nspins:-1:2
        if (counter(jj) > 4)
            counter(jj) = 1;
            counter(jj-1) = counter(jj-1)+1;
        end
    end
    if (coherence(ii) == coherenceOrder) %only select proper pathway
        filterMatrix = filterMatrix + kronMulti(inputMat);
    end
end
