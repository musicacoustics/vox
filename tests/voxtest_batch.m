function voxtest_batch(voxdir)
%VOXTEST_BATCH  Variation over time in Fold Calc and Combi: batch mode and control file (#74)
%   voxtest_batch(voxdir) works in voxdir (a copy of VOX/matlab):
%   - Fold Calc 60 ms with the batch mode (window "controlfile": periodic,
%     50 Hz, 10 %, active stress and subglottal pressure; vocal tract also
%     chosen): pressure and tension change over the time steps within
%     +-10 % (data.control), the result differs from Fold Calc without
%     batch, afterwards both are back at their values before, a second run
%     is bit-identical (no drift), the vocal tract is ignored with a message
%   - the fold display (GRON) shows the varying p_s0
%   - Combi 30 ms with the batch mode: pressure modulated (planned
%     pressure plotted), the result differs from Combi without batch,
%     pressure and tension back afterwards, a second run bit-identical
%   - Fold Calc with control files: pressure vibrato follows the file, the
%     mouth opening is ignored with a warning
%   - Fold Calc and Combi without batch/control afterwards: bit-identical
%     to the first runs
%   Run it hidden (see runvoxtests).
%   The batch values are set in the window after choosing the Input mode,
%   because every display of a result sets the window to its settings.

global GRONF GRON Hndl Infold Fs %#ok<GVMIS,NUSED> VOX is driven through its globals
fprintf('MATLAB %s, batch mode and control files in Fold Calc and Combi in %s\n', version, voxdir);
cd(voxdir);
nfail = 0;
here = fileparts(mfilename('fullpath'));
warning('off', 'MATLAB:dispatcher:nameConflict');
addpath(fullfile(here, 'stubs')); rehash;
tmp = tempname; mkdir(tmp);

vox;
GRONF = 0; set(Hndl.gronf, 'value', 0);
% plain runs
setinput(1); type('60');
vox('foldcalc');
yf0 = getfield(get(Hndl.figureNumber, 'UserData'), 'y');
ptg0 = Infold.ptg; tv0 = Infold.tvakt;
setinput(4); type('30');
vox('combicalc');
yc0 = getfield(get(Hndl.figureNumber, 'UserData'), 'y');

% batch on: the window opens
set(Hndl.batch, 'value', 1); vox('batchedit');

% Fold Calc with batch
setinput(1); type('60');
setbatch();   % periodic 50 Hz, 10 %, stress, pressure and tract
out = evalc('vox(''foldcalc'')');
d1 = getfield(load(voxoutdir('out_vf_n10000.mat')), 'data');   % the fold result as saved (data.control)
p = d1.control.values(:, 1); v = d1.control.values(:, 2);
check(sprintf('Fold Calc + batch: pressure %.4g..%.4g Pa (%d values), tension %.4g..%.4g', min(p), max(p), ...
    numel(unique(p)), min(v), max(v)), numel(unique(p)) > 5 && numel(unique(v)) > 5 && ...
    max(abs(p/ptg0 - 1)) <= 0.1 + 1e-9 && max(p) > ptg0*1.05 && max(abs(v/tv0 - 1)) <= 0.1 + 1e-9);
check('Fold Calc + batch: result differs from Fold Calc without batch', ~isequal(d1.y, yf0));
check('Fold Calc + batch: pressure and tension back afterwards (also the sliders)', Infold.ptg == ptg0 && ...
    Infold.tvakt == tv0 && get(Hndl.ptg, 'Value') == ptg0);
check('Fold Calc + batch: vocal tract ignored with a message', contains(out, 'needs Combi'));
vox('foldcalc');
d2 = get(Hndl.figureNumber, 'UserData');
check('Fold Calc + batch: second run bit-identical (no drift)', isequal(d2.y, d1.y));

% the fold display shows p_s0 varying
set(Hndl.gron, 'value', 1); vox('gron');
vox('foldcalc');
f = findobj('Name', 'Sound pressure during calculation');
ax = findobj(f, 'Type', 'axes');
lab = arrayfun(@(a) char(string(get(get(a, 'YLabel'), 'String'))), ax, 'UniformOutput', false);
k = find(contains(lab, 'p_{s0}'), 1);
ok = false;
if ~isempty(k)   % p_s0: the line that stays within +-11 % of the pressure after the onset
    ln = findobj(ax(k), 'Type', 'line');
    yy = arrayfun(@(l) get(l, 'YData'), ln, 'UniformOutput', false);
    ok = any(cellfun(@(y) all(abs(y(round(end/2):end)/ptg0 - 1) < 0.11) && ...
        numel(unique(y(round(end/2):end))) > 3, yy));
end
check('Fold display (GRON): p_s0 varies', ok);
set(Hndl.gron, 'value', 0); vox('gron');

% Combi with batch
setinput(4); type('30');
setbatch();
close(findobj('Type', 'figure', 'Number', 613));
vox('combicalc');
c1 = get(Hndl.figureNumber, 'UserData');
check('Combi + batch: pressure modulated (planned pressure plotted, fig. 613)', ...
    ~isempty(findobj('Type', 'figure', 'Number', 613)));
check('Combi + batch: result differs from Combi without batch', ~isequal(c1.y, yc0));
check('Combi + batch: pressure and tension back afterwards', Infold.ptg == ptg0 && Infold.tvakt == tv0);
vox('combicalc');
c2 = get(Hndl.figureNumber, 'UserData');
check('Combi + batch: second run bit-identical (no drift)', isequal(c2.y, c1.y));
set(Hndl.batch, 'value', 0); vox('batchedit');

% Fold Calc with control files
setinput(1); type('60');
fv = voxvibrato(fullfile(tmp, 'vib.txt'), 'ptg', 0.2, 100, 0.1, 1e-4);
vox('setcontrol', fv);
vox('foldcalc');
d = getfield(load(voxoutdir('out_vf_n10000.mat')), 'data');   % saved fold result (data.control)
n = numel(d.y); t = (0:n-1)'/Fs;
dev = max(abs(d.control.values(:, 1) - ptg0*(1 + 0.2*sin(2*pi*100*t))))/ptg0;
check(sprintf('Fold Calc + control file: pressure follows the file (dev %.2g), back afterwards', dev), ...
    dev < 1e-3 && ~isequal(d.y, yf0) && Infold.ptg == ptg0);
fm = voxvibrato(fullfile(tmp, 'mouth.txt'), 'mouth', 0.2, 100, 0.1, 1e-4);
vox('setcontrol', fm);
lastwarn('');
vox('foldcalc');
[~, id] = lastwarn;
d = get(Hndl.figureNumber, 'UserData');
check('Fold Calc + mouth opening: ignored with a warning, result as without control', ...
    strcmp(id, 'vox:control') && isequal(d.y, yf0));
vox('setcontrol', '');

% without batch and control file afterwards
vox('foldcalc');
check('Fold Calc afterwards: bit-identical to the first', isequal(getfield(get(Hndl.figureNumber, 'UserData'), 'y'), yf0));
setinput(4); type('30');
vox('combicalc');
check('Combi afterwards: bit-identical to the first', isequal(getfield(get(Hndl.figureNumber, 'UserData'), 'y'), yc0));

vox('closevox');
rmpath(fullfile(here, 'stubs'));
rmdir(tmp, 's');
if nfail == 0
    fprintf('RESULT PASS pressure and tension vary over time in Fold Calc (batch, control file), all three in Combi; values back afterwards, no drift\n');
else
    fprintf('RESULT FAIL %d checks failed\n', nfail);
    exit(1);
end

    function setbatch()
        % batch window: periodic 50 Hz, 10 %, 10 segments per period;
        % active stress, subglottal pressure and vocal tract
        h = guihandles(Hndl.controlfig);
        set(h.rb_periodic, 'Value', 1); controlfile('periodic');
        set(h.ed_freq, 'String', '50');  controlfile('ed_freq');
        set(h.ed_depth, 'String', '10'); controlfile('ed_depth');
        set(h.ed_seg1, 'String', '10');  controlfile('ed_seg1');
        for b = {'rb_actstr', 'rb_subpre', 'rb_trac'}
            set(h.(b{1}), 'Value', 1); controlfile('');
        end
    end
    function setinput(val)
        set(Hndl.INPUT, 'value', val);
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
