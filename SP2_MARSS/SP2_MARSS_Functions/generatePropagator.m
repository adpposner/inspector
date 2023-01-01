function [P] = generatePropagator(rfpulse,G,IxN,IyN,IzN,phaseShifts,dt,x,y,z,orientation,Hfree,Nspins,pulseStruct)

if (orientation == 0)
    gradientwaveindex = 1;
    positions = 1;
end
if (orientation == 1)
    gradientwaveindex = 1;
    positions = x;
end
if (orientation == 2)
    gradientwaveindex = 2;
    positions = y;
end
if (orientation == 3)
    gradientwaveindex = 3;
    positions = z;
end

counter = 0;
P = zeros(length(positions),size(IxN,1),size(IxN,2));
%create Hg
for individualPosition = positions
    counter = counter+1;
    if (~pulseStruct.gradientwave)
        Hg = 0; %generate gradient Hamiltonian
        for kk = 1:Nspins
            Hg = Hg + pulseStruct.gamma*(G*individualPosition)*IzN(:,:,kk);
        end
    end
    %create the RF hamiltonian
    for ii = 1:length(rfpulse) %simulate the pulse
        Hrf = zeros(size(IxN,1),size(IxN,2));
        for kk = 1:Nspins
              Hrf = Hrf + 2*pi*rfpulse(1,ii)*(cos(rfpulse(2,ii)+phaseShifts)*IxN(:,:,kk)+sin(rfpulse(2,ii)+phaseShifts)*IyN(:,:,kk));
        end
        if (pulseStruct.gradientwave)
            Hg = 0; %generate gradient Hamiltonian
            for kk = 1:Nspins
                Hg = Hg + pulseStruct.gamma*(G(ii,gradientwaveindex)*individualPosition)*IzN(:,:,kk);
            end
        end
        H = Hfree+Hrf+Hg;
        A = -1i*H*dt;
        if (ii == 1)
            P(counter,:,:) = expm(A);
        else
            P(counter,:,:) = expm(A)*squeeze(P(counter,:,:));
        end
    end
end