function [SampleZahl,SamplingRate,ADoffset,...
   Kanalanzahl,KanalNr,...
   VoltageRange,Reserviert,...
   XachsSchriftLen,XachsSchrift,...
   YachsSchriftLen,YachsSchrift,...
   Rand,Cursor,Grundlaufzeit,OberkantdB,...
   Dynamik,VoltBei0dB,LeftCursOld,...
   RightCursOld,AddaIdentLen,ADDAident,...
   KommentarLen,Kommentar,z] = itazream(Name)

% Einlese-Programm fuer mf-Zeitsignale mit neuem (4/1997) Header
% Eingangs-Parameter:
%	Name [string]:		Dateiname
%
% Ausgangs-Parameter (Erklärung siehe Programmtext):
%
% [SampleZahl,SamplingRate,ADoffset,...
%  Kanalanzahl,KanalNr,...
%  VoltageRange,Reserviert,...
%  XachsSchriftLen,XachsSchrift,...
%  YachsSchriftLen,YachsSchrift,...
%  Rand,Cursor,Grundlaufzeit,OberkantdB,...
%  Dynamik,VoltBei0dB,LeftCursOld,...
%  RightCursOld,AddaIdentLen,ADDAident,...
%  KommentarLen,Kommentar,z]
%
% Dabei muss darauf geachtet werden, dass die Datei "Name" in
% einfachen Hochkommata (z.B. 'h45.dat') angegeben wird. Bei
% leeren Hochkommata ('') erfolgt die Datei-Eingabe durch eine
% Abfrage innerhalb des Programms.
%
% last change: 8/98

if isempty(Name),
   Name = input('Welche Datei lesen?:','s');  % Dateiname abfragen
end;

if  strcmp(computer,'SOL2')
   [fid, message]	= fopen (Name,'r','l');	% Oeffnen Datei on SOL2
elseif  strcmp(computer,'MAC2')
   [fid, message]	= fopen (Name,'r','l');	% Oeffnen Datei on MAC
else
   [fid, message]	= fopen (Name,'r');	% Oeffnen Datei on PC
end;


if (fid == -1),
   error(message);
