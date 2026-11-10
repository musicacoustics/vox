function [h, first] = tubekernel(L, r, xi, c, dt, maxtaps)
% TUBEKERNEL  Propagation kernel of a cylindrical tube with viscothermal losses
%   [h, first] = tubekernel(L, r, xi, c, dt, maxtaps) returns the FIR
%   coefficients h of a wave travelling through a cylinder of length L [m]
%   and radius r [m]: the output at time n is sum(h(j) * p(n-first-j+1)),
%   i.e. h(1) belongs to a delay of first samples.
%
%   The continuous kernel is the one of ctim2/integralsigma (Martinez,
%   Agullo, Barjau): a delay L/c followed by
%      sigma(u) = coef * u^-1.5 * exp(-a/u),
%      coef = sqrt(2/pi)*xi*L/(c^1.5*D),  a = 2*(xi*L/D)^2/c^3,  D = 4r,
%   whose Laplace transform is exp(-2*sqrt(a*s)), i.e. a boundary layer
%   attenuation of xi*sqrt(omega)/(2*r*c^1.5) per metre. The input between
%   two samples is interpolated linearly (degree 1 in integralsigma).
%
%   Unlike integralsigma (quadl on a nearly singular integrand, sum of the
%   coefficients about 1.1), the integrals are evaluated in closed form:
%      int_0^u sigma     = 1 - erf(sqrt(a/u))
%      int_0^u sigma*v   = 2*coef*sqrt(u)*exp(-a/u) - 2*a*(1 - erf(sqrt(a/u)))
%   All coefficients are >= 0 and the tail after maxtaps intervals is added
%   to the last coefficient, so sum(h) = 1 (no loss at 0 Hz) and |H| <= 1:
%   the kernel is passive for every geometry and time step.
%
%   The delay L/c must be at least one sample (first >= 1); otherwise the
%   output would need the input of the same time step.

tol = 1e-6;                 % stop when this part of the kernel is left
tau0 = L/c;                 % delay of the wave front [s]
first = floor(tau0/dt + 1e-9);
if first < 1
   error('tubekernel: tube of %.2f mm is shorter than one time step (%.2f mm)', ...
      L*1e3, c*dt*1e3);
end
D    = 4*r;                 % d1 + d2 of integralsigma (diameters)
a    = 2*(xi*L/D)^2/c^3;
coef = sqrt(2/pi)*xi*L/(c^1.5*D);

h = zeros(1, maxtaps+1);
E_lo = 1;                   % erf(sqrt(a/u)) at the lower limit, u = 0
G_lo = 0;                   % int_0^u sigma*v at u = 0
for m = 1:maxtaps
   q    = first + m - 1;    % interval [q*dt, (q+1)*dt] of the delay
   u_hi = (q+1)*dt - tau0;
   if a > 0
      E_hi = erf(sqrt(a/u_hi));
      G_hi = 2*coef*sqrt(u_hi)*exp(-a/u_hi) - 2*a*(1 - E_hi);
   else                     % lossless: pure (fractional) delay
      E_hi = 0;
      G_hi = 0;
   end
   K1 = E_lo - E_hi;                                  % int sigma
   K2 = (G_hi - G_lo)/dt + ((tau0 - q*dt)/dt)*K1;     % int sigma*weight
   K2 = min(max(K2, 0), K1);                          % rounding errors
   h(m)   = h(m)   + K1 - K2;
   h(m+1) = h(m+1) + K2;
   E_lo = E_hi;
   G_lo = G_hi;
   if E_hi < tol
      break
   end
end
h(m+1) = h(m+1) + E_hi;     % tail of the kernel: keep the 0 Hz gain at 1
h = h(1:m+1);
h = h/sum(h);
