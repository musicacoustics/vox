function voxtest_tubes(voxdir)
%VOXTEST_TUBES  Tube model (ctim2) against a reference; stability
%   voxtest_tubes(voxdir) checks the section-wise tube calculation in
%   voxdir (a copy of VOX/matlab) without the GUI:
%   1. Accuracy: 200 ms impulse responses against a frequency-domain
%      transmission-line model (local function tuberef: cylinders with the
%      same viscothermal loss, or exact lossless cones with spherical
%      waves, same radiation load). Pass: every reference formant below
%      5 kHz within 1 % (and for the lossy cases median level deviation
%      < 0.5 dB between 0.1 and 5 kHz).
%   2. Stability: 2 s impulse responses (/a/, a cone, a tube converging
%      strongly towards the glottis) and 0.5 s for 40 random conical
%      geometries must decay.
%   3. Combi interface: 1 s with 120 Hz pulses, the last period must equal
%      the one 10 periods earlier.

global Fs c rho Hndl GRONT %#ok<GVMIS> ctim2 reads these globals of VOX
fprintf('MATLAB %s, tube tests in %s\n', version, voxdir);
cd(voxdir);
Fs = 22050; c = 350; rho = 1.293; GRONT = 0;
Hndl = struct('voxMainBGColor', [0.8 0.8 0.8]);   % for voxwaitbar
zcar = 412;     % source impedance used by ctim2
xi = 0.135;     % viscothermal constant (default of the tube mode)
geo.cyl  = [0.17 0.01 0.01];
geo.cyl2 = [0.08 0.005 0.005; 0.09 0.015 0.015];
geo.a    = [0.0714 0.0038 0.0030; 0.1032 0.0030 0.0127];   % /a/ with 2 tubes (areas3)
geo.cone = [0.17 0.005 0.02];
fails = {};

% 1) accuracy
runs = {'cyl', xi, 'cyl'; 'cyl2', xi, 'cyl'; 'a', xi, 'stair'; 'cone', xi, 'stair'; ...
        'a', 0, 'cone'; 'cone', 0, 'cone'};
for k = 1:size(runs, 1)
    tubes = geo.(runs{k,1}); x = runs{k,2}; ref = runs{k,3};
    [y, ~, P] = ctim2(tubes, 200, x);
    Fi = P.out.Fs;
    n = 2^nextpow2(numel(y)*4);
    f = (0:n/2-1)*Fi/n;
    Y = fft(y(:), n); Y = Y(1:n/2).';
    w = sinc(f/Fi).^2*zcar/(rho*c)/(rho*c);   % flow impulse of one sample
    switch ref
        case 'cyl',   Hy = tuberef(tubes, f, x, c, rho, 'cyl');
        case 'stair', Hy = tuberef([P.length, P.radius, P.radius], f, x, c, rho, 'cyl');
        case 'cone',  Hy = tuberef(tubes, f, x, c, rho, 'cone');
    end
    b  = f > 100 & f < 5000;
    dB = median(abs(20*log10(abs(Y(b))./abs(w(b).*Hy(b)))));
    fr = peaks(f, abs(w.*Hy));
    ft = peaks(f, abs(Y));
    dev = arrayfun(@(p) min(abs(ft - p))/p, fr);
    ok = all(dev < 0.01) && (x == 0 || dB < 0.5);
    fprintf('%-5s xi=%.3f vs %-5s: formants %s Hz (reference %s), max dev %.2f %%, median %.2f dB  %s\n', ...
        runs{k,1}, x, ref, mat2str(round(ft(arrayfun(@(p) find(abs(ft-p) == min(abs(ft-p)), 1), fr)))), ...
        mat2str(round(fr)), 100*max(dev), dB, okstr(ok));
    if ~ok, fails{end+1} = sprintf('accuracy %s/%s', runs{k,1}, ref); end %#ok<AGROW>
end

% 2) stability
rng(1);
G = {geo.a, geo.cone, [0.05 0.012 0.002; 0.12 0.002 0.015]};
for k = 1:40
    nt = randi([2 8]);
    G{end+1} = [0.005 + 0.06*rand(nt,1), 0.001 + 0.02*rand(nt,2)]; %#ok<AGROW>
    G{end}(2:end,2) = G{end}(1:end-1,3);   % continuous radius
end
nbad = 0;
for k = 1:numel(G)
    if k <= 3, T = 2000; else, T = 500; end
    [y, ~, P] = ctim2(G{k}, T, xi);
    nb  = round(0.02*P.out.Fs);
    env = arrayfun(@(m) max(abs(y((m-1)*nb+1:m*nb))), 1:floor(numel(y)/nb));
    ok  = all(isfinite(y)) && env(end) < 1e-3*max(env);
    if k <= 3
        fprintf('stability %d: envelope per 20 ms first %.3g, last %.3g  %s\n', k, env(1), env(end), okstr(ok));
    end
    nbad = nbad + ~ok;
end
fprintf('stability: %d geometries, %d not decaying  %s\n', numel(G), nbad, okstr(nbad == 0));
if nbad, fails{end+1} = sprintf('%d geometries not decaying', nbad); end

% 3) combi interface
N = Fs; per = round(Fs/120);
u = zeros(1, N); g = 0.5*(1 - cos(2*pi*(0:round(0.6*per)-1)/round(0.6*per)));
for s0 = 1:per:N-numel(g), u(s0:s0+numel(g)-1) = g; end
P = []; yc = zeros(1, N);
for ii = 1:N
    [yc(ii), ~, P] = ctim2(geo.a, 0, xi, ii, P, 100*u(ii));
end
p1 = max(abs(yc(end-per+1:end)));
p0 = max(abs(yc(end-11*per+1:end-10*per)));
ok = all(isfinite(yc)) && abs(p1 - p0) <= 1e-6*p0;
fprintf('combi interface: peak of the last period %.6g, 10 periods before %.6g  %s\n', p1, p0, okstr(ok));
if ~ok, fails{end+1} = 'combi interface'; end

if isempty(fails)
    fprintf('RESULT PASS accuracy (6 cases), stability (%d geometries), combi interface\n', numel(G));
else
    fprintf('RESULT FAIL %s\n', strjoin(fails, '; '));
    exit(1);
end
end

% -------------------------------------------------------------------------
function p = peaks(f, A)
b = f > 100 & f < 5000;
[~, loc] = findpeaks(20*log10(A(b)), 'MinPeakProminence', 3);
fb = f(b);
p = fb(loc);
end

function s = okstr(ok)
if ok, s = 'ok'; else, s = 'FAILED'; end
end

function Hy = tuberef(tubes, f, xi, c, rho, mode)
% Frequency-domain reference, independent of ctim2.
%   tubes: [L, r_left, r_right] per row [m]; xi: viscothermal constant
%   mode 'cyl' : every row a cylinder with area-mean radius, loss as ctim2
%   mode 'cone': exact conical frustums (spherical waves), lossless
% Hy = p_mouth/u for a particle velocity u of the source (U = u*S_1);
% mouth load R(s) = -1/(1+s/|nu|)^2 with nu = -ke/d (openend.m).
ke   = 727.14;
s    = 1j*2*pi*f(:).';
Hy   = nan(size(s));
rend = tubes(end,3);
nu   = -ke/(2*rend);
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
    R  = -1/(1 + s(k)/abs(nu))^2;
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
