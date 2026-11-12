function PARCTIM = preparation(tubes, holes, fingering, xi, c)
% NOTE (#64): no longer used. Since November 2026 the tube model (ctim2)
% calculates the conical segments with coneprepare.m and conestep.m:
% plane waves at the tube ends, finite kernels over the round trip of
% every cone and a stable recursion (method M2, docs/conical-tubes.md).
% This file belongs to the former multiconvolution formulation, which
% grew without limit; it is kept for reference.

global Fs

zcar 	 = 412;			% wave impedence in air
deltat = 1/Fs;		    % time increment

degree = 1;				% degree for integralsigma

%load tubes and load holes and load fingering

% generation of tube pieces
length_aux = 0;
i = 0;
j = 1;
discontinuities = double('d')*ones(1,size(tubes,1)-1);	 % ASCII(100) = 'd'
discontinuities = [double('x') discontinuities]; % prepend 'x' instead of 'et'
discontinuities = [discontinuities double('y')]; % append 'y' instead of 'eo'
discontinuities = char(discontinuities);
ldis = length(discontinuities);

while j <= size(holes,1)
   i = i+1;
   length_aux = length_aux + tubes(i,1);
   if holes(j,1) < length_aux
      discontinuities = [discontinuities(1:i+j-1), fingering(j), ...
         discontinuities(i+j:ldis)];
      ldis = length(discontinuities);
      L = length_aux - holes(j,1);
      d2 = tubes(i,3);
      d1 = d2 - (((tubes(i,3)-tubes(i,2))*L)/tubes(i,1));
      tubes = [tubes(1:i,:); [L, d1, d2]; tubes(i+1:size(tubes,1),:)];
      tubes(i,1) = tubes(i,1)-L;
      tubes(i,3) = d1;
      length_aux = length_aux - tubes(i+1,1);
      j = j+1;
   elseif holes(j,1) == length_aux
      disp('Something''s wrong with the holes...');
   end;
end;

%save discontinuities discontinuities

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculation of propagators
for tube = 1:size(tubes,1)
   [b(tube) ,minf(tube), msup(tube), alfa1(tube).value, alfa2(tube).value] ...
      = integralsigma(tubes(tube,1), tubes(tube,2), tubes(tube,3), xi, c, deltat, degree);
end;
%save matricepropagators degree b minf msup alfa1 alfa2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculation of discontinuities
j = 1;
for i = 2:ldis-1
   switch discontinuities(i)
      case 't'
         [C_minus(i).value, C_plus(i).value, A(i).value, B(i).value] ...
            = closedhole(i, j, tubes, holes, c);
         j = j+1;
      case 'o'
         [C_minus(i).value, C_plus(i).value, A(i).value, B(i).value] ...
            = openhole(i, j, tubes, holes, c);
         j = j+1;
      case 'd'
         % canvitram(i_) := block[{1a,d1a,d2a,ra,lb,d1b,d2b,rb,Bsec,c1,c2,nu}]
         [C_minus(i).value, C_plus(i).value, A(i).value, B(i).value] ...
            = middleend(i, tubes, c);
   end;
end;

switch discontinuities(1)
   case 'x'
      % extremtancat(i_) = Block[{l,d1,d2,nu}]
      [C_plus(1).value, A(1).value, B(1).value] ...
         = closedend(1, tubes, c);
   case 'y'
      % extremobert(I_) = Block [{l,d1,d2,nu}]
      [C_plus(1).value, A(1).value, B(1).value] ...
         = openend(1, tubes, c);
end;

switch discontinuities(ldis)
   case 'x'
      % extremtancat(i_) = Block[{l,d1,d2,nu}]
      [C_minus(ldis).value, A(ldis).value, B(ldis).value] ...
         = closedend(ldis, tubes, c);
   case 'y'
      % extremobert(I_) = Block [{l,d1,d2,nu}]
      [C_minus(ldis).value, A(ldis).value, B(ldis).value] ...
         = openend(ldis, tubes, c, deltat);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% flow to pressure transformation
% extrementrada;
[Cinput, Ainput, Binput] = inputend(tubes, c, zcar);

%save matricediscontinuities Ainput Binput Cinput A B C_plus C_minus

PARCTIM.degree	= degree;
PARCTIM.b				= b;
PARCTIM.alfa1		= alfa1;
PARCTIM.alfa2		= alfa2;
PARCTIM.ldis 		= ldis;
PARCTIM.minf		= minf;
PARCTIM.msup		= msup;
PARCTIM.C_plus	= C_plus;
PARCTIM.C_minus	= C_minus;
PARCTIM.Ainput	= Ainput;
PARCTIM.Binput	= Binput;
PARCTIM.Cinput	= Cinput;
PARCTIM.A				= A;
PARCTIM.B				= B;