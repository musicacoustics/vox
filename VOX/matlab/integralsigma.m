function [b, minf, msup, alfa1, alfa2] ...
   = integralsigma(lcyl, d1, d2, xi, c, deltat, degree)
% NOTE (#64): part of the former conical formulation (preparation.m),
% no longer used; the tube model now uses coneprepare.m and conestep.m
% (docs/conical-tubes.md).

L  = lcyl;
%d1 = rl*2;
%d2 = rr*2;
b  = d1/d2;
tolerance = [1e-3 0];	% [rel_tol abs_tol] default:1e-3
alert = 10;

coefsigma = (sqrt(2/pi)*xi*L)/(c^1.5*(d1+d2));
expsigma 	= 2*(xi*L/(d1+d2))^2/(c^3);
mretard 	= floor(L/(c*deltat));
t0 = (L/(c*deltat)-mretard)*deltat;
%disp(['coefsigma=' num2str(coefsigma)]);
%disp(['expsigma=' num2str(expsigma)]);
%disp(['mretard=' num2str(mretard)]);
%disp(['t0=' num2str(t0)]);

warning off
for s=0:degree
%   k(1,s+1) = quad8('intsigma1',t0,deltat,[tolerance],[],...
%      coefsigma, expsigma, t0, deltat, s);
   k(1,s+1) = quadl('intsigma1',t0,deltat,[tolerance],[],...
      coefsigma, expsigma, t0, deltat, s);
end;
aux	= 0;
m=1;
aux = aux + k(1,1);
%while ((aux<=0.98)|(m<=10))
while ((aux<=0.1)|(m<=10))
   %while (m<=40)
   for s=0:degree
%      k(m+1,s+1) = quad8('intsigma2',0,deltat,[],[], ...
%         coefsigma, expsigma, t0, deltat, s, m);
      k(m+1,s+1) = quadl('intsigma2',0,deltat,[],[], ...
         coefsigma, expsigma, t0, deltat, s, m);
   end;
   aux = aux + k(m+1,1);
   m = m+1;
end;

warning on

if m == alert
   error('alfa does not converge!');
end;
mmax = m-1;
%disp(['k(1,1)=' num2str(k(1,1))]);
%disp(['k(1,2)=' num2str(k(1,2))]);
minf  = mretard+1;
msup  = minf + mmax;
alfa1 = (k(:,1)-k(:,2))';
alfa2 = k(:,2)';
%disp(['mmax=' int2str(mmax) ', aux=' num2str(aux) ...
%    ', alfa1(1)=' num2str(alfa1(1)) ', alfa2(1)=' num2str(alfa2(1))]);
%keyboard;
