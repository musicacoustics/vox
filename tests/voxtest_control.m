function voxtest_control(voxdir)
%VOXTEST_CONTROL  Control files: parameters over time in a combi run (#74)
%   voxtest_control(voxdir) works in voxdir (a copy of VOX/matlab):
%   - voxcontrolread: file with column names, old FE file (time in s,
%     positions in um), clear errors for broken files
%   - Combi 30 ms without control file; with a control file that keeps
%     pressure and tension constant: bit-identical result, saved under
%     the name with the control file, values in data.control
%   - vibrato of the subglottal pressure, the vocal fold tension and the
%     mouth opening: the values follow the file, the result changes, and
%     afterwards pressure, tension and area function are back
%   - mouth opening with tubes: ignored with a warning
%   - FE005 (old FE file) and adduction.txt: positions of the vocal folds
%     as interpolated from the file, positions back afterwards
%   - checkbox Control and its list ("other file..." cancelled), and
%     vox('setcontrol', ''); a combi run afterwards is bit-identical to
%     the first one
%   Dialogs are replaced by stubs (cancel). Run it hidden (see runvoxtests).

global GRONF Hndl Infold Fs %#ok<GVMIS> VOX is driven through its globals
fprintf('MATLAB %s, control files in %s\n', version, voxdir);
cd(voxdir);
nfail = 0;
here = fileparts(mfilename('fullpath'));
warning('off', 'MATLAB:dispatcher:nameConflict');
addpath(fullfile(here, 'stubs')); rehash;   % file dialogs cancel
ex = fullfile(voxdir, 'examples', 'control');

% reading
c = voxcontrolread(fullfile(ex, 'FE005unilatmitzeit.txt'));
M = readmatrix(fullfile(ex, 'FE005unilatmitzeit.txt'), 'FileType', 'text');
check(sprintf('FE005: old FE format, %d rows, time 0..%g s', numel(c.t), c.t(end)), ...
    strcmp(c.format, 'FE') && numel(c.t) == 175 && c.t(end) == 3.48);
check('FE005: columns 2-4 wmaxla, 5-7 w0lp, 8-10 wmaxra, 11-13 w0rp, mm -> um', ...
    isequal(c.names(1:12), {'wmaxla_x','wmaxla_y','wmaxla_z','w0lp_x','w0lp_y','w0lp_z', ...
    'wmaxra_x','wmaxra_y','wmaxra_z','w0rp_x','w0rp_y','w0rp_z'}) && isequal(c.values(:, 1:12), 1000*M(:, 2:13)));
c = voxcontrolread(fullfile(ex, 'vibrato_ptg.txt'));
check('vibrato_ptg.txt: columns time, ptg_factor', strcmp(c.format, 'columns') && isequal(c.names, {'ptg_factor'}));
tmp = tempname; mkdir(tmp);
bad = {'time ptg\n0 800\n0.1\n', 'line 2'; 'zeit ptg\n0 800\n', 'first column'; ...
    'time foo\n0 1\n', 'unknown column'; 'time ptg\n0 800\n0 900\n', 'increase'};
for k = 1:size(bad, 1)
    f = fullfile(tmp, sprintf('bad%d.txt', k));
    writetext(f, sprintf(bad{k, 1}));
    try
        voxcontrolread(f);
        check(['broken file (' bad{k, 2} '): error'], false);
    catch err
        check(['broken file (' bad{k, 2} '): ' err.message], strcmp(err.identifier, 'vox:control'));
    end
end

% combi without and with a constant control file
vox;
GRONF = 0; set(Hndl.gronf, 'value', 0);
setinput(4); type('30');
vox('combicalc');
d0 = get(Hndl.figureNumber, 'UserData');
y0 = d0.y; ptg0 = Infold.ptg; tv0 = Infold.tvakt; r0 = d0.radius; w00 = Infold.w0lp;
check('combi 30 ms without control file: out/out_cs_a10000.mat', isfile(voxoutdir('out_cs_a10000.mat')));
f = fullfile(tmp, 'constant.txt');
writetext(f, sprintf('time ptg tvakt\n0 %.17g %.17g\n1 %.17g %.17g\n', ptg0, tv0, ptg0, tv0));
vox('setcontrol', f);
vox('combicalc');
d = get(Hndl.figureNumber, 'UserData');
check('constant control file: result bit-identical', isequal(d.y, y0));
check('constant control file: saved as out_cs_a10000_constant, values in data.control', ...
    isfile(voxoutdir('out_cs_a10000_constant.mat')) && isfield(d, 'control') && ...
    isequal(d.control.names, {'ptg', 'tvakt'}) && size(d.control.values, 1) == numel(y0));

% vibrato of pressure, tension, mouth
n = numel(y0);
t = (0:n-1)'/Fs;
names = {'ptg', 'tvakt', 'mouth'};
for k = 1:3
    f = voxvibrato(fullfile(tmp, ['vib_' names{k} '.txt']), names{k}, 0.2, 100, 0.05, 1e-4);
    vox('setcontrol', f);
    vox('combicalc');
    d = get(Hndl.figureNumber, 'UserData');
    switch names{k}
        case 'ptg', base = ptg0;
        case 'tvakt', base = tv0;
        otherwise, base = 1;
    end
    expected = base*(1 + 0.2*sin(2*pi*100*t));
    dev = max(abs(d.control.values(:, 1) - expected))/base;
    back = Infold.ptg == ptg0 && Infold.tvakt == tv0 && isequal(d.radius, r0);
    dd = get(Hndl.figureNumber, 'UserData');
    check(sprintf('vibrato %s (+-20 %%, 100 Hz): values follow the file (dev %.2g), result changes (%.3g), values back afterwards', ...
        names{k}, dev, max(abs(d.y - y0))), dev < 1e-3 && max(abs(d.y - y0)) > 0 && back && isequal(dd.radius, r0));
end

% mouth opening with tubes: ignored with a warning
set(Hndl.TractCalcMode, 'Value', 2);
lastwarn('');
S = voxcontrolapply('init', fullfile(ex, 'vibrato_mouth.txt'), t');
[~, id] = lastwarn;
check('mouth opening with tubes: ignored with a warning', isempty(S.field) && strcmp(id, 'vox:control'));
set(Hndl.TractCalcMode, 'Value', 1);

% positions: old FE file and adduction.txt
vox('setcontrol', fullfile(ex, 'FE005unilatmitzeit.txt'));
vox('combicalc');
d = get(Hndl.figureNumber, 'UserData');
c = voxcontrolread(fullfile(ex, 'FE005unilatmitzeit.txt'));
ref = interp1(c.t, c.values(:, 1:12), t);
k4 = find(strcmp(d.control.names, 'w0lp_x'));
check(sprintf('FE005: positions per sample interpolated from the rows (time in s), max dev %.2g um', ...
    max(abs(d.control.values(:, 1:12) - ref), [], 'all')), max(abs(d.control.values(:, 1:12) - ref), [], 'all') < 1e-9 ...
    && ~isempty(k4) && isequal(Infold.w0lp, w00));
check('FE005: saved as out_cs_a10000_FE005unilatmitzeit', isfile(voxoutdir('out_cs_a10000_FE005unilatmitzeit.mat')));
vox('setcontrol', fullfile(ex, 'adduction.txt'));
vox('combicalc');
d = get(Hndl.figureNumber, 'UserData');
w = d.control.values(:, strcmp(d.control.names, 'w0lp_x'));
check(sprintf('adduction: w0 from %g um to %g um, positions back afterwards', w(1), w(end)), ...
    w(1) == 300 && abs(w(end) - (300 - 275*min(t(end)/0.05, 1))) < 1e-9 && isequal(Infold.w0lp, w00));

% checkbox and list
vox('setcontrol', '');
set(Hndl.FE, 'Value', 1); vox('FEchange');
s = get(Hndl.PARAM, 'String');
check('checkbox Control: list with the example files and "other file..."', ...
    all(ismember({'vibrato_ptg.txt', 'adduction.txt', 'FE005unilatmitzeit.txt'}, s)) && strcmp(s{end}, 'other file...'));
k = find(strcmp(s, 'adduction.txt'));
set(Hndl.PARAM, 'Value', k); vox('paradisplay');
before = voxcontrolfile();
set(Hndl.PARAM, 'Value', numel(s)); vox('paradisplay');   % other file..., dialog cancelled
check('list: "other file..." cancelled keeps the choice', strcmp(voxcontrolfile(), before) && endsWith(before, 'adduction.txt'));
set(Hndl.FE, 'Value', 0); vox('FEchange');
check('checkbox off: no control file', isempty(voxcontrolfile()));
vox('combicalc');
d = get(Hndl.figureNumber, 'UserData');
check('combi without control file afterwards: bit-identical to the first', isequal(d.y, y0) && ~isfield(d, 'control'));

vox('closevox');
rmpath(fullfile(here, 'stubs'));
rmdir(tmp, 's');
if nfail == 0
    fprintf('RESULT PASS control files: reading, constant file bit-identical, vibrato of pressure, tension and mouth, positions (FE, adduction), values back afterwards, GUI\n');
else
    fprintf('RESULT FAIL %d checks failed\n', nfail);
    exit(1);
end

    function setinput(v)
        set(Hndl.INPUT, 'value', v);
        eval(get(Hndl.INPUT, 'Callback'));
    end
    function type(s)
        set(Hndl.DurationStr, 'string', s);
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

function writetext(file, txt)
fid = fopen(file, 'w');
fwrite(fid, txt);
fclose(fid);
end
