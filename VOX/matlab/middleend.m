function [C_right, C_left, A, B] = middleend(i, tub, c)
% NOTE (#64): part of the former conical formulation (preparation.m),
% no longer used; the tube model now uses coneprepare.m and conestep.m
% (docs/conical-tubes.md).
% disconituity i betwen the tube pieces i-1 (a) and i (b)
% canvitram(i_) := block[{1a,d1a,d2a,ra,lb,d1b,d2b,rb,Bsec,c1,c2,nu}]
La 	 = tub(i-1,1);
d1a  = tub(i-1,2);
d2a  = tub(i-1,3);
Lb	 = tub(i,1);
d1b  = tub(i,2);
d2b  = tub(i,3);
Bsec = (d2a*d2a)/(d1b*d1b);
c1	 = (Bsec-1)/(Bsec+1);
c2	 = (2*Bsec)/(Bsec+1);
if ((d1a==d2a)&(d1b==d2b)&(d1a==d1b))
   C_right = [0  0];
   C_left  = C_right;
   A = [0, 0; ...
      0, 1];
   B = [1, 0; ...
      0, 0];
elseif ((d1a==d2a)&(d1b==d2b))
   C_right = [ c1, 0];
   C_left  = [-c1, 0];
   A = [0, 0; ...
      0, 1];
   B = [1, 0; ...
      0, 0];
elseif (d1a==d2a)
   rb = Lb*d1b/(d2b-d1b);
   nu = -c/((Bsec+1)*rb);
   C_right = [ c1, c2*nu];
   C_left  = [-c1, c2*nu/Bsec];
   A = [0, 0; ...
      0, cosaexp(nu)];
   B = [1, 			0; ...
      k10(nu), k11(nu)];
elseif (d1b==d2b)
   ra = La*d2a/(d2a-d1a);
   nu = c*Bsec/((Bsec+1)*ra);
   C_right = [ c1, c2*nu];
   C_left  = [-c1, c2*nu/Bsec];
   A = [0, 0; ...
      0, cosaexp(nu)];
   B = [1, 			0; ...
      k10(nu), k11(nu)];
else
   ra = La*d2a/(d2a-d1a);
   rb = Lb*d1b/(d2b-d1b);
   nu = (c/(Bsec+1))*((Bsec*rb-ra)/(ra*rb));
   C_right = [ c1, c2*nu];
   C_left  = [-c1, c2*nu/Bsec];
   A = [0, 0; ...
      0, cosaexp(nu)];
   B = [1, 			0; ...
      k10(nu), k11(nu)];
end;
