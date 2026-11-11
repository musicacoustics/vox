function voxtest_tubestairs(voxdir)
%VOXTEST_TUBESTAIRS  Tube model and stairs model in the GUI, vowel /a/ (#64, #50)
%   voxtest_tubestairs(voxdir) starts VOX in voxdir (a copy of VOX/matlab)
%   with the default settings (vowel /a/) and compares the two tract
%   models with the same radius vector:
%   - Tract Calc (50 ms impulse response): stairs, and tubes with cones
%     through all points of the radius vector (maxsegments = number of
%     points - 1, maxdevlimit 0), so that both have the same geometry
%     apart from the steps. Pass: formants below 4 kHz within 3 %, levels
%     at the formants within 6 dB.
%   - Tubes with the default of 2 cones: calculated, finite (reported).
%   - Combi (30 ms, calculated folds): stairs and tubes (all points).
%     Pass: finite, peak of the mouth signal of the tubes within a factor
%     2 of the stairs (before #64 the tubes were about 10x louder, #50),
%     Infold.pin_gl_ac set in both.
%   Run it hidden (see runvoxtests): VOX opens its windows.

global TMAX GRONF Hndl Infold %#ok<GVMIS> VOX is driven through its globals
fprintf('MATLAB %s, tubes and stairs in %s\n', version, voxdir);
cd(voxdir);
vox;
GRONF = 0;
set(Hndl.gronf, 'value', 0);
nfail = 0;

% tract alone
setdur(50);
setmode(1);
vox('tractcalc');
st = get(Hndl.figureNumber, 'UserData');
[fs, as] = formants(st.y, st.Fs);
setmode(2);
d = get(Hndl.figureNumber, 'UserData');
d.properties.maxsegments = numel(d.radius) - 1;
d.properties.maxdevlimit = 0;
set(Hndl.figureNumber, 'UserData', d);
vox('tractcalc');
tt = get(Hndl.figureNumber, 'UserData');
[ft, at] = formants(tt.y, tt.Fs);
n = min(numel(fs), numel(ft));
dev = abs(ft(1:n) - fs(1:n))./fs(1:n);
ddb = abs(at(1:n) - as(1:n));
fprintf('stairs: Fs %d Hz, %d segments, formants %s Hz, levels %s dB\n', st.Fs, numel(st.radius), ...
    mat2str(round(fs)), mat2str(round(as, 1)));
fprintf('tubes:  Fs %d Hz, %d cones,    formants %s Hz, levels %s dB, damping (xi) %.4g\n', tt.Fs, ...
    size(tt.tubes, 1), mat2str(round(ft)), mat2str(round(at, 1)), tt.properties.damping);
check(sprintf('tract: tubes (all points) and stairs, %d formants below 4 kHz, max dev %.2f %%, max level diff %.1f dB', ...
    n, 100*max(dev), max(ddb)), numel(ft) == numel(fs) && all(dev < 0.03) && all(ddb < 6) ...
    && all(isfinite(tt.y)));

d = get(Hndl.figureNumber, 'UserData');
d.properties.maxsegments = 2;
set(Hndl.figureNumber, 'UserData', d);
vox('tractcalc');
t2 = get(Hndl.figureNumber, 'UserData');
f2 = formants(t2.y, t2.Fs);
check(sprintf('tract: tubes with the default of 2 cones, formants %s Hz', mat2str(round(f2))), ...
    all(isfinite(t2.y)) && ~isempty(f2));

% combi
d.properties.maxsegments = numel(d.radius) - 1;
set(Hndl.figureNumber, 'UserData', d);
setinput(1); setdur(30);
vox('foldcalc');
peak = zeros(1, 2);
names = {'stairs', 'tubes'};
for m = 1:2
    setmode(m);
    setinput(4); setdur(30);
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
    fprintf('RESULT PASS tubes and stairs: same formants and levels for /a/, combi of the same order\n');
else
    fprintf('RESULT FAIL %d checks failed\n', nfail);
    exit(1);
end

    function setmode(v)
        set(Hndl.TractCalcMode, 'value', v);
        vox('tractcalcmode');
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

function [f, a] = formants(y, Fs)
% peaks of the spectrum of the impulse response below 4 kHz
n = 2^nextpow2(max(4*numel(y), Fs));
Y = abs(fft(y(:), n));
fr = (0:n/2-1)'*Fs/n;
b = fr > 100 & fr < 4000;
[pk, loc] = findpeaks(20*log10(Y(b)), 'MinPeakProminence', 6);
fb = fr(b);
f = fb(loc).';
a = pk.';
end
