function [moved, kept] = voxmoveoutput(folder)
%VOXMOVEOUTPUT Move files that VOX wrote next to vox.m into out/.
%   [MOVED, KEPT] = VOXMOVEOUTPUT(FOLDER) moves the files that VOX before
%   #29 wrote into its own folder FOLDER (results, session files, WAV
%   exports, movies, CSV files) into out/ (voxoutdir), where VOX now
%   writes and reads them. vox('initialize') calls it at every start; it
%   only finds files once, or after an older version of VOX has run.
%
%   A file that out/ already contains with the same content is removed
%   from FOLDER. A file whose name exists in out/ with a different content
%   stays where it is and is reported (KEPT): nothing is overwritten.
%   MOVED and KEPT are the names of the files (cell arrays).
%
%   Only names that VOX writes are moved; the program files (.m, the three
%   .fig windows, the .txt input files) do not match them.
%
%   See also voxoutdir, vox.

patterns = {'out*.mat', 'out_vf_n00000', 'last_filename.mat', 'recorded.mat', ...
    'background.mat', 'para*.mat', '*.wav', '*.avi', 'foldmov_*.fig', ...
    'combimov_*.fig', 'externalforce_glottalarea_*.csv'};
names = {};
for k = 1:numel(patterns)
    f = dir(fullfile(folder, patterns{k}));
    names = [names, {f(~[f.isdir]).name}]; %#ok<AGROW>
end
names = unique(names);
moved = {};
kept  = {};
if isempty(names)
    return
end
outdir = voxoutdir;
for k = 1:numel(names)
    src = fullfile(folder, names{k});
    dst = fullfile(outdir, names{k});
    if isfile(dst)
        if samecontent(src, dst)
            delete(src);   % a copy of the file in out/
            moved{end+1} = names{k}; %#ok<AGROW>
        else
            kept{end+1} = names{k}; %#ok<AGROW>
        end
        continue
    end
    [ok, msg] = movefile(src, dst);
    if ok
        moved{end+1} = names{k}; %#ok<AGROW>
    else
        warning('vox:moveoutput', 'Could not move "%s" into out/: %s', names{k}, msg);
        kept{end+1} = names{k}; %#ok<AGROW>
    end
end
if ~isempty(moved)
    fprintf('VOX: moved %d file(s) from %s into out/: %s\n', numel(moved), folder, strjoin(moved, ', '));
end
if ~isempty(kept)
    warning('vox:moveoutput', ['These files stay in %s, because out/ contains ' ...
        'a different file of the same name; VOX uses the one in out/: %s'], ...
        folder, strjoin(kept, ', '));
end
end

function same = samecontent(a, b)
% byte-wise comparison of two files
same = false;
fa = fopen(a, 'r');
if fa < 0
    return
end
ca = onCleanup(@() fclose(fa));
fb = fopen(b, 'r');
if fb < 0
    return
end
cb = onCleanup(@() fclose(fb));
same = isequal(fread(fa, Inf, '*uint8'), fread(fb, Inf, '*uint8'));
end
