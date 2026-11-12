function P = coneprepare(tubes, xi, c, dt, radimp)
% CONEPREPARE  Vocal tract of conical tubes in the time domain (#64, method M2)
%   P = coneprepare(tubes, xi, c, dt, radimp) prepares the calculation of
%   ctim2 for a chain of conical tubes.
%   tubes  : one row [length, left radius, right radius] per tube [m]
%            (data.tubes of areas3), glottis first
%   xi     : viscothermal constant (data.properties.damping, default 0.135);
%            0: no wall losses
%   c      : speed of sound [m/s]
%   dt     : time step [s]; every tube must be at least c*dt long
%   radimp : radiation at the mouth as in the stairs model
%            (data.properties.radimp): 1 reflection -a/(s + a), a = c/(2r);
%            2 piston in an infinite baffle
%   P.stable is false if the recursion of a tube is not stable for this
%   time step (very steep cone): ctim2 then takes a shorter time step.
%
%   Waves. Both ends of every tube are ports with plane pressure waves
%   (reference impedance rho*c/S of the end), as in the stairs model: the
%   junctions between tubes, the glottis end, the radiation and the output
%   are those of the stairs model. Inside a cone the waves are spherical.
%   a1, a2: waves entering the tube at its left and right end; p1, p2:
%   pressures at the ends; outgoing waves b = p - a.
%
%   One cone (lossless, exact): left and right end at the signed distances
%   x1, x2 = x1 + L from the apex (both negative for a converging cone),
%   T = L/c, D = delay T, g1 = c/(2*x1), g2 = c/(2*x2),
%   gam = c/(2*x1*x2) > 0:
%      p1 = ((1 - g2*B) a1 + (r2/r1) D a2) / Delta
%      p2 = ((1 + g1*B) a2 + (r1/r2) D a1) / Delta,   Delta = 1 + gam*K
%   B and K are finite impulse responses of the length 2T, the round trip
%   of the cone:
%      B(t) = 1,           0 <= t < 2T
%      K(t) = L - c*t/2,   0 <= t < 2T  (falls linearly to 0)
%   The integrators 1/s of the spherical waves (the exponential terms that
%   grow at converging junctions) cancel exactly in this form: what remains
%   are the two finite kernels and a recursion with Delta.
%   Discretisation: input interpolated linearly between two samples, the
%   kernels integrated exactly (time-interpolated convolution); the delay T
%   becomes a linear interpolation. Delta gives the recursion
%      (1 + gam*K(0)) p(n) = N(n) - gam * sum_m K(m) p(n-m),
%   with positive coefficients that do not increase with m: by the
%   Enestrom-Kakeya theorem all poles are inside the unit circle. This
%   holds if 1 + gam*K(0) >= gam*K(1), i.e. unless the cone is very steep
%   for the time step; the poles are checked here in any case.
%   Cylinders: g1 = g2 = gam = 0, p1 = a1 + D a2: a pure delay.
%
%   Losses: half of the viscothermal loss of the tube (kernel of
%   integralsigma/Martinez and Agullo, coefficients >= 0, sum 1, |H| <= 1;
%   integralsigma.m of the former formulation was removed in #19)
%   is applied at each end to the entering and to the leaving wave. The
%   tube stays passive for every xi.
%
%   Instantaneous parts (sample n -> n): every tube reflects a small part
%   of a1(n), a2(n) at once; the transmission is delayed by T >= one time
%   step. The equations of two tubes meeting at a junction, of the glottis
%   end and of the mouth end are solved per sample (2x2 systems).

if nargin < 5 || isempty(radimp)
   radimp = 1;
end
maxspan = 1e-3;                   % length of the loss kernels [s]
nt = size(tubes,1);
Lt = tubes(:,1);  r1 = tubes(:,2);  r2 = tubes(:,3);
T  = Lt/c;
if any(T < dt*(1 - 1e-9))
   error('coneprepare: tube of %.2f mm is shorter than one time step (%.2f mm)', ...
      1e3*min(Lt), 1e3*c*dt);
end

% cones
tau = (r2 - r1)./Lt;              % taper dr/dx
g1  = c*tau./(2*r1);              % c/(2*x1)
g2  = c*tau./(2*r2);              % c/(2*x2)
gam = c*tau.^2./(2*r1.*r2);       % c/(2*x1*x2)
nk  = ceil(2*T/dt - 1e-9);        % last index of the kernels B, K
nb  = max(nk);
KB  = zeros(nt, nb);  KK = zeros(nt, nb);  KD = zeros(nt, nb);
B0  = zeros(nt,1);    K0 = zeros(nt,1);
P.stable = true;
for i = 1:nt
   b = fohkernel(@(t) ones(size(t)), 2*T(i), dt);
   k = fohkernel(@(t) Lt(i) - c*t/2, 2*T(i), dt);
   B0(i) = b(1);  KB(i,1:numel(b)-1) = b(2:end);
   K0(i) = k(1);  KK(i,1:numel(k)-1) = k(2:end);
   m0 = floor(T(i)/dt + 1e-9);
   fr = max(T(i)/dt - m0, 0);
   KD(i,m0) = 1 - fr;
   if fr > 1e-9
      KD(i,m0+1) = fr;
   end
   if gam(i) > 0                  % poles of the recursion 1/Delta
      z = roots([1 + gam(i)*K0(i), gam(i)*KK(i,1:numel(k)-1)]);
      if any(abs(z) >= 1 - 1e-9)
         P.stable = false;
      end
   end
end
den = 1 + gam.*K0;

% viscothermal losses, half of the tube at each end (diameter d1 + d2 as
% in integralsigma)
lam = cell(nt,1);
for i = 1:nt
   lam{i} = losskernel(Lt(i)/2, 2*(r1(i) + r2(i)), xi, c, dt, ceil(maxspan/dt));
end
nl = max(1, max(cellfun(@numel, lam)) - 1);
KL = zeros(nt, nl);  L0 = zeros(nt,1);
for i = 1:nt
   L0(i) = lam{i}(1);
   KL(i,1:numel(lam{i})-1) = lam{i}(2:end);
end

% junctions between tubes: plane-wave scattering (stairs model)
Sa = reshape(r2(1:nt-1), [], 1).^2;   % left of the junction
Sb = reshape(r1(2:nt), [], 1).^2;     % right of the junction
r  = (Sa - Sb)./(Sa + Sb);

% instantaneous reflection of a tube (port to port, including the losses)
s1 = (1 - g2.*B0)./den - 1;
s2 = (1 + g1.*B0)./den - 1;
S1 = L0.^2.*s1;
S2 = L0.^2.*s2;

P.dt   = dt;
P.nt   = nt;
P.tubes = tubes;
P.g1 = g1;  P.g2 = g2;  P.gam = gam;  P.den = den;
P.q21 = r2./r1;  P.q12 = r1./r2;
P.B0 = B0;  P.K0 = K0;
P.KB = KB;  P.KK = KK;  P.KD = KD;
P.c1 = (1 - g2.*B0)./den;
P.c2 = (1 + g1.*B0)./den;
P.s1 = s1;  P.s2 = s2;  P.S1 = S1;  P.S2 = S2;
P.L0 = L0;  P.KL = KL;
P.r  = r;
Sl = S2(1:nt-1);  Sr = S1(2:nt);
P.det = (1 - Sl.*r).*(1 + Sr.*r) - Sl.*Sr.*(1 - r).*(1 + r);
P.rg = 1;                         % glottis end: closed (stairs model)
P.rad = radiation(r2(end), c, dt, radimp);
% state: column j holds the value of time step n-j
P.A1 = zeros(nt, nb);  P.A2 = zeros(nt, nb);   % waves entering the cone
P.P1 = zeros(nt, nb);  P.P2 = zeros(nt, nb);   % pressures at the ends
P.E1 = zeros(nt, nl);  P.E2 = zeros(nt, nl);   % waves entering the loss filters
P.O1 = zeros(nt, nl);  P.O2 = zeros(nt, nl);   % waves leaving the cone
P.radx = zeros(1, P.rad.nx);                   % incident waves at the mouth
P.radz = 0;                                    % state of the one-pole filter


function h = fohkernel(fun, Tend, dt)
% h(m+1) = integral of fun(t)*hat(m - t/dt) over 0 <= t <= Tend:
% kernel for an input interpolated linearly between the samples
% (fun linear: Gauss-Legendre with 3 points is exact)
M  = ceil(Tend/dt - 1e-9);
h  = zeros(1, M+1);
gx = [-sqrt(3/5), 0, sqrt(3/5)];
gw = [5 8 5]/9;
for m = 0:M
   for e = [m-1, m+1]
      lo = max(0, min(m, e)*dt);
      hi = min(Tend, max(m, e)*dt);
      if hi > lo
         t = (lo + hi)/2 + (hi - lo)/2*gx;
         h(m+1) = h(m+1) + (hi - lo)/2*sum(gw.*fun(t).*(1 - abs(m - t/dt)));
      end
   end
end


function lam = losskernel(L, D, xi, c, dt, maxtaps)
% viscothermal loss of a tube of length L without its delay: kernel
% sigma(u) = coef*u^-1.5*exp(-a/u) of integralsigma (Laplace transform
% exp(-2*sqrt(a*s))), input interpolated linearly, integrals in closed form
% as in the former tubekernel.m: int_0^u sigma = 1 - erf(sqrt(a/u)),
% int_0^u sigma*v = 2*coef*sqrt(u)*exp(-a/u) - 2*a*(1 - erf(sqrt(a/u))).
% All coefficients >= 0, the tail after maxtaps is added to the last one,
% sum 1: |H| <= 1 and no loss at 0 Hz.
if xi == 0
   lam = 1;
   return
end
tol  = 1e-6;
a    = 2*(xi*L/D)^2/c^3;
coef = sqrt(2/pi)*xi*L/(c^1.5*D);
lam  = zeros(1, maxtaps+1);
E_lo = 1;
G_lo = 0;
for m = 0:maxtaps-1
   u_hi = (m+1)*dt;
   E_hi = erf(sqrt(a/u_hi));
   G_hi = 2*coef*sqrt(u_hi)*exp(-a/u_hi) - 2*a*(1 - E_hi);
   K1 = E_lo - E_hi;                       % int sigma over the interval
   K2 = min(max((G_hi - G_lo)/dt - m*K1, 0), K1);   % int sigma*(u/dt - m)
   lam(m+1) = lam(m+1) + K1 - K2;
   lam(m+2) = lam(m+2) + K2;
   E_lo = E_hi;
   G_lo = G_hi;
   if E_hi < tol
      break
   end
end
lam(m+2) = lam(m+2) + E_hi;
lam = lam(1:m+2)/sum(lam(1:m+2));


function R = radiation(rend, c, dt, radimp)
% reflection of the wave arriving at the mouth, as in the stairs model;
% reflected(n) = r0*x(n) + (history), x: incident wave
R.radimp = radimp;
if radimp == 2
   % piston in an infinite baffle, d = 2*rend (cf. voctract):
   % normalized impedance f = 1 - 2*J1(kd)/(kd) + j*2*H1(kd)/(kd),
   % reflection (f - 1)/(f + 1); FIR by frequency sampling (about 100 Hz)
   Fi = 1/dt;
   n  = 2*round(Fi/200);
   x  = (0:n/2)*Fi/n;
   k  = 2*pi*x/c;
   d  = 2*rend;
   f  = 1 - 2*besselj(1, k*d)./(k*d) + 1j*2*mstruv(k*d)./(k*d);
   f(1) = 0;                      % 0 Hz: f -> 0, reflection -1
   Rf = (f - 1)./(f + 1);
   h  = real(ifft([Rf, conj(Rf(end-1:-1:2))]));
   h  = h(1:n/2);                 % causal part (5 ms)
   H  = abs(fft(h, 8*n));
   if max(H) > 1                  % keep the reflection passive
      h = h/max(H);
   end
   R.h  = h;
   R.r0 = h(1);
   R.nx = numel(h) - 1;
else
   % R(s) = a/(s - a), a = -c/(2*rend) (stairs model, radimp 1), input
   % interpolated linearly: z(n) = E*z(n-1) + k1*x(n-1) + k2*x(n),
   % reflected = a*z
   a  = -c/(2*rend);
   E  = exp(a*dt);
   R.a  = a;
   R.E  = E;
   R.k1 = E*((a*dt - 1) + exp(-a*dt))/(dt*a^2);
   R.k2 = E*(1 - (1 + a*dt)*exp(-a*dt))/(dt*a^2);
   R.r0 = a*R.k2;
   R.nx = 1;
end
