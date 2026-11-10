function results = runvoxtests(varargin)
%RUNVOXTESTS  Run the VOX tests hidden in separate MATLAB processes
%   runvoxtests runs all tests and compares with the git branch main.
%
%   runvoxtests('Tests', {'regression','guisweep'}) runs only these tests:
%      'codeanalyzer'  Code Analyzer messages of the changed files vs. baseline
%      'regression'    fold, tract (stairs), combi (stairs) bit-identical with baseline
%      'guisweep'      callbacks of all controls of the main window; no new errors
%      'tubes'         tube model against a frequency-domain reference, stability
%
%   runvoxtests('Baseline', 'origin/main') compares with another git ref;
%   runvoxtests('Baseline', '') skips the comparisons.
%
%   results = runvoxtests(...) returns a struct array with the fields
%   name, passed, summary and log (path of the log file).
%
%   Every test runs in its own MATLAB process of this release, started with
%   -batch and -noFigureWindows (Windows) or -nodisplay (Linux, macOS): no
%   window appears and the computer stays usable. Start runvoxtests itself
%   in the background as well, e.g. from a shell:
%      matlab -noFigureWindows -batch "cd tests; runvoxtests"
%   VOX writes its results into its own folder, so every test works on a
%   copy of VOX/matlab in tempdir; the repository is not changed.
%
%   Requires MATLAB R2025a or newer, the Signal Processing Toolbox and git
%   (for the baseline).
%
%   See also voxtest_regression, voxtest_guisweep, voxtest_tubes.

if isMATLABReleaseOlderThan("R2025a")
    error('runvoxtests:release', 'The VOX tests need MATLAB R2025a or newer.');
end
p = inputParser;
addParameter(p, 'Tests', {'codeanalyzer', 'regression', 'guisweep', 'tubes'});
addParameter(p, 'Baseline', 'main');
addParameter(p, 'WorkDir', '');
parse(p, varargin{:});
opt = p.Results;
tests = cellstr(opt.Tests);

testsdir = fileparts(mfilename('fullpath'));
root     = fileparts(testsdir);
src      = fullfile(root, 'VOX', 'matlab');
work     = opt.WorkDir;
if isempty(work)
    work = fullfile(tempdir, 'voxtests', char(datetime('now', 'Format', 'yyyyMMdd_HHmmss')));
end
if ~isfolder(work)
    mkdir(work);
end
fprintf('VOX tests, MATLAB %s\nsource   %s\nwork dir %s\n', version, src, work);

base = '';
if ~isempty(opt.Baseline)
    base = exportref(root, opt.Baseline, fullfile(work, 'baseline'));
    if isempty(base)
        fprintf('baseline %s: not available, comparisons skipped\n', opt.Baseline);
    else
        fprintf('baseline %s\n', opt.Baseline);
    end
end

results = struct('name', {}, 'passed', {}, 'summary', {}, 'log', {});
for k = 1:numel(tests)
    name = tests{k};
    fprintf('\n== %s\n', name);
    switch name
        case 'codeanalyzer'
            files = changedfiles(root, opt.Baseline);
            [ok, summary] = voxtest_codeanalyzer(src, base, files);
            logfile = '';
        case 'regression'
            [ok, summary, logfile] = regression(testsdir, src, base, work);
        case 'guisweep'
            [ok, summary, logfile] = guisweep(testsdir, src, base, work);
        otherwise   % tests of the change itself: voxtest_<name>(voxdir)
            if ~exist(['voxtest_' name], 'file')
                error('runvoxtests:test', 'Unknown test ''%s''.', name);
            end
            copy = copyvox(src, fullfile(work, name));
            logfile = fullfile(work, [name '.log']);
            [ok, out] = runhidden(testsdir, sprintf('voxtest_%s(%s)', name, q(copy)), logfile);
            summary = resultline(out);
    end
    fprintf('%s: %s\n', upper(passtext(ok)), summary);
    results(end+1) = struct('name', name, 'passed', ok, 'summary', summary, 'log', logfile); %#ok<AGROW>
end

fprintf('\n== summary\n');
for k = 1:numel(results)
    fprintf('%-13s %-4s %s\n', results(k).name, passtext(results(k).passed), results(k).summary);
end
fprintf('logs in %s\n', work);
if nargout == 0
    clear results   % no "ans" output when called as a command
end
end

% -------------------------------------------------------------------------
function [ok, summary, logfile] = regression(testsdir, src, base, work)
% fixed runs on the change and on the baseline, then a bitwise comparison
logfile = fullfile(work, 'regression.log');
new = fullfile(work, 'regression_new.mat');
[ok, out] = runhidden(testsdir, sprintf('voxtest_regression(%s, %s)', ...
    q(copyvox(src, fullfile(work, 'regression_new'))), q(new)), logfile);
if ~ok
    summary = ['runs failed: ' resultline(out)];
    return
end
if isempty(base)
    summary = 'runs OK, no baseline to compare';
    return
