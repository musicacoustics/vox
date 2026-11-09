function P = pegel(p)
% Berechnet den Pegel P einer eingegebenen Größe p
% ersetzt 0-Eingangswerte durch sehr kleine (verhindert "divide by 0")
% letzte Änderung 4/97

absp = abs(p);
if min(absp) == 0,
   absp(find(absp == 0)) = realmin;
end;
P = 20.*log10(absp);
