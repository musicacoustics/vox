function [flag, fig] = voxfigflag(str, silent)
%VOXFIGFLAG True if a figure with the given name is open.
%   [FLAG, FIG] = VOXFIGFLAG(STR, SILENT) replaces the obsolete MATLAB
%   function figflag. FLAG is true if a figure whose Name is STR exists,
%   FIG contains the handles of these figures. If SILENT is 0 (default),
%   the figures are brought to the front.
%
%   Unlike figflag, VOXFIGFLAG also finds figures with HandleVisibility
%   'callback' or 'off' (e.g. GUIDE windows such as external_forces_gui),
%   so the result no longer depends on whether it is called from a
%   callback.
%
%   See also findall, figure.

if nargin < 2
    silent = 0;
end

fig  = findall(groot, 'Type', 'figure', 'Name', str)';
flag = ~isempty(fig);
if flag && ~silent
    for f = fig
        figure(f);
    end
end
end
