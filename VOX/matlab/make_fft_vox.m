function Vek_aus = make_fft_vox(Vek_ein, Linienzahl)
% berechnet das Leistungsspektrum eines Zeitsignals
%
% Eingangs-Parameter:
% 		Vek_ein: 		Eingangs-Zeitsignal
% 		Linienzahl:		Linienzahl der FFT
% Ausgangs-Parameter:
%		Vek_aus:			gepegeltes Spektrum
%
% letzte Änderung 8/97

% following lines set timesignal to zero after last zerocrossing
maxindex=length(Vek_ein);lastindex=maxindex;oldindex=maxindex;
while lastindex>1 & (abs(Vek_ein(lastindex))<=abs(Vek_ein(oldindex)))
   oldindex=lastindex;
   lastindex=lastindex-1;
end;
Vek_ein = Vek_ein(:);
Vek_ein = [Vek_ein(1:lastindex); zeros(maxindex-lastindex,1)];
if lastindex > 1
   Vek_ein = Vek_ein(1:lastindex);
   Vek_ein(lastindex)=0;
   Vek_ein=block(Vek_ein,1);	% zeropad Signal to next 2^n
end

Linienzahl = length(Vek_ein);

Y = fft(Vek_ein,Linienzahl);

Vek_aus = pegel(Y(1:Linienzahl/2));
