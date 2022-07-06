function [ZC, zxidx] = ZeroX(x,y)
%% returns the exact interpolated time of the zero-crossing
% also returns the first index before() the zero crossing
% - wenn die Reihe mit 0 beginnt wird 1 ausgegeben.
% wahrscheinlich gibt es noch ein problem mit "nullzeitreihen"
% wir sollten eine Mindestamplitude integrieren um das 
% bei 0-Amplitude = Rauschen keine unsinnigen Frequenzen zu berechnen
    x = condTranspose(x,"row");
    y = condTranspose(y,"row");
    zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0); 
    % Returns Approximate Zero-Crossing Indices Of Argument Vector
    zxidx = zci(y);
    if ~isempty(zxidx)
        if xor (y(1)<=0, y(end)<=0)
             zxidx = zxidx(1:end-1); 
             % wenn die Enden unterschiedliche VZ haben, führt Circshift zu  
             % einem zusätzlichen ZC weil es Anfang und ende "verbindet"
        end

        % nur die Steigenden
        if zxidx(end)==length(y)
            pos_mask = y(zxidx(1:end-1)+1) > y(zxidx(1:end-1));
            %die letzte marke kann kein Nulldurchgang sein daher nur bis zum
            %vorletzten
            %pos_last_mask = y(zxidx(end)) > y(zxidx(end)-1);
            %pos_mask = [pos_mask pos_last_mask];
            zxidx = zxidx(1:end-1);
        else
            pos_mask = y(zxidx(1:end)+1) > y(zxidx(1:end));
        end
            zxidx = nonzeros(transpose(pos_mask).*zxidx);

        ZC = zeros(numel(zxidx),1);
        for k1 = 1:numel(zxidx)
            idxrng = max([1 zxidx(k1)-1]):min([zxidx(k1)+1 numel(y)]);
            xrng = x(idxrng);
            yrng = y(idxrng);
            ZC(k1) = interp1( yrng(:), xrng(:), 0, 'linear', 'extrap' );
        end
    else
        ZC = [];
        zxidx = [];
    end
end
