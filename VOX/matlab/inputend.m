function [Cinput, Ainput, Binput] = inputend(tubes, c, zcar)
% NOTE (#64): part of the former conical formulation (preparation.m),
% no longer used; the tube model now uses coneprepare.m and conestep.m
% (docs/conical-tubes.md).
% input extremity (where h(t) is calculated)
% extrementrada := Block[{l,d1,d2,nu}]
L  = tubes(1,1);
d1 = tubes(1,2);
d2 = tubes(1,3);
nu = c*(d1-d2)/(d1*L);
if nu ~= 0
   Cinput = [zcar, zcar*nu];
   Ainput = [0, 0;...
      0, cosaexp(nu)];
   Binput = [1, 			 0;...
      k10(nu), k11(nu)];
else
   Cinput = [zcar, 0];
   Ainput = [0, 0;...
      0, 1];
   Binput = [1, 0;...
      0, 0];
end
% if no Table -> columns!