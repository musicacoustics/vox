function P = tubeprepare(tubes, xi, c, dt)
% TUBEPREPARE  Wave model of a vocal tract made of conical tubes
%   P = tubeprepare(tubes, xi, c, dt) prepares the section-wise (tube by
%   tube) time-domain calculation of ctim2.
%   tubes : one row [length, left radius, right radius] per tube [m]
%           (data.tubes of areas3), glottis first
%   xi    : viscothermal constant (data.properties.damping, default 0.135)
%   c     : speed of sound [m/s]
%   dt    : time step [s]
%
%   Every conical tube is divided into cylindrical sub-tubes of one time
%   step c*dt (the last one is between one and two steps long); the radius
%   of a sub-tube keeps the volume of its part of the cone. Cylinders stay
%   one sub-tube. In the limit of short sub-tubes this staircase solves the
%   horn (Webster) equation, which is exact for conical tubes.
%
%   Why not the conical formulation of the former ctim2: at a change of
%   the taper and at the closed end of a converging tube its reflection
%   filters grow like exp(+c*t/x). In the exact solution the growing parts
%   cancel each other; in discrete time they do not, and the signals grew
%   without limit (e.g. vowel /a/: factor 4.8 percent per sample).
%
%   The staircase is passive and therefore stable for any duration:
%   - junctions between sub-tubes: lossless scattering, |r| < 1
%   - propagation: tubekernel, coefficients >= 0 with sum 1 (|H| <= 1)
%   - glottis: closed end (r = +1) with the source
%   - mouth: radiation filter R(s) = -nu^2/(s-nu)^2, nu = -ke/d of the
%     former openend.m (nu < 0 for a cylindrical end), |R| <= 1

ke      = 727.14;                 % radiation constant of openend.m
maxspan = 1e-3;                   % kernel length [s]; the rest is added
                                  % to the last coefficient (tubekernel)
h0      = c*dt;                   % sub-tube length of one time step

nt  = size(tubes,1);
len = [];  rad = [];  first = zeros(1,nt);
for i = 1:nt
   L  = tubes(i,1);  r1 = tubes(i,2);  r2 = tubes(i,3);
   first(i) = numel(len) + 1;     % first sub-tube of tube i
   if r1 == r2
      len(end+1) = L;             %#ok<AGROW>
      rad(end+1) = r1;            %#ok<AGROW>
   else
      K = max(1, floor(L/h0 + 1e-9));
      x = [0, (1:K-1)*h0, L];     % sub-tube boundaries
      ra = r1 + (r2-r1)*x(1:K)/L;
      rb = r1 + (r2-r1)*x(2:K+1)/L;
      len = [len, diff(x)];                         %#ok<AGROW>
      rad = [rad, sqrt((ra.^2 + ra.*rb + rb.^2)/3)]; %#ok<AGROW>
   end
end
N = numel(len);
S = pi*rad.^2;

% propagation kernels, one row per sub-tube
maxtaps = max(16, ceil(maxspan/dt));
kern = cell(N,1);  kfirst = zeros(N,1);
for k = 1:N
   [kern{k}, kfirst(k)] = tubekernel(len(k), rad(k), xi, c, dt, maxtaps);
end
nbuf = max(kfirst + cellfun(@numel, kern) - 1);
H = zeros(N, nbuf);
for k = 1:N
   H(k, kfirst(k):kfirst(k)+numel(kern{k})-1) = kern{k};
end

% radiation at the mouth (openend.m for a cylindrical end)
nu = -ke/(2*rad(end));
E  = exp(nu*dt);
I1 = (E-1)/nu;
I2 = (E*(nu*dt-1)+1)/nu^2;
I3 = (E*(nu*dt*(nu*dt-2)+2)-2)/nu^3;

P.dt     = dt;
P.N      = N;
P.length = len(:);
P.radius = rad(:);
P.first  = first(:);              % index of the first sub-tube per tube
P.r      = (S(1:N-1)-S(2:N))'./(S(1:N-1)+S(2:N))';   % junction k|k+1
P.H      = H;
P.rad    = struct('nu', nu, 'E', E, 'k10', I1-I2/dt, 'k11', I2/dt, ...
                  'k20', I2-I3/dt, 'k21', I3/dt);
% state
P.fbuf   = zeros(N, nbuf);        % column j: wave entering at time n-j
P.bbuf   = zeros(N, nbuf);
P.radstate = [0 0 0];             % [y2, y3, previous input] of the filter
