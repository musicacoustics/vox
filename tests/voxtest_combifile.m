function voxtest_combifile(voxdir)
%VOXTEST_COMBIFILE  Combi with the fold signal from a file (register 0, #49)
%   voxtest_combifile(voxdir) starts VOX in voxdir (a copy of VOX/matlab):
%   - Fold Calc (30 ms) and Combicalc with calculated folds (no coupling).
%     The combi runs again up to the sample with the largest fold signal,
%     where the glottis is open, and keep the flow of foldsig there.
%   - Fold Load of the fold result (writes out_vf_n00000), then the register
%     button switched off (register 0): Combicalc takes the fold signal from
%     the file. Checks: no error, the same fold signal, and the flow derived
%     from it (p*pi*rvoc^2/(rho*c)) equals the flow of foldsig
%   - the same with noise, and with noise and GRON (display of the flow)
%   - Duration longer than the file: the calculation stops at the end of
%     the file signal instead of failing
%   Run it hidden (see runvoxtests): VOX opens its windows.

global GRONF Hndl PARFOLD NOISE Infold Fs %#ok<GVMIS,NUSED> VOX is driven through its globals
fprintf('MATLAB %s, combi with fold file in %s\n', version, voxdir);
cd(voxdir);
vox;
GRONF = 0;
set(Hndl.gronf, 'value', 0);
nfail = 0;

% folds calculated: fold file of 30 ms, combi up to the largest fold signal
setinput(1); type('30');
vox('foldcalc');
nfile = numel(getfield(load(fullfile('out', 'out_vf_n10000.mat')), 'data', 'y')); %#ok<GFLD> results in out/ (#29)
setinput(4); type('30');
vox('combicalc');
d = get(Hndl.figureNumber, 'UserData');
[~, m] = max(abs(d.out.out_vf_voc_vek));
tm = (m - 0.5)/Fs*1000;               % Duration [ms] with exactly m samples
type(sprintf('%.10g', tm));
vox('combicalc');
d = get(Hndl.figureNumber, 'UserData');
ycalc = d.out.out_vf_voc_vek;
ucalc = PARFOLD.var.flow;
check(sprintf('calculated folds: %d samples up to the open glottis, flow %.4g m^3/s', numel(ycalc), ucalc), ...
    numel(ycalc) == m && ucalc > 0);

% Fold Load writes out_vf_n00000; switching the register off selects it
stub = fullfile(tempdir, ['voxtest_combifile_' char(datetime('now', 'Format', 'HHmmssSSS'))]);
mkdir(stub);
fid = fopen(fullfile(stub, 'uigetfile.m'), 'w');
fprintf(fid, 'function [f, p, i] = uigetfile(varargin)\nf = ''out_vf_n10000.mat''; p = [%s filesep]; i = 1;\n', ...
    ['''' strrep(fullfile(voxdir, 'out'), '''', '''''') '''']);
fclose(fid);
warning('off', 'MATLAB:dispatcher:nameConflict');
addpath(stub); rehash;
vox('foldload');
rmpath(stub);
rmdir(stub, 's');
setinput(4);
set(Hndl.modal, 'value', 0); vox('modal');
check('register button off: register 0 (fold signal from the file)', Infold.register == 0);

cases = {'no noise', 0, 0; 'noise', 1, 0; 'noise and GRON', 1, 1};
for k = 1:size(cases, 1)
    NOISE = cases{k, 2}; set(Hndl.noise, 'value', NOISE);
    set(Hndl.gron, 'value', cases{k, 3}); vox('gron');
    type(sprintf('%.10g', tm));
    try
        rng(1);
        vox('combicalc');
        d = get(Hndl.figureNumber, 'UserData');
        yfile = d.out.out_vf_voc_vek;
        ufile = PARFOLD.var.flow;
        ok = numel(yfile) == m && all(isfinite(d.y));
        if k == 1
            check(sprintf('combi from the file: no error, %d samples, fold signal as calculated (max diff %.3g)', ...
                numel(yfile), max(abs(yfile - ycalc))), ok && max(abs(yfile - ycalc)) <= 1e-12*max(abs(ycalc)));
            check(sprintf('flow from the file %.8g = flow of foldsig %.8g (rel. diff %.2g)', ufile, ucalc, ...
                abs(ufile - ucalc)/ucalc), abs(ufile - ucalc) <= 1e-9*ucalc);
        else
            check(sprintf('combi from the file (%s): no error, finite, noise %s', cases{k, 1}, ...
                mat2str(any(d.out.glotnoise_vek ~= 0))), ok && any(d.out.glotnoise_vek ~= 0));
        end
    catch err
        fprintf('FAILED combi from the file (%s): %s (%s line %d)\n', cases{k, 1}, err.message, ...
            err.stack(1).name, err.stack(1).line);
        nfail = nfail + 1;
    end
end

% Duration longer than the file signal
NOISE = 0; set(Hndl.noise, 'value', 0);
set(Hndl.gron, 'value', 0); vox('gron');
type('60');
try
    vox('combicalc');
    d = get(Hndl.figureNumber, 'UserData');
    check(sprintf('Duration 60 ms, file %d samples: stops at the end of the file (%d samples)', nfile, numel(d.y)), ...
        numel(d.y) == nfile && all(isfinite(d.y)));
catch err
    fprintf('FAILED combi longer than the file: %s (%s line %d)\n', err.message, err.stack(1).name, err.stack(1).line);
    nfail = nfail + 1;
end

vox('closevox');
if nfail == 0
    fprintf('RESULT PASS combi with the fold signal from a file: no error, flow from the file equals the flow of foldsig, noise, GRON and a short file work\n');
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
            fprintf('%-100s ok\n', label);
        else
            fprintf('%-100s FAILED\n', label);
            nfail = nfail + 1;
        end
    end
end
