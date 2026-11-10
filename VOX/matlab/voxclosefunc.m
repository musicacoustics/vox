function voxclosefunc(src, ~)
%VOXCLOSEFUNC Close all VOX windows.
%   VOXCLOSEFUNC closes the main VOX window and all VOX sub-windows
%   (editors, plots, progress bars). vox calls it at start-up, because
%   windows left over from an earlier VOX session cannot work with the new
%   session: VOX recognises its windows by name and then uses handles
%   that only exist for windows it opened itself (e.g. "Unrecognized
%   field name 'TractMod'").
%
%   VOXCLOSEFUNC(SRC, EVENT) is the CloseRequestFcn of the main window,
%   so closing VOX no longer leaves its sub-windows behind.
%
%   Uses delete instead of close, so the CloseRequestFcn is not called
%   again.

%    display('hallo');
%   close all;

names = {'Vox - a physical model of the human voice', ...
    'Design of VT area function', 'Design of VT area Function', ...
    'Vocal fold parameters', 'controlfile', 'external_forces_gui', ...
    'Parametermode', 'Vox Progress...', 'Deflection of masses', 'Waterfall', ...
    'Wave propagation in the vocal tract', 'Sound pressure during calculation', ...
    'Sound pressure in the vocal tract', 'Phonovibrogramm', 'Vortex generation'};
figs = findall(groot, 'Type', 'figure');
for k = 1:numel(figs)
    if isgraphics(figs(k)) && any(strcmp(figs(k).Name, names))
        delete(figs(k));
    end
end
if nargin >= 1 && isgraphics(src)
    delete(src);
end
end
