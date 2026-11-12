function voxtest_tubestairs(voxdir)
%VOXTEST_TUBESTAIRS  Tube model and stairs model in the GUI, vowel /a/ (#64, #50)
%   voxtest_tubestairs(voxdir) starts VOX in voxdir (a copy of VOX/matlab)
%   with the default settings (vowel /a/) and compares the two tract
%   models with the same radius vector. The tubes are cones through all
%   points of the radius vector (maxsegments = number of points - 1,
%   maxdevlimit 0), so that both have the same geometry apart from the
%   steps.
%   - Tract Calc without wall losses (damping 0 in both, 200 ms): formants
%     below 4 kHz (peaks with 6 dB prominence) within 4 %, levels at the
%     formants within 3 dB.
%   - Tract Calc with the default damping of each model (stairs Xi0 per
%     sample, tubes viscothermal XI; 50 ms): formants (1 dB prominence,
%     the stairs peaks are broad; peaks more than 30 dB below the
%     strongest are left out) within 4 %; the levels differ with the
%     different loss models and are only reported.
%   - Tubes with the default of 2 cones: calculated, finite (reported).
%   - Combi (30 ms, calculated folds): stairs and tubes (all points).
%     Pass: finite, peak of the mouth signal of the tubes within a factor
%     2 of the stairs (before #64 the tubes were about 10x louder, #50),
%     Infold.pin_gl_ac set in both.
%   The limits of 4 % and 3 dB were set after the first run: the remaining
%   differences come from the geometry (steps against straight lines
%   between the points), not from the wave calculation, which
%   voxtest_tubes checks against exact references.
%   Run it hidden (see runvoxtests): VOX opens its windows.

global TMAX GRONF Hndl Infold XI Xi0 %#ok<GVMIS> VOX is driven through its globals
fprintf('MATLAB %s, tubes and stairs in %s\n', version, voxdir);
cd(voxdir);
vox;
GRONF = 0;
set(Hndl.gronf, 'value', 0);
nfail = 0;
names = {'stairs', 'tubes'};

% tract alone
cases = {'without wall losses', 200, 6, [0 0]; 'default damping', 50, 1, [Xi0 XI]};
for c = 1:size(cases, 1)
    setdur(cases{c, 2});
    F = cell(1, 2);  A = cell(1, 2);
    for m = 1:2
        setmode(m);
        setgeometry(numel(getfield(get(Hndl.figureNumber, 'UserData'), 'radius')) - 1, ...
            cases{c, 4}(m));
        vox('tractcalc');
        r = get(Hndl.figureNumber, 'UserData');
        [F{m}, A{m}] = formants(r.y, r.Fs, cases{c, 3});
        fprintf('%-20s %-6s: Fs %d Hz, damping %.4g, formants %s Hz, levels %s dB\n', cases{c, 1}, ...
            names{m}, r.Fs, r.properties.damping, mat2str(round(F{m})), mat2str(round(A{m}, 1)));
        if m == 2
            okfin = all(isfinite(r.y));
        end
    end
    [dev, ddb] = match(F{1}, A{1}, F{2}, A{2});
    ok = okfin && numel(F{2}) == numel(F{1}) && all(dev < 0.04) && (c == 2 || all(ddb < 3));
    check(sprintf('tract %s: %d formants, max dev %.2f %%, max level diff %.1f dB', cases{c, 1}, ...
        numel(F{1}), 100*max(dev), max(ddb)), ok);
end

setgeometry(2, XI);
vox('tractcalc');
t2 = get(Hndl.figureNumber, 'UserData');
f2 = formants(t2.y, t2.Fs, 6);
check(sprintf('tract: tubes with the default of 2 cones, formants %s Hz', mat2str(round(f2))), ...
    all(isfinite(t2.y)) && ~isempty(f2));

% combi
setinput(1); setdur(30);
vox('foldcalc');
peak = zeros(1, 2);
for m = 1:2
    setmode(m);
    setinput(4); setdur(30);
    if m == 2
        setgeometry(numel(getfield(get(Hndl.figureNumber, 'UserData'), 'radius')) - 1, XI);
    end
    Infold.pin_gl_ac = NaN;
    vox('combicalc');
    d = get(Hndl.figureNumber, 'UserData');
    peak(m) = max(abs(d.y));
    fprintf('combi %-6s: %d samples, peak of the mouth signal %.4g, pin_gl_ac %.4g\n', ...
        names{m}, numel(d.y), peak(m), Infold.pin_gl_ac);
    check(sprintf('combi %s: finite, pin_gl_ac set', names{m}), all(isfinite(d.y)) && isfinite(Infold.pin_gl_ac));
end
check(sprintf('combi: peak tubes/stairs %.3f (within a factor 2)', peak(2)/peak(1)), ...
    peak(2)/peak(1) > 0.5 && peak(2)/peak(1) < 2);

vox('closevox');
if nfail == 0
    fprintf('RESULT PASS tubes and stairs: same formants for /a/ (and levels without wall losses), combi of the same order\n');
else
    fprintf('RESULT FAIL %d checks failed\n', nfail);
    exit(1);
end

    function setmode(v)
        set(Hndl.TractCalcMode, 'value', v);
        vox('tractcalcmode');
    end
    function setgeometry(nseg, damping)
        % vox('tractcalcmode') may load the last result of the mode
        dd = get(Hndl.figureNumber, 'UserData');
        dd.properties.maxsegments = nseg;
        dd.properties.maxdevlimit = 0;
        dd.properties.damping = damping;
        set(Hndl.figureNumber, 'UserData', dd);
    end
    function setinput(v)
        set(Hndl.INPUT, 'value', v);
        eval(get(Hndl.INPUT, 'Callback'));
    end
    function setdur(ms)
        TMAX = ms;
        set(Hndl.DurationStr, 'string', num2str(ms));
        vox('refreshDuration', 'string');
    end
    function check(label, ok)
        if ok
            fprintf('%-110s ok\n', label);
        else
            fprintf('%-110s FAILED\n', label);
            nfail = nfail + 1;
        end
    end
end

function [f, a] = formants(y, Fs, prominence)
% peaks of the spectrum of the impulse response below 4 kHz
n = 2^nextpow2(max(4*numel(y), Fs));
Y = abs(fft(y(:), n));
fr = (0:n/2-1)'*Fs/n;
b = fr > 100 & fr < 4000;
[pk, loc] = findpeaks(20*log10(Y(b)), 'MinPeakProminence', prominence);
keep = pk > max(pk) - 30;   % no ripples far below the formants (end of the response)
fb = fr(b);
f = fb(loc(keep)).';
a = pk(keep).';
end

function [dev, ddb] = match(fs, as, ft, at)
% every stairs formant with the nearest tubes formant
dev = ones(size(fs));  ddb = inf(size(fs));
for k = 1:numel(fs)*~isempty(ft)
    [~, j] = min(abs(ft - fs(k)));
    dev(k) = abs(ft(j) - fs(k))/fs(k);
    ddb(k) = abs(at(j) - as(k));
end
end
