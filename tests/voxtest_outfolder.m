function voxtest_outfolder(voxdir)
%VOXTEST_OUTFOLDER  All files that VOX writes go into out/ (#29)
%   voxtest_outfolder(voxdir) works in voxdir (a copy of VOX/matlab):
%   - files that older versions wrote next to vox.m (result, last_filename,
%     recorded, WAV, CSV) are moved into out/ at the start; a file that
%     out/ contains with the same content is removed, one with a different
%     content stays and nothing is overwritten
%   - Fold Calc, Tract Calc, VF*VT, Combicalc, background (toback), WAV
%     export, Fold Load and Tract Load of example files, *.mat input, LastRec,
%     movie dialog, parameter mode: their files are in out/, VOX reads them
%     back from there (no "not present"), the dialogs start in out/
%   - afterwards no file outside out/ is new or changed (examples/ included)
%   Dialogs are replaced by stubs (file names from this test, otherwise
%   cancel), sound by a stub. Run it hidden (see runvoxtests).

global GRONF Hndl %#ok<GVMIS> VOX is driven through its globals
fprintf('MATLAB %s, output folder in %s\n', version, voxdir);
cd(voxdir);
nfail = 0;
outdir = fullfile(voxdir, 'out');
exdir  = fullfile(voxdir, 'examples');
here   = fileparts(mfilename('fullpath'));
if isfolder(outdir)
    rmdir(outdir, 's');   % the copy may contain results of the working tree
end

% files of an older VOX next to vox.m
copyfile(fullfile(exdir, 'out_st_a.mat'), voxdir);
data = struct('y', sin(2*pi*200*(0:999)/22050), 't', (0:999)/22050, 'Fs', 22050, ...
    'filename', 'recorded');   % fields as vox('record') saves them
save(fullfile(voxdir, 'recorded.mat'), 'data');
data = struct('y', cos(2*pi*300*(0:999)/22050), 'Fs', 22050, 'filename', 'planted');
save(fullfile(voxdir, 'last_filename.mat'), 'data');
writebytes(fullfile(voxdir, 'a.wav.wav'), 'RIFF test');
writebytes(fullfile(voxdir, 'externalforce_glottalarea_1mN_10percent.csv'), '1,2,3');
mkdir(outdir);
writebytes(fullfile(voxdir, 'out_vf_n00000.mat'), 'same');      % identical copy in out/
writebytes(fullfile(outdir, 'out_vf_n00000.mat'), 'same');
writebytes(fullfile(voxdir, 'background.mat'), 'old VOX');      % different file in out/
writebytes(fullfile(outdir, 'background.mat'), 'out version');
writebytes(fullfile(outdir, 'marker.txt'), 'out');              % to recognise out/ in dialog paths

% dialogs: uigetfile returns what the test sets, uiputfile cancels; both
% record their first argument (where the dialog starts)
stub = fullfile(tempdir, ['voxtest_outfolder_' char(datetime('now', 'Format', 'HHmmssSSS'))]);
mkdir(stub);
writebytes(fullfile(stub, 'uigetfile.m'), sprintf(['function [f, p, i] = uigetfile(varargin)\n' ...
    'setappdata(0, ''voxtest_filter'', varargin{1});\n' ...
    'r = getappdata(0, ''voxtest_uigetfile'');\n' ...
    'if isempty(r), f = 0; p = 0; i = 0; else, f = r{1}; p = [r{2} filesep]; i = 1; end\n']));
writebytes(fullfile(stub, 'uiputfile.m'), sprintf(['function [f, p, i] = uiputfile(varargin)\n' ...
    'setappdata(0, ''voxtest_filter'', varargin{1});\n' ...
    'f = 0; p = 0; i = 0;\n']));
writebytes(fullfile(stub, 'sound.m'), sprintf('function sound(varargin)\n'));
warning('off', 'MATLAB:dispatcher:nameConflict');
addpath(fullfile(here, 'stubs'));   % questdlg, msgbox, ... cancel
addpath(stub); rehash;

vox;
GRONF = 0;
set(Hndl.gronf, 'value', 0);
check('start: old result moved into out/', isfile(fullfile(outdir, 'out_st_a.mat')) && ~isfile(fullfile(voxdir, 'out_st_a.mat')));
check('start: recorded, last_filename, a.wav.wav, CSV moved into out/', ...
    all(cellfun(@(n) isfile(fullfile(outdir, n)) && ~isfile(fullfile(voxdir, n)), ...
    {'recorded.mat', 'last_filename.mat', 'a.wav.wav', 'externalforce_glottalarea_1mN_10percent.csv'})));
check('start: identical copy of a file in out/ removed from the VOX folder', ~isfile(fullfile(voxdir, 'out_vf_n00000.mat')));
check('start: different file of the same name stays, out/ not overwritten', ...
    isfile(fullfile(voxdir, 'background.mat')) && strcmp(readbytes(fullfile(outdir, 'background.mat')), 'out version'));
delete(fullfile(voxdir, 'background.mat'));   % resolved by the user
before = listfiles(voxdir, '');

% calculations: results in out/, shown again from there
setinput(1); type('30');
vox('foldcalc');
check('Fold Calc: out/out_vf_n10000.mat', isfile(fullfile(outdir, 'out_vf_n10000.mat')));
setinput(2); type('20');
vox('tractcalc');
d = load(fullfile(outdir, 'out_st_a.mat'));
check('Tract Calc: out/out_st_a.mat (the new 20 ms result)', abs(d.data.Tmax - 20) < 1);
check('Tract: result shown from out/', shown('out\_st\_a'));
setinput(3);
check('VF*VT: fold and tract results loaded from out/', shown('out\_f'));
setinput(4); type('30');
vox('combicalc');
check('Combicalc: out/out_cs_a10000.mat', isfile(fullfile(outdir, 'out_cs_a10000.mat')));
setinput(1); setinput(4);
check('Combi: result shown from out/', shown('out\_cs\_a10000'));

% background
set(Hndl.toback, 'value', 1); vox('toback');
check('background: out/background.mat', ~strcmp(readbytes(fullfile(outdir, 'background.mat')), 'out version'));
try
    vox('display');
    check('display with background (plot_tuf loads it from out/)', true);
catch err
    check(['display with background: ' err.message], false);
end
set(Hndl.toback, 'value', 0); vox('toback');

% WAV export: automatic copy into out/, the save dialog starts in out/
setappdata(0, 'voxtest_filter', '');
vox('wav');
check('WAV export: out/out_cs_a10000.wav', isfile(fullfile(outdir, 'out_cs_a10000.wav')));
check('WAV export: save dialog starts in out/', inout());

% movie dialog of Fold Calc (cancelled: no movie)
GRONF = 1; set(Hndl.gronf, 'value', 1); vox('gronf');
set(Hndl.makemovie, 'Value', 1); vox('makemovie');
setappdata(0, 'voxtest_filter', '');
setinput(1); type('5');
try
    vox('foldcalc');
    check('movie: save dialog starts in out/', inout());
catch err
    check(['Fold Calc with movie dialog: ' err.message], false);
end
set(Hndl.makemovie, 'Value', 0); vox('makemovie');
GRONF = 0; set(Hndl.gronf, 'value', 0); vox('gronf');

% Fold Load of an example: dialog in out/, files in out/
setappdata(0, 'voxtest_uigetfile', {'out_vf_n10000.mat', exdir});
setappdata(0, 'voxtest_filter', '');
try
    vox('foldload');
    check('Fold Load: dialog starts in out/', inout());
    check('Fold Load: out/out_vf_n00000.mat written', isfile(fullfile(outdir, 'out_vf_n00000.mat')) && ...
        ~strcmp(readbytes(fullfile(outdir, 'out_vf_n00000.mat')), 'same'));
catch err
    check(['Fold Load: ' err.message], false);
end

% Tract Load of an example that out/ does not contain: copied into out/
setappdata(0, 'voxtest_uigetfile', {'out_ms_a.mat', exdir});
setappdata(0, 'voxtest_filter', '');
try
    vox('tractload');
    check('Tract Load: dialog starts in out/', inout());
    check('Tract Load: out/out_ms_a.mat and out/out_stfi.mat', ...
        isfile(fullfile(outdir, 'out_ms_a.mat')) && isfile(fullfile(outdir, 'out_stfi.mat')));
    % in File mode vox('input') saves the file again as out_fm_<vowel>
    check('Tract Load: file shown, saved again as out/out_fm_a.mat', ...
        shown('out\_fm\_a') && isfile(fullfile(outdir, 'out_fm_a.mat')));
catch err
    check(['Tract Load: ' err.message], false);
end
set(Hndl.TractCalcMode, 'Value', 1); vox('tractcalcmode');

% *.mat input and LastRec
setappdata(0, 'voxtest_uigetfile', {'out_vf_n10000.mat', outdir});
setappdata(0, 'voxtest_filter', '');
setinput(5);
check('*.mat input: dialog starts in out/', inout());
L = load(fullfile(outdir, 'last_filename.mat'));
check('*.mat input: out/last_filename.mat of the chosen file', strcmp(L.data.filename, 'out_vf_n10000'));
setappdata(0, 'voxtest_uigetfile', []);
setinput(9);
check('LastRec: out/recorded.mat (moved at the start) shown', shown('recorded'));

% parameter mode: its parameter file goes into out/
try
    parametermode('initialize');
    h = guihandles(findobj('Name', 'Parametermode'));
    check('parameter mode: file path out/', isfile(fullfile(get(h.ed_filepath, 'String'), 'marker.txt')));
    parametermode('close');
catch err
    check(['parameter mode: ' err.message], false);
end

% nothing outside out/ is new or changed
after = listfiles(voxdir, '');
[added, gone, changed] = compare(before, after);
check(sprintf('no new file outside out/ (new: %s)', strjoin(added, ', ')), isempty(added));
check(sprintf('no file outside out/ removed or changed (%s)', strjoin([gone, changed], ', ')), ...
    isempty(gone) && isempty(changed));

vox('closevox');
rmpath(stub);
rmpath(fullfile(here, 'stubs'));
rmdir(stub, 's');
if nfail == 0
    fprintf('RESULT PASS all files in out/: old files moved at the start (nothing overwritten), calculations, background, WAV, loads, LastRec, dialogs and parameter mode use out/, nothing new outside\n');
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
    function ok = shown(part)
        % title of the main window names the file, not "not present"
        t = get(get(get(Hndl.figureNumber, 'CurrentAxes'), 'title'), 'String');
        t = char(t);
        ok = contains(t, part) && ~contains(t, 'not present');
        if ~ok
            fprintf('    title: %s\n', t);
        end
    end
    function ok = inout()
        % the last dialog started in out/ (it contains marker.txt)
        f = getappdata(0, 'voxtest_filter');
        ok = ischar(f) && ~isempty(f) && isfile(fullfile(fileparts(f), 'marker.txt'));
        if ~ok
            fprintf('    dialog started at: %s\n', char(string(f)));
        end
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

function writebytes(file, txt)
fid = fopen(file, 'w');
fwrite(fid, txt);
fclose(fid);
end

function txt = readbytes(file)
fid = fopen(file, 'r');
txt = char(fread(fid, Inf, '*uint8')');
fclose(fid);
end

function L = listfiles(folder, rel)
% files below folder (without out/ at the top) with size and date
L = struct('name', {}, 'bytes', {}, 'datenum', {});
f = dir(folder);
for k = 1:numel(f)
    n = f(k).name;
    if any(strcmp(n, {'.', '..'})) || (isempty(rel) && strcmp(n, 'out'))
        continue
    end
    r = fullfile(rel, n);
    if f(k).isdir
        L = [L, listfiles(fullfile(folder, n), r)]; %#ok<AGROW>
    else
        L(end+1) = struct('name', r, 'bytes', f(k).bytes, 'datenum', f(k).datenum); %#ok<AGROW>
    end
end
end

function [added, gone, changed] = compare(a, b)
added = setdiff({b.name}, {a.name});
gone  = setdiff({a.name}, {b.name});
changed = {};
for k = 1:numel(a)
    j = find(strcmp({b.name}, a(k).name), 1);
    if ~isempty(j) && (a(k).bytes ~= b(j).bytes || a(k).datenum ~= b(j).datenum)
        changed{end+1} = a(k).name; %#ok<AGROW>
    end
end
end
