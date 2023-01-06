function [returnVal] = kronMulti(inputMats)

if (size(inputMats,3) == 1)
    returnVal = inputMats;
else
    for ii = 1:(size(inputMats,3)-1)
        if (ii == 1)
            returnVal = kron(inputMats(:,:,1),inputMats(:,:,2));
        else
            returnVal = kron(returnVal,inputMats(:,:,ii+1));
        end
    end
end
end
