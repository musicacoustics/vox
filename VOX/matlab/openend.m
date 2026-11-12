function [C, A, B] = openend(i, tub, c, deltat)
% NOTE (#64): part of the former conical formulation (preparation.m),
% no longer used; the tube model now uses coneprepare.m and conestep.m
% (docs/conical-tubes.md).
% open end
% extremobert(I_) = Block [{l,d1,d2,nu}]
ke = 727.14;
if i ~= 1
   L 	= tub(i-1,1);
   d1  = tub(i-1,2);
   d2	= tub(i-1,3);
   nu  = -((ke/d2)-(c/2)*(d2-d1)/(d2*L));
   C = [0, 0, -(nu*nu)];
   A = [0, 0, 		  		 				0; ...
      0, cosaexp(nu), 				0; ...
      0, deltat*cosaexp(nu), cosaexp(nu)];
   B = [1, 		 	0; ...
      k10(nu),	k11(nu); ...
      k20(nu), k21(nu)];
else
   L 	= tub(i,1);
   d1  = tub(i,2);
   d2	= tub(i,3);
   nu  = -((ke/d1)-(c/2)*(d1-d2)/(d1*L));
   C = [0, 0, -(nu*nu)];
   A = [0, 0, 					 				0; ...
      0, cosaexp(nu),				0; ...
      0, deltat*cosaexp(nu), cosaexp(nu)];
   B = [1, 			0; ...
      k10(nu), k11(nu); ...
      k20(nu), k21(nu)];
end;
