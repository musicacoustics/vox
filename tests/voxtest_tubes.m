function voxtest_tubes(voxdir)
%VOXTEST_TUBES  Conical tube model (ctim2, #64) against references; stability
%   voxtest_tubes(voxdir) checks the tube calculation in voxdir (a copy of
%   VOX/matlab) without the GUI. Source: pressure wave impulse 1 into the
%   first tube at the closed glottis end, as in the stairs model.
%   1. Passivity: for 300 random tubes (cones and cylinders, lossless and
%      with the viscothermal loss) the scattering matrix of power-normalized
%      waves has a norm <= 1 at all frequencies; the recursion of every cone
%      is stable at 88.2 kHz.
%   2. Accuracy: impulse responses of 100 ms against a frequency-domain
%      transmission-line model (local function tuberef): exact lossless
%      cones (spherical waves), cylinders with the same viscothermal loss,
%      and lossy cones against a fine staircase (1 mm) of lossy cylinders;
%      radiation load of the stairs model (radimp 1 and 2). Pass: every
%      reference formant below 5 kHz within 1 % (lossy cones: 1.5 %, the
%      losses are applied at the tube ends, an approximation; first run:
%      F1 of the lossy converging cone 254 Hz against 257 Hz) and a median
%      level deviation < 0.5 dB between 0.1 and 5 kHz.
%   3. Stability: 2 s without wall losses (/a/, diverging and converging
%      cone, steep cones): finite, the energy does not grow; 20 ms (the
%      default Tract duration) with losses for 40 random geometries: finite
%      and the last 2 ms at least 20 dB below the maximum.
%   4. Combi interface: 1 s with 120 Hz pulses and a glottal area: the last
%      period equals the one 10 periods earlier; source 2*Ag/(Ag+Av) and
%      pin_gl_ac = (Ag-Av)/(Ag+Av) times the fold signal, as in tractsig.

global Fs c rho Hndl GRONT %#ok<GVMIS> ctim2 reads these globals of VOX
fprintf('MATLAB %s, tube tests in %s\n', version, voxdir);
cd(voxdir);
Fs = 22050; c = 350; rho = 1.293; GRONT = 0;
Hndl = struct('voxMainBGColor', [0.8 0.8 0.8]);   % for voxwaitbar
xi = 0.135;     % viscothermal constant (default of the tube mode)
geo.cyl   = [0.17 0.01 0.01];
geo.cyl2  = [0.08 0.005 0.005; 0.09 0.015 0.015];
geo.a     = [0.0714 0.0038 0.0030; 0.1032 0.0030 0.0127];   % /a/ with 2 tubes (areas3)
geo.cone  = [0.17 0.005 0.02];
geo.conv  = [0.17 0.02 0.005];
geo.steep = [0.05 0.012 0.002; 0.12 0.002 0.015];
fails = {};

% 1) passivity of single tubes
rng(2);
Fi = 88200; w = linspace(0, pi, 1025);
worst = 0; nunst = 0;
for k = 1:300
    L = 0.004 + 0.06*rand; ra = 0.001 + 0.02*rand; rb = 0.001 + 0.02*rand;
    if k <= 30, rb = ra; end                         % cylinders
    for x = [0 xi]
        P = coneprepare([L ra rb], x, c, 1/Fi, 1);
        nunst = nunst + ~P.stable;
        worst = max(worst, maxsv(P, w));
    end
end
ok = worst <= 1 + 1e-9 && nunst == 0;
fprintf('passivity: 300 tubes, lossless and lossy: max norm of S %.12f, unstable recursions %d  %s\n', ...
    worst, nunst, okstr(ok));
if ~ok, fails{end+1} = 'passivity'; end

% 2) accuracy
T = 100;   % [ms]
runs = {'cyl', xi, 'cyl', 1; 'cyl2', xi, 'cyl', 1; 'a', 0, 'cone', 1; 'cone', 0, 'cone', 1; ...
        'conv', 0, 'cone', 1; 'steep', 0, 'cone', 1; 'a', 0, 'cone', 2; ...
        'a', xi, 'fine', 1; 'cone', xi, 'fine', 1; 'conv', xi, 'fine', 1};
