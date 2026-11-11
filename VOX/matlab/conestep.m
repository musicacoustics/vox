function [P, pmouth, pglot, pbound, fw, bw] = conestep(P, s)
% CONESTEP  One time step of the conical tube model (see coneprepare)
%   [P, pmouth, pglot, pbound, fw, bw] = conestep(P, s)
%   s      : pressure wave entering the first tube at the glottis
%   pmouth : pressure at the mouth end (incident plus reflected wave)
%   pglot  : pressure at the glottis end
%   pbound : pressure at the tube ends, glottis to mouth (nt+1)
%   fw, bw : waves towards the mouth and towards the glottis at the tube ends

% contributions of the past samples
ha1 = sum(P.KL.*P.E1, 2);         % loss filters, entering waves
ha2 = sum(P.KL.*P.E2, 2);
hb1 = sum(P.KL.*P.O1, 2);         % loss filters, leaving waves
hb2 = sum(P.KL.*P.O2, 2);
h1 = (-P.g2.*sum(P.KB.*P.A1, 2) + P.q21.*sum(P.KD.*P.A2, 2) ...
      - P.gam.*sum(P.KK.*P.P1, 2))./P.den;
h2 = ( P.g1.*sum(P.KB.*P.A2, 2) + P.q12.*sum(P.KD.*P.A1, 2) ...
      - P.gam.*sum(P.KK.*P.P2, 2))./P.den;
% leaving waves at the ports: o = S*e + H (e: wave entering the port)
H1 = P.L0.*(P.s1.*ha1 + h1) + hb1;
H2 = P.L0.*(P.s2.*ha2 + h2) + hb2;

nt = P.nt;
e1 = zeros(nt,1);
e2 = zeros(nt,1);
% glottis end: closed (reflection rg) with the source
e1(1) = (P.rg*H1(1) + s)/(1 - P.rg*P.S1(1));
% junctions: u leaves tube i to the right, v leaves tube i+1 to the left
if nt > 1
   r  = P.r;
   Sl = P.S2(1:nt-1);  Hl = H2(1:nt-1);
   Sr = P.S1(2:nt);    Hr = H1(2:nt);
   u  = (Hl.*(1 + Sr.*r) + Sl.*(1 - r).*Hr)./P.det;
   v  = (Hr.*(1 - Sl.*r) + Sr.*(1 + r).*Hl)./P.det;
   e2(1:nt-1) = r.*u + (1 - r).*v;
   e1(2:nt)   = (1 + r).*u - r.*v;
end
% mouth end: radiation
R = P.rad;
if R.radimp == 2
   hR = sum(R.h(2:end).*P.radx);
else
   hR = R.a*(R.E*P.radz + R.k1*P.radx);
end
e2(nt) = (R.r0*H2(nt) + hR)/(1 - R.r0*P.S2(nt));

% waves and pressures of this time step
a1 = P.L0.*e1 + ha1;
a2 = P.L0.*e2 + ha2;
p1 = P.c1.*a1 + h1;
p2 = P.c2.*a2 + h2;
b1 = p1 - a1;
b2 = p2 - a2;
o1 = P.L0.*b1 + hb1;
o2 = P.L0.*b2 + hb2;
x  = o2(nt);                      % incident wave at the mouth
if R.radimp == 2
   P.radx = [x, P.radx(1:end-1)];
else
   P.radz = R.E*P.radz + R.k1*P.radx + R.k2*x;
   P.radx = x;
end
pmouth = x + e2(nt);
pglot  = e1(1) + o1(1);
fw     = [e1; x];
bw     = [o1; e2(nt)];
pbound = fw + bw;

% time shift of the buffers
P.A1 = [a1, P.A1(:,1:end-1)];
P.A2 = [a2, P.A2(:,1:end-1)];
P.P1 = [p1, P.P1(:,1:end-1)];
P.P2 = [p2, P.P2(:,1:end-1)];
P.E1 = [e1, P.E1(:,1:end-1)];
P.E2 = [e2, P.E2(:,1:end-1)];
P.O1 = [b1, P.O1(:,1:end-1)];
P.O2 = [b2, P.O2(:,1:end-1)];