end
old = fullfile(work, 'regression_base.mat');
[okb, outb] = runhidden(testsdir, sprintf('voxtest_regression(%s, %s)', ...
    q(copyvox(base, fullfile(work, 'regression_base'))), q(old)), [logfile(1:end-4) '_base.log']);
if ~okb
    ok = false;
    summary = ['baseline runs failed: ' resultline(outb)];
    return
end
A = load(old); B = load(new);
diffs = {};
for f = fieldnames(A.R)'
    a = A.R.(f{1}); b = B.R.(f{1});
    if ~isequal(a, b)
        diffs{end+1} = f{1}; %#ok<AGROW>
    end
end
ok = isempty(diffs);
if ok
    summary = sprintf('%s bit-identical with the baseline', strjoin(fieldnames(A.R)', ', '));
else
    summary = sprintf('DIFFERENT from the baseline: %s', strjoin(diffs, ', '));
end
end

% -------------------------------------------------------------------------
function [ok, summary, logfile] = guisweep(testsdir, src, base, work)
% sweep on the change and on the baseline; errors only on the change fail
logfile = fullfile(work, 'guisweep.log');
new = fullfile(work, 'guisweep_new.mat');
runhidden(testsdir, sprintf('voxtest_guisweep(%s, %s)', ...
    q(copyvox(src, fullfile(work, 'guisweep_new'))), q(new)), logfile);
if ~isfile(new)
    ok = false; summary = 'sweep did not finish, see log';
    return
end
B = load(new);
olderr = {};
if ~isempty(base)
    old = fullfile(work, 'guisweep_base.mat');
    runhidden(testsdir, sprintf('voxtest_guisweep(%s, %s)', ...
        q(copyvox(base, fullfile(work, 'guisweep_base'))), q(old)), [logfile(1:end-4) '_base.log']);
    if isfile(old)
        A = load(old); olderr = A.S.errors;
    end
end
newerr = setdiff(B.S.errors, olderr);
ok = isempty(newerr);
summary = sprintf('%d callbacks, %d errors (%d also on the baseline)', ...
    B.S.nrun, numel(B.S.errors), numel(B.S.errors) - numel(newerr));
for k = 1:numel(newerr)
    summary = sprintf('%s; NEW: %s', summary, newerr{k});
end
end

% -------------------------------------------------------------------------
function [ok, out] = runhidden(testsdir, call, logfile)
% run call in a new MATLAB process of this release without windows
exe = fullfile(matlabroot, 'bin', 'matlab');
if ispc
    exe  = [exe '.exe'];
    hide = '-noFigureWindows';
else
    hide = '-nodisplay';
end
cmd = sprintf('"%s" %s -batch "addpath(%s); %s"', exe, hide, q(testsdir), call);
[status, out] = system(cmd);
fid = fopen(logfile, 'w');
if fid > 0
    fprintf(fid, '%s\n', out);
    fclose(fid);
end
[~, verdict] = resultline(out);
ok = status == 0 && strcmp(verdict, 'PASS');
end

function [s, verdict] = resultline(out)
% text and verdict (PASS/FAIL) of the last "RESULT ..." line of a test
t = regexp(out, 'RESULT (\w+) ([^\r\n]*)', 'tokens');
if isempty(t)
    s = 'no result (crashed?), see log';
    verdict = '';
else
    s = t{end}{2};
    verdict = t{end}{1};
end
end

function d = copyvox(src, d)
% VOX writes results into its own folder: work on a copy
if isfolder(d)
    rmdir(d, 's');
end
mkdir(d);
copyfile(fullfile(src, '*'), d);
end

function base = exportref(root, ref, dest)
% VOX/matlab of a git ref (git archive), '' if not available
base = '';
zipfile = [dest '.zip'];
[status, msg] = system(sprintf('git -C "%s" archive --format=zip -o "%s" %s VOX/matlab', root, zipfile, ref));
if status ~= 0
    fprintf('git archive %s failed: %s\n', ref, strtrim(msg));
    return
end
unzip(zipfile, dest);
delete(zipfile);
base = fullfile(dest, 'VOX', 'matlab');
end

function files = changedfiles(root, ref)
% .m files in VOX/matlab that differ from ref, including uncommitted and new ones
files = {};
if isempty(ref)
    return
end
[s1, a] = system(sprintf('git -C "%s" diff --name-only %s -- VOX/matlab', root, ref));
[s2, b] = system(sprintf('git -C "%s" ls-files --others --exclude-standard VOX/matlab', root));
if s1 ~= 0 || s2 ~= 0
    return
end
names = splitlines(strtrim([a newline b]));
names = names(endsWith(names, '.m'));
files = unique(cellfun(@(f) [regexprep(f, '^.*/', '')], names, 'UniformOutput', false))';
end

function s = q(str)
% MATLAB string literal
s = ['''' strrep(str, '''', '''''') ''''];
end

function s = passtext(ok)
if ok, s = 'pass'; else, s = 'FAIL'; end
end