for k = 1:size(runs, 1)
    tubes = geo.(runs{k,1}); x = runs{k,2}; ref = runs{k,3}; radimp = runs{k,4};
    [y, ~, P] = ctim2(tubes, T, x, 0, [], 0, [], [], radimp);
    Fi = P.out.Fs;
    n = 2^nextpow2(max(numel(y)*4, Fi));   % zero-padded to at least 1 s: bins < 1 Hz
    f = (0:n/2-1)*Fi/n;
    Y = fft(y(:), n); Y = Y(1:n/2).';
    wgt = sinc(f/Fi).^2/(rho*c);           % pressure wave impulse 1 of one sample
    switch ref
        case 'cyl',  Hy = tuberef(tubes, f, x, c, rho, 'cyl', radimp);
        case 'cone', Hy = tuberef(tubes, f, x, c, rho, 'cone', radimp);
        case 'fine', Hy = tuberef(finestairs(tubes, 1e-3), f, x, c, rho, 'cyl', radimp);
    end
    b  = f > 100 & f < 5000;
    dB = median(abs(20*log10(abs(Y(b))./abs(wgt(b).*Hy(b)))));
    fr = peaks(f, abs(wgt.*Hy));
    ft = peaks(f, abs(Y));
    dev = arrayfun(@(p) min(abs(ft - p))/p, fr);
    tol = 0.01 + 0.005*strcmp(ref, 'fine');   % lossy cones: losses at the ends (approximation)
    ok = all(dev < tol) && dB < 0.5;
    fprintf('%-5s xi=%.3f radimp %d vs %-4s: formants %s Hz (reference %s), max dev %.2f %%, median %.2f dB  %s\n', ...
        runs{k,1}, x, radimp, ref, mat2str(round(ft(arrayfun(@(p) find(abs(ft-p) == min(abs(ft-p)), 1), fr)))), ...
        mat2str(round(fr)), 100*max(dev), dB, okstr(ok));
    if ~ok, fails{end+1} = sprintf('accuracy %s/%s', runs{k,1}, ref); end %#ok<AGROW>
end

% 3) stability
for nm = {'a', 'cone', 'conv', 'steep'}
    [y, ~, P] = ctim2(geo.(nm{1}), 2000, 0);
    nw = round(0.05*P.out.Fs);              % energy per 50 ms
    E  = arrayfun(@(m) sum(y((m-1)*nw+1:m*nw).^2), 1:floor(numel(y)/nw));
    m2 = ceil(numel(E)/2):numel(E);
    pf = polyfit((m2-1)*0.05, 10*log10(E(m2) + realmin), 1);   % [dB/s]
    ok = all(isfinite(y)) && pf(1) <= 0;
    fprintf('stability %-5s lossless 2 s: energy slope over the second second %.2f dB/s, last 50 ms %.0f dB re max  %s\n', ...
        nm{1}, pf(1), 10*log10(E(end)/max(E)), okstr(ok));
    if ~ok, fails{end+1} = sprintf('stability %s lossless', nm{1}); end %#ok<AGROW>
end
rng(1);
G = {};
for k = 1:40
    nt = randi([2 8]);
    G{end+1} = [0.005 + 0.06*rand(nt,1), 0.001 + 0.02*rand(nt,2)]; %#ok<AGROW>
    G{end}(2:end,2) = G{end}(1:end-1,3);   % continuous radius
end
nbad = 0;
Td = voxduration(2);   % default Tract duration [ms], 20 ms
for k = 1:numel(G)
    [y, ~, P] = ctim2(G{k}, Td, xi);
    nb  = round(0.002*P.out.Fs);   % envelope per 2 ms
    env = arrayfun(@(m) max(abs(y((m-1)*nb+1:m*nb))), 1:floor(numel(y)/nb));
    nbad = nbad + ~(all(isfinite(y)) && env(end) < 0.1*max(env));
end
fprintf('stability: 40 random geometries with losses, %d ms, %d not decaying  %s\n', Td, nbad, okstr(nbad == 0));
if nbad, fails{end+1} = sprintf('%d geometries not decaying', nbad); end

% 4) combi interface
N = Fs; per = round(Fs/120);
u = zeros(1, N); g = 0.5*(1 - cos(2*pi*(0:round(0.6*per)-1)/round(0.6*per)));
for s0 = 1:per:N-numel(g), u(s0:s0+numel(g)-1) = g; end
Ag = 2e-5; Av = pi*geo.a(1,2)^2;
P = []; P1 = []; yc = zeros(1, N); y1 = zeros(1, N); zc = zeros(1, N);
for ii = 1:N
    [yc(ii), zc(ii), P] = ctim2(geo.a, 0, xi, ii, P, 100*u(ii), [], Ag, 1);
    [y1(ii), ~, P1] = ctim2(geo.a, 0, xi, ii, P1, 100*u(ii));   % no glottal area: factor 1
end
p1 = max(abs(yc(end-per+1:end)));
p0 = max(abs(yc(end-11*per+1:end-10*per)));
src = max(abs(yc - 2*Ag/(Ag + Av)*y1));
pin = max(abs(zc - 100*u*(Ag - Av)/(Ag + Av)));
ok = all(isfinite(yc)) && abs(p1 - p0) <= 1e-6*p0 && src <= 1e-9*max(abs(yc)) && pin == 0;
fprintf(['combi interface: peak of the last period %.6g, 10 periods before %.6g; ', ...
    'source factor 2Ag/(Ag+Av) (max diff %.2g), pin_gl_ac as tractsig (max diff %.2g)  %s\n'], ...
    p1, p0, src, pin, okstr(ok));
if ~ok, fails{end+1} = 'combi interface'; end

