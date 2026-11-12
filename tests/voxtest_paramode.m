function voxtest_paramode(voxdir)
%VOXTEST_PARAMODE  Parameter mode (Para): profiles are stored and calculated (#74)
%   voxtest_paramode(voxdir) works in voxdir (a copy of VOX/matlab):
%   - new parameter file in out/; two profiles: vowel /a/ with the
%     defaults, and vowel /aa/ with a control file (pressure vibrato) and
%     another subglottal pressure; before saving each one a Combicalc of
%     the same settings gives the reference result
%   - "save settings" only stores (no calculation); a Combicalc afterwards
%     adds no profile
%   - "start" calculates every profile: out/para_<file>_<n>.mat with the
%     profile in data.profile, each bit-identical to its reference
%   - a profile of an older version (without Infold.vflength and without
%     control) runs with parametermode('run', file)
%   - "refresh" sets VOX to profile 2 (vowel, control file, pressure)
%   - "load" with a .txt chooses that control file
%   Dialogs are replaced by stubs. Run it hidden (see runvoxtests).

global GRONF Hndl Infold %#ok<GVMIS> VOX is driven through its globals
fprintf('MATLAB %s, parameter mode in %s\n', version, voxdir);
cd(voxdir);
nfail = 0;
here = fileparts(mfilename('fullpath'));
ex = fullfile(voxdir, 'examples', 'control');
stub = fullfile(tempdir, ['voxtest_paramode_' char(datetime('now', 'Format', 'HHmmssSSS'))]);
mkdir(stub);
writetext(fullfile(stub, 'uigetfile.m'), sprintf(['function [f, p, i] = uigetfile(varargin)\n' ...
    'r = getappdata(0, ''voxtest_get'');\n' ...
    'if isempty(r), f = 0; p = 0; i = 0; else, f = r{1}; p = [r{2} filesep]; i = 1; end\n']));
writetext(fullfile(stub, 'uiputfile.m'), sprintf(['function [f, p, i] = uiputfile(varargin)\n' ...
    'r = getappdata(0, ''voxtest_put'');\n' ...
    'if isempty(r), f = 0; p = 0; i = 0; else, f = r{1}; p = [r{2} filesep]; i = 1; end\n']));
warning('off', 'MATLAB:dispatcher:nameConflict');
addpath(fullfile(here, 'stubs')); addpath(stub); rehash;

vox;
GRONF = 0; set(Hndl.gronf, 'value', 0);
setinput(4); type('30');
parametermode('initialize');
setappdata(0, 'voxtest_put', {'paratest.mat', voxoutdir});
parametermode('new');
pfile = voxoutdir('paratest.mat');
check('new parameter file in out/', isfile(pfile));

% profile 1: vowel /a/, defaults; reference first
vox('combicalc');
d = get(Hndl.figureNumber, 'UserData'); yref1 = d.y;
before = dir(voxoutdir('out_c*.mat'));
parametermode('save');
% profile 2: vowel /aa/, pressure vibrato, 1100 Pa (the pressure last: every
% display of a result takes pressure and tension from the result)
set(Hndl.VOWEL, 'value', 8); vox('refreshPopup');
vox('setcontrol', fullfile(ex, 'vibrato_ptg.txt'));
set(Hndl.ptgStr, 'String', '1100'); vox('refreshptg', 'string');
vox('combicalc');
d = get(Hndl.figureNumber, 'UserData'); yref2 = d.y;
check('reference of profile 2 with control file', strcmp(d.filename, 'out_csaa10000_vibrato_ptg'));
mid = dir(voxoutdir('out_c*.mat'));
parametermode('save');
after = dir(voxoutdir('out_c*.mat'));
S = load(pfile);
check(sprintf('two profiles: vowel %s, pressure %s, control %s', mat2str([S.datas.vowel]), ...
    mat2str([S.datas.PTG]), strjoin(cellfun(@ctrlname, {S.datas.control}, 'UniformOutput', false), '|')), ...
    numel(S.datas) == 2 && isequal([S.datas.vowel], [3 8]) && S.datas(2).PTG == 1100 ...
    && isempty(S.datas(1).control) && endsWith(S.datas(2).control, 'vibrato_ptg.txt'));
check('"save settings" calculates nothing (no result file new or changed)', ...
    isequal({mid.name}, {after.name}) && isequal([mid.datenum], [after.datenum]) && numel(before) >= 1);
vox('setcontrol', '');
vox('combicalc');
S = load(pfile);
check('a Combicalc afterwards adds no profile', numel(S.datas) == 2);

% start: every profile, every result kept
parametermode('start');
r1 = load(voxoutdir('para_paratest_001.mat'));
r2 = load(voxoutdir('para_paratest_002.mat'));
check('start: out/para_paratest_001.mat and _002.mat with the profiles', ...
    r1.data.profile.vowel == 3 && r2.data.profile.vowel == 8 && r2.data.profile.PTG == 1100);
check('profile 1: bit-identical to the Combicalc of its settings', isequal(r1.data.y, yref1));
check('profile 2 (vowel, pressure, control file): bit-identical to its Combicalc', isequal(r2.data.y, yref2));

% a profile of an older version
old = S.datas(1);
old.Infold = rmfield(old.Infold, 'vflength');
old = rmfield(old, 'control');
datas = old;
save(voxoutdir('paraold.mat'), 'datas');
try
    parametermode('run', voxoutdir('paraold.mat'));
    r = load(voxoutdir('para_paraold_001.mat'));
    check('old profile (no vflength, no control): runs, bit-identical to profile 1', isequal(r.data.y, yref1));
catch err
    check(['old profile: ' err.message], false);
end

% refresh: VOX set to profile 2
setappdata(0, 'voxtest_get', {'paratest.mat', voxoutdir});
parametermode('load');
set(findobj('Tag', 'pop_profilenum'), 'Value', 2);
parametermode('refresh');
check('refresh: vowel, control file and pressure of profile 2', get(Hndl.VOWEL, 'Value') == 8 && ...
    endsWith(voxcontrolfile(), 'vibrato_ptg.txt') && Infold.ptg == 1100 && get(Hndl.ptg, 'Value') == 1100);

% load with a control file
setappdata(0, 'voxtest_get', {'adduction.txt', ex});
parametermode('load');
check('load with a .txt: control file chosen', endsWith(voxcontrolfile(), 'adduction.txt'));

parametermode('close');
vox('closevox');
rmpath(stub); rmpath(fullfile(here, 'stubs'));
rmdir(stub, 's');
if nfail == 0
    fprintf('RESULT PASS parameter mode: save only stores, start calculates every profile bit-identical to its settings (also with a control file), old profiles run, refresh and load work\n');
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

function s = ctrlname(f)
[~, n] = fileparts(f);
s = n;
end

function writetext(file, txt)
fid = fopen(file, 'w');
fwrite(fid, txt);
fclose(fid);
end
