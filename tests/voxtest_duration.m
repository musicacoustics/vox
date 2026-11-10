function voxtest_duration(voxdir)
%VOXTEST_DURATION  Duration field: defaults per Input mode, files keep it
%   voxtest_duration(voxdir) starts VOX in voxdir (a copy of VOX/matlab)
%   and checks the Duration field (upper left) and TMAX:
%   - switching Input to Fold or Combi sets 200 ms, to Tract 20 ms,
%     VF*VT keeps the value
%   - a typed value or the slider applies to the next calculation and is
%     not reset by the display after the calculation
%   - Fold Load of a 200 ms example result does not change the field
%   Run it hidden (see runvoxtests): VOX opens its windows.

global TMAX GRONF Hndl %#ok<GVMIS> VOX is driven through its globals
fprintf('MATLAB %s, duration tests in %s\n', version, voxdir);
cd(voxdir);
vox;
GRONF = 0;
set(Hndl.gronf, 'value', 0);
nfail = 0;
expect('start (Input Fold)', 200);
setinput(2); expect('Input -> Tract (example result is 200 ms long)', 20);
vox('tractcalc'); expectresult('tract calc', 20); expect('field after tract calc', 20);
type('50'); vox('tractcalc'); expectresult('tract calc after typing 50', 50); expect('field after tract calc', 50);
setinput(1); expect('Input -> Fold', 200);
type('30'); vox('foldcalc'); expectresult('fold calc after typing 30', 30); expect('field after fold calc', 30);
setinput(3); expect('Input -> VF*VT keeps the value', 30);
setinput(4); expect('Input -> Combi', 200);
type('30'); vox('combicalc'); expectresult('combi calc after typing 30', 30);
setinput(1); expect('Input -> Fold', 200);
set(Hndl.Duration, 'value', 120); vox('refreshDuration', 'slider'); expect('slider -> 120', 120);
% Fold Load with the 200 ms example result: a stub returns its name
stub = fullfile(tempdir, ['voxtest_duration_' char(datetime('now', 'Format', 'HHmmssSSS'))]);
mkdir(stub);
fid = fopen(fullfile(stub, 'uigetfile.m'), 'w');
fprintf(fid, 'function [f, p, i] = uigetfile(varargin)\nf = ''out_vf_n10000.mat''; p = [%s filesep]; i = 1;\n', ...
    ['''' strrep(fullfile(voxdir, 'out'), '''', '''''') '''']);
fclose(fid);
warning('off', 'MATLAB:dispatcher:nameConflict');
addpath(stub); rehash;
try
    vox('foldload');
    expect('Fold Load of a 200 ms result keeps the field', 120);
catch err
    fprintf('FAILED Fold Load: %s (%s line %d)\n', err.message, err.stack(1).name, err.stack(1).line);
    nfail = nfail + 1;
end
rmpath(stub);
rmdir(stub, 's');
vox('closevox');
if nfail == 0
    fprintf('RESULT PASS defaults 200/20/200 ms, typed values kept, Fold Load keeps the field\n');
else
    fprintf('RESULT FAIL %d checks failed\n', nfail);
    exit(1);
end

    function setinput(v)
        set(Hndl.INPUT, 'value', v);
        vox('input');
    end
    function type(s)
        set(Hndl.DurationStr, 'string', s);
        vox('refreshDuration', 'string');
    end
    function expect(label, ms)
        f = str2double(get(Hndl.DurationStr, 'string'));
        ok = TMAX == ms && f == ms && get(Hndl.Duration, 'value') == ms;
        fprintf('%-50s TMAX %6g | field %6g  %s\n', label, TMAX, f, okstr(ok, ms));
        nfail = nfail + ~ok;
    end
    function expectresult(label, ms)
        d = get(Hndl.figureNumber, 'UserData');
        len = 1000*numel(d.y)/d.Fs;
        ok = abs(len - ms) <= 1000/d.Fs*1.5;   % ceil/round of the sample count
        fprintf('%-50s result %.2f ms  %s\n', label, len, okstr(ok, ms));
        nfail = nfail + ~ok;
    end
end

function s = okstr(ok, ms)
if ok, s = 'ok'; else, s = sprintf('FAILED (expected %g ms)', ms); end
end