if isempty(fails)
    fprintf('RESULT PASS passivity, accuracy (%d cases), stability (4 lossless 2 s, 40 lossy), combi interface\n', size(runs, 1));
else
    fprintf('RESULT FAIL %s\n', strjoin(fails, '; '));
    exit(1);
end
end

% -------------------------------------------------------------------------
function sv = maxsv(P, w)
% largest singular value of the scattering matrix of one tube (power waves
% a/sqrt(Z): the transmission is D/Delta in both directions)
z  = exp(-1j*w(:));
B  = P.B0 + zpoly(P.KB, z);
K  = P.K0 + zpoly(P.KK, z);
D  = zpoly(P.KD, z);
Lm = P.L0 + zpoly(P.KL, z);
De = 1 + P.gam*K;
s11 = (1 - P.g2*B)./De - 1;
s22 = (1 + P.g1*B)./De - 1;
s12 = D./De;
sv = 0;
for q = 1:numel(z)
    sv = max(sv, norm(Lm(q)^2*[s11(q) s12(q); s12(q) s22(q)]));
end
end

function v = zpoly(k, z)
% sum_m k(m) z^m: k(1) belongs to one sample of delay
v = zeros(size(z));
for m = 1:numel(k)
    v = v + k(m)*z.^m;
end
end

function t = finestairs(tubes, h)
% every tube divided into cylinders of about h with the area-mean radius
t = zeros(0, 3);
for i = 1:size(tubes, 1)
    L = tubes(i,1); r1 = tubes(i,2); r2 = tubes(i,3);
    K = max(1, round(L/h));
    x = (0:K)*L/K;
    ra = r1 + (r2 - r1)*x(1:K)/L;
    rb = r1 + (r2 - r1)*x(2:K+1)/L;
    r = sqrt((ra.^2 + ra.*rb + rb.^2)/3);
    t = [t; repmat(L/K, K, 1), r(:), r(:)]; %#ok<AGROW>
end
end

function p = peaks(f, A)
b = f > 100 & f < 5000;
[~, loc] = findpeaks(20*log10(A(b)), 'MinPeakProminence', 3);
fb = f(b);
p = fb(loc);
end

function s = okstr(ok)
if ok, s = 'ok'; else, s = 'FAILED'; end
end

function Hy = tuberef(tubes, f, xi, c, rho, mode, radimp)
% Frequency-domain reference, independent of ctim2.
%   tubes: [L, r_left, r_right] per row [m]; xi: viscothermal constant
%   mode 'cyl' : every row a cylinder with area-mean radius, viscothermal
%                loss xi*sqrt(s)/(sqrt(2)*r*c^1.5) per metre
%   mode 'cone': exact conical frustums (spherical waves), lossless
% Hy = p_mouth/u for a particle velocity u of the source (U = u*S_1);
% mouth load of the stairs model: radimp 1 R(s) = -1/(1 + s*2r/c),
% radimp 2 piston in an infinite baffle.
s    = 1j*2*pi*f(:).';
Hy   = nan(size(s));
rend = tubes(end,3);
for k = find(s ~= 0)
    T = eye(2);
    for i = 1:size(tubes,1)
        L = tubes(i,1); r1 = tubes(i,2); r2 = tubes(i,3);
        if strcmp(mode, 'cyl') || r1 == r2
            r  = sqrt((r1^2 + r1*r2 + r2^2)/3);
            Zc = rho*c/(pi*r^2);
            G  = s(k)/c + xi*sqrt(s(k))/(sqrt(2)*r*c^1.5);
            Ti = [cosh(G*L), Zc*sinh(G*L); sinh(G*L)/Zc, cosh(G*L)];
        else
            kw = s(k)/(1j*c);
            X0 = -r1*L/(r2 - r1);                 % apex relative to the left end
            Ti = conemat(0 - X0, kw, s(k), r1, rho) / conemat(L - X0, kw, s(k), r2, rho);
        end
        T = T*Ti;
    end
    if radimp == 2
        kd = 2*abs(s(k))/c*rend;
        fz = 1 - 2*besselj(1, kd)/kd + 1j*2*mstruv(kd)/kd;
        R  = (fz - 1)/(fz + 1);
    else
        R  = -1/(1 + s(k)*2*rend/c);
    end
    ZL = rho*c/(pi*rend^2)*(1 + R)/(1 - R);
    Hy(k) = pi*tubes(1,2)^2/(T(2,1) + T(2,2)/ZL);
end
end

function M = conemat(x, k, s, r, rho)
% (A, B) of p = (A exp(-jkx) + B exp(jkx))/x  ->  (p, U) at the signed position x
S = pi*r^2;
M = [exp(-1j*k*x)/x, exp(1j*k*x)/x; ...
     S/(s*rho)*exp(-1j*k*x)*(1j*k/x + 1/x^2), S/(s*rho)*exp(1j*k*x)*(-1j*k/x + 1/x^2)];
end
