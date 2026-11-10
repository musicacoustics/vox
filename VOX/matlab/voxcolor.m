function varargout = voxcolor(target, option)
%VOXCOLOR Keep VOX graphics readable in light and dark figure themes.
%   Since R2025a, figures follow the light or dark theme of the MATLAB
%   desktop. Colours that MATLAB chooses itself (figure, axes, texts, UI
%   controls, default line colours) follow the theme, explicit colours do
%   not: black lines such as FGSTYLE ('k-') are invisible on a dark
%   background. In releases without graphics themes (R2024b and earlier)
%   VOXCOLOR changes nothing and returns the light-theme colours.
%
%   VOXCOLOR(H) gives every black line in the graphics objects H and their
%   children (H can be figures, axes or lines) the neutral foreground
%   colour of the theme (SeriesIndex "none"): almost black in a light
%   theme, light grey in a dark theme. MATLAB updates this colour itself
%   when the theme changes; line style and markers stay as they are. Call
%   it after plotting black lines.
%
%   VOXCOLOR(FIG, 'light') keeps the figure FIG in the light theme. Use it
%   for windows loaded from GUIDE .fig files, which store light colours.
%
%   [C, ISDARK] = VOXCOLOR('fg') returns the foreground colour for the
%   theme of the current figure: black [0 0 0] in a light theme and in
%   releases without themes, white [1 1 1] in a dark theme. ISDARK is true
%   for a dark theme. [C, ISDARK] = VOXCOLOR('fg', H) uses the figure that
%   contains the graphics object H. Use it for colours that depend on the
%   background and therefore cannot be left to MATLAB.
%
%   Examples
%      plot(t, y, fgstyle); voxcolor(gca)
%      [~, isdark] = voxcolor('fg', ax);
%
%   See also THEME.

if ischar(target) || isstring(target)   % colour query
    if nargin < 2
        option = get(groot, 'CurrentFigure');
    end
    isdark = isdarktheme(option);
    switch lower(char(target))
        case 'fg'
            if isdark
                c = [1 1 1];
            else
                c = [0 0 0];
            end
        otherwise
            error('voxcolor:unknownName', 'Unknown VOX colour name ''%s''.', char(target));
    end
    varargout = {c, isdark};
    return
end

h = target(isgraphics(target));
if isempty(h) || isempty(themedfigure(h(1)))
    return   % no graphics themes: black stays black
end

if nargin > 1
    if ~strcmpi(option, 'light')
        error('voxcolor:unknownOption', 'Unknown option ''%s''.', char(option));
    end
    for k = 1:numel(h)
        fig = themedfigure(h(k));
        if ~isempty(fig) && (~strcmp(fig.ThemeMode, 'manual') ...
                || ~strcmp(fig.Theme.BaseColorStyle, 'light'))
            theme(fig, 'light');
        end
    end
    return
end

% black lines: neutral colour of the theme, which also adapts on a theme
% change; the line style and markers stay as they are
ln = findall(h, 'Type', 'line');
for k = 1:numel(ln)
    if isprop(ln(k), 'ColorMode') && strcmp(ln(k).ColorMode, 'manual') ...
            && isequal(ln(k).Color, [0 0 0])
        set(ln(k), 'SeriesIndex', 'none', 'ColorMode', 'auto');
    end
end
end

function isdark = isdarktheme(h)
% true if the figure that contains H uses a dark theme
isdark = false;
if isempty(h) || ~isgraphics(h(1))
    return
end
fig = themedfigure(h(1));
if ~isempty(fig)
    isdark = strcmp(fig.Theme.BaseColorStyle, 'dark');
end
end

function fig = themedfigure(h)
% figure that contains H if it has a graphics theme, otherwise []
fig = ancestor(h, 'figure');
if isempty(fig) || ~isprop(fig, 'Theme') || isempty(fig.Theme)
    fig = [];
end
end
