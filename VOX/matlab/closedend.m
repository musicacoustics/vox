function [C, A, B] = closedend(i, tub, c)
% NOTE (#64): part of the former conical formulation (preparation.m),
% no longer used; the tube model now uses coneprepare.m and conestep.m
% (docs/conical-tubes.md).

% closed end
% extremtancat(i_) = Block[{l,d1,d2,nu}]
if i ~= 1
   L 	= tub(i-1,1);
   d1  = tub(i-1,2);
   d2	= tub(i-1,3);
   nu 	= c *(d2-d1)/(d2*L);
   if nu ~= 0
      C = [1, 2*nu];
      A = [0,				0;
         0, 	   	cosaexp(nu)];
      B = [1, 	   	0;
         k10(nu),	k11(nu)];
   else
      C = [1, 0];
      A = [0, 0;
         0, 1];
      B = [1, 0;
         0, 0];
   end;
else
   L 	= tub(i,1);
   d1  = tub(i,2);
   d2	= tub(i,3);
   nu 	= c *(d1-d2)/(d1*L);
   if nu ~= 0
      C = [1, 2*nu];
      A	= [0,      	0;
         0, 	   	cosaexp(nu)];
      B = [1, 	   	0;
         k10(nu), k11(nu)];
   else
      C = [1, 0];
      A = [0, 0;
         0, 1];
      B = [1, 0;
         0, 0];
   end;
end;
