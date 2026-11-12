function ctrl = voxcontrolread(file)
%VOXCONTROLREAD Read a control file (time series of VOX parameters).
%   CTRL = VOXCONTROLREAD(FILE) reads a control file and returns a struct
%   with the fields
%     file    name of the file
%     format  'columns' (file with a header line) or 'FE' (old FE file)
%     t       time [s], column vector, increasing
%     names   names of the controlled quantities (cell array)
%     values  matrix, one column per name, one row per time; NaN keeps the
%             value that VOX has at the start of the calculation
%
%   Control files let external programs or parameter files control the
%   suspension of the voice apparatus (positions of the ends of the vocal
%   folds) and the vocal folds during a combi calculation, e.g. a vibrato
%   by varying the subglottal pressure, the vocal fold tension or the
%   mouth opening (#74). Format and examples: examples/control/README.md.
%
%   Text file; lines starting with % or # are comments. The first other
%   line names the columns, separated by spaces, tabs, commas or
%   semicolons; the first column is the time in seconds:
%     time      time [s]
%     ptg       subglottal pressure [Pa]
%     tvakt     active stress of the vocal folds (vocal fold tension), unit
%               of the GUI field for the active stress
%     ptg_factor, tvakt_factor   the same as a factor of the value at the
%               start of the calculation
%     mouth     mouth opening: factor of the radii of the last 1 cm of the
%               vocal tract (stairs model)
%     w0, wmax  distance of both vocal folds from the midline at the
%               posterior (w0) and the anterior (wmax) end [um]
%     w0lp_x, w0lp_y, w0lp_z, w0rp_*, wmaxla_*, wmaxra_*
%               coordinates of the ends of the left (l) and right (r) vocal
%               fold, posterior (p) and anterior (a) [um]
%   An old FE file (FE*.txt) has no header line and 14 columns: time [s],
%   wmaxla, w0lp, wmaxra, w0rp (x, y, z each, in mm) and the active stress
%   (used where > 0). This is the order in which combicalc read these files
%   before #74; the positions are converted to um.
%
%   See also voxcontrolapply, voxvibrato, vox.

ax = {'x', 'y', 'z'};
ends = {'w0lp', 'w0rp', 'wmaxla', 'wmaxra'};
known = {'ptg', 'tvakt', 'ptg_factor', 'tvakt_factor', 'mouth', 'w0', 'wmax'};
for e = ends
    for a = ax
        known{end+1} = [e{1} '_' a{1}]; %#ok<AGROW>
    end
end

if ~isfile(file)
    error('vox:control', 'Control file "%s" not found.', file);
end
lines = strtrim(splitlines(fileread(file)));
lines = lines(~cellfun(@isempty, lines) & ~startsWith(lines, {'%', '#'}));
if isempty(lines)
    error('vox:control', 'Control file "%s" contains no data.', file);
end

ctrl = struct('file', file, 'format', '', 't', [], 'names', {{}}, 'values', []);
head = tokens(lines{1});
if all(isnan(str2double(head)))   % header line with names
    ctrl.format = 'columns';
    names = lower(head);
    if ~any(strcmp(names{1}, {'time', 't', 'time_s'}))
        error('vox:control', 'Control file "%s": the first column must be the time in seconds ("time").', file);
    end
    names = names(2:end);
    bad = setdiff(names, known);
    if ~isempty(bad)
        error('vox:control', 'Control file "%s": unknown column(s) %s. Known: time, %s.', ...
            file, strjoin(bad, ', '), strjoin(known, ', '));
    end
    if numel(unique(names)) < numel(names)
        error('vox:control', 'Control file "%s": a column name occurs twice.', file);
    end
    M = readrows(lines(2:end), numel(names) + 1, file);
    ctrl.t      = M(:, 1);
    ctrl.names  = names;
    ctrl.values = M(:, 2:end);
else                              % old FE file: 14 columns, no names
    ctrl.format = 'FE';
    M = readrows(lines, 14, file);
    ctrl.t = M(:, 1);
    order = {'wmaxla', 'w0lp', 'wmaxra', 'w0rp'};   % columns 2-4, 5-7, 8-10, 11-13
    for e = order
        for a = ax
            ctrl.names{end+1} = [e{1} '_' a{1}];
        end
    end
    ctrl.values = 1000*M(:, 2:13);   % mm -> um
    if any(M(:, 14) > 0)             % active stress where it is given
        tv = M(:, 14);
        tv(tv <= 0) = NaN;
        ctrl.names{end+1} = 'tvakt';
        ctrl.values = [ctrl.values, tv];
    end
end
if any(diff(ctrl.t) <= 0)
    error('vox:control', 'Control file "%s": the times must increase from row to row.', file);
end
end

function c = tokens(line)
% fields of a line, separated by spaces, tabs, commas or semicolons
c = regexp(line, '[\s,;]+', 'split');
c = c(~cellfun(@isempty, c));
end

function M = readrows(lines, ncol, file)
% numbers of the data lines, ncol per line
M = zeros(numel(lines), ncol);
for k = 1:numel(lines)
    v = str2double(tokens(lines{k}));
    if numel(v) ~= ncol || any(isnan(v) & ~strcmpi(tokens(lines{k}), 'nan'))
        error('vox:control', 'Control file "%s": data line %d ("%s") does not contain %d numbers.', ...
            file, k, lines{k}, ncol);
    end
    M(k, :) = v;
end
end