else
   SampleZahl			= fread (fid,1,'int32');	%{  0} int32int;     {! Anzahl Samples pro Kanal}
   SamplingRate		= fread (fid,1,'float64');%{  4} float64;      {! Abtastrate in Hz}
   ADoffset	    	= fread (fid,1,'uint16');	%{ 12} word;        {Zeitsignale : Integer-Offset der AW's}
   Kanalanzahl		= fread (fid,1,'schar');	%{ 14} byte;        {1 : Mono, bis zu 31 sind erlaubt}
   %  Kanalliste % fehlt noch
   KanalNr	    	= fread (fid,1,'schar');	%{ 15} byte;        {aktueller Kanal, 0 bis Kanalanzahl - 1}
   alleBearb     	= fread (fid,1,'char');		%{ 16} boolean;     {1 : Editieren wirkt auf alle Kanäle}
   Preemphasis   	= fread (fid,1,'char');		%{ 17} boolean;     {1 : 50/15 µs Preemphasis}
   LiCursAktiv   	= fread (fid,1,'char');		%{ 18} boolean;     {1 : Linker Cursor aktiv}
   CursorKreuz   	= fread (fid,1,'char');		%{ 19} boolean;     {1 : Horizontale Cursorlinie erscheint}
   CursorLock    	= fread (fid,1,'char');		%{ 20} boolean;     {1 : Cursor bewegen sich gemeinsam}
   Darstellung   	= fread (fid,1,'char');		%{ 21} MalTyp;      {0 : Punkte,1 : Striche, 2 : Balken}
   Odarstellung  	= fread (fid,1,'char');		%{ 22} MalTyp;      {wie Darstellung, aber nur für Ortskurve}
   Bewertung     	= fread (fid,1,'char');		%{ 23} char;        {für Spektren : Bewertung als Buchstabe 'A'}
   HierEine0     	= fread (fid,1,'char');		%{ 24} byte;        {derzeit unbenutzt}
   NormMax0dB    	= fread (fid,1,'char');		%{ 25} boolean;     {1 : Spektren und Leistung : 0dB = ¦Max¦}
   Yzoom         	= fread (fid,1,'char');		%{ 26} boolean;     {1 : Y-Bereich auf Maximum normieren}
   Xlog          	= fread (fid,1,'char');		%{ 27} boolean;     {1 : Spektren : Frequenz logarithmisch}
   Ylog          	= fread (fid,1,'char');		%{ 28} byte;        {YLog-Bits 1,2,4,8}
   VersionsNr    	= fread (fid,1,'char');		%{ 29} byte;        {früher 0, jetzt 95}
   FFTnorm       	= fread (fid,1,'char');		%{ 30} byte;        {0 : Leistung, 1 Energie, 2 Passband}
   VoltageRange	= fread (fid,1,'float64');	%{ 31} float64;      {! max. Spannung im Zeitsignal}
   Reserviert		= fread (fid,52,'schar');		%{ 39} array [0..52] of byte; {mit Nullen füllen}
   Hun           	= fread (fid,1,'char');		%{ 91} byte;        {Hundertstel}
   Sec           	= fread (fid,1,'char');		%{ 92} byte;
   Min           	= fread (fid,1,'char');		%{ 93} byte;
   Hour           	= fread (fid,1,'char');	%{ 94} byte;        {Entstehungszeit des Signals}
   Day           	= fread (fid,1,'char');		%{ 95} byte;
   Month           	= fread (fid,1,'char');	%{ 96} byte;
   Year           	= fread (fid,1,'uint16'); %{ 97} word;        {Entstehungsdatum des Signals}
   Start           	= fread (fid,1,'int32');%{ 99} int32Int;     {(Nr-1) des ersten Wertes in Datei}
   XachsSchriftLen	= fread (fid,1,'char');	%{102} ?
   XachsSchrift		= setstr(fread (fid,3,'char'));	%{103} string [3];  {Einheit an der X-Achse}
   YachsSchriftLen	= fread (fid,1,'char');	%{105} ?
   YachsSchrift		= setstr(fread (fid,3,'char'));	%{107} string [3];  {Einheit an der Y-Achse}
   Rand		    	= fread (fid,2,'int32');		%{111} LRint32Int;   {dargestellter X-Bereich}
   Cursor	    	= fread	(fid,2,'int32');		%{119} LRint32Int;   {Position der Cursorlinien}
   Grundlaufzeit 	= fread (fid,1,'float64');%{127} float64;      { [s] }
   %  d           		=				%{135} dBBlock;     {bestehend aus folgenden 3 Werten :
   OberkantdB		= fread (fid,1,'float64');	%{135} float64;       dB an der Oberkante
   Dynamik		= fread (fid,1,'float64');		%{143} float64;       Oberkante [db] - Unterkante [dB]
   VoltBei0dB		= fread (fid,1,'float64');	%{151} float64;       Bezugsspannung für 0 dB}
   LeftCursOld		= fread (fid,1,'uint16');	%{159} word;        {alt, für Signale bis Länge 65535}
   RightCursOld		= fread (fid,1,'uint16');	%{161} word;        {alt, für Signale bis Länge 65535}
   AddaIdentLen		= fread (fid,1,'char');		%{} ?
   ADDAident		= setstr(fread (fid,AddaIdentLen,'char'));	%{163} String [20]; {Quantisierung als ASCII-String}
   KommentarLen		= fread (fid,1,'char');		%{} ?
   Kommentar		= setstr(fread (fid,KommentarLen,'char'));	%{184} String [71]; {Beliebiges Blabla}

   if Kanalanzahl == 0
      Kanalanzahl = 1;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % An dieser Stelle werden die Bytes pro Sample bestimmt                %
   % Dazu mit fseek ans Ende der Datei und mit ftell die Bytezahl         %
   % herausgeholt. Danach wieder mit fseek hinter den Header der Datei    %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   status    = fseek(fid,0,'eof');
   SampleSize= (ftell(fid)-256)/SampleZahl/Kanalanzahl*8;
   status    = fseek(fid,256,'bof');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Damit die Leseroutine auf verschiedenen Maschinen laeuft muss hier   %
   % etwas unstaendlich unterschieden werden                              %
   % Besonders bei 3 Bytes pro Sample                                     %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if SampleSize     == 8                                  % 1 Byte  pro Sample Dateien
      buff= fread (fid,Kanalanzahl*SampleZahl,'schar');

   elseif SampleSize == 16                                 % 2 Bytes pro Sample Dateien
      buff= fread (fid,Kanalanzahl*SampleZahl,'int16');

   elseif SampleSize == 24                                 % 3 Bytes pro Sample Dateien
      buff= fread (fid,Kanalanzahl*SampleZahl,'bit24');
      %	  buff = buff1(1:3:Kanalanzahl*SampleZahl*3);
      %	  buff = buff + buff1(2:3:Kanalanzahl*SampleZahl*3)*256;
      %	  buff = buff + buff1(3:3:Kanalanzahl*SampleZahl*3)*65536;
      %	  clear buff1;

   elseif SampleSize == 32                                 % 4 Bytes pro Sample Dateien
      buff= fread (fid,Kanalanzahl*SampleZahl,'int32');

   else	                                                   % ? Bytes pro Sample Dateien
      error('Falscher Dateiheader!');
   end;



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % So das Feld z aufmachen und die Werte aus buff darin eintragen       %
   % Danach kann Buff wieder geloescht werden .                           %
   % Zur Zeit steht in jeder Spalte von z ein Kanal                       %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   z  = zeros (Kanalanzahl,SampleZahl);

   for j = 1:Kanalanzahl,
      z(j,:) = buff(j:Kanalanzahl:SampleZahl*Kanalanzahl)';
   end;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Normieren ! Da Matlab mit floats rechnet kann die VoltageRange in    %
   % die Werte miteingerechnet werden und braucht nicht mehr zusaetzlich  %
   % betrachtet zu werden.                                                %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   z = z  - ADoffset;
   z = z / (2^(SampleSize-1)-1) * VoltageRange;



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Noch einwenig saubermachen und fertig !!                             %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   status	= fclose(fid);
   clear buff; clear fread; clear fseek; clear for;
   clear message; clear error; clear fopen; clear close;
   clear ones;


end; % von else im if-Zweig
