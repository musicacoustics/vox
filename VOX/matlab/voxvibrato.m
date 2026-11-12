function file = voxvibrato(file, name, depth, rate, duration, dt)
%VOXVIBRATO Write a control file for a vibrato.
%   VOXVIBRATO(FILE, NAME, DEPTH, RATE, DURATION) writes the control file
%   FILE with a sinusoidal variation of NAME:
%     'ptg'    subglottal pressure    (column ptg_factor)
%     'tvakt'  vocal fold tension     (column tvakt_factor)
%     'mouth'  mouth opening          (column mouth)
%   as a factor 1 + DEPTH*sin(2*pi*RATE*t) of the value at the start of the
%   calculation; DEPTH relative (e.g. 0.1 for +-10 %), RATE in Hz (e.g.
%   5.5), DURATION in s. NAME may be a cell array to vary several
%   quantities in phase, DEPTH then a vector of the same length.
%   VOXVIBRATO(..., DT) sets the time step of the rows (default 1 ms).
%   FILE without a folder goes into out/. The full name is returned.
%
%   Use it in VOX with the checkbox Control and the list below it, with
%   vox('setcontrol', FILE), or in a profile of the parameter mode.
%   Other programs can write the same format (examples/control/README.md).
%
%   Example: voxvibrato('vibrato_ptg.txt', 'ptg', 0.1, 5.5, 1)
%
%   See also voxcontrolread, vox, parametermode.

if nargin < 6
    dt = 1e-3;
end
name  = cellstr(name);
depth = depth(:)'.*ones(1, numel(name));
col = cell(size(name));
for k = 1:numel(name)
    switch name{k}
        case {'ptg', 'tvakt'}
            col{k} = [name{k} '_factor'];
        case 'mouth'
            col{k} = 'mouth';
        otherwise
            error('vox:vibrato', 'Unknown quantity "%s" (ptg, tvakt or mouth).', name{k});
    end
end
if isempty(fileparts(file))
    file = voxoutdir(file);
end
t = (0:dt:duration)';
V = 1 + depth.*sin(2*pi*rate*t);
fid = fopen(file, 'w');
if fid < 0
    error('vox:vibrato', 'Could not write "%s".', file);
end
c = onCleanup(@() fclose(fid));
fprintf(fid, '%% VOX control file: vibrato %s, depth %s, rate %g Hz, %g s (voxvibrato)\n', ...
    strjoin(name, ', '), mat2str(depth), rate, duration);
fprintf(fid, '%% factors of the values at the start of the calculation\n');
fprintf(fid, '%s\n', strjoin([{'time'}, col], ' '));
fprintf(fid, [repmat('%.6g ', 1, numel(col)) '%.6g\n'], [t, V]');
end
