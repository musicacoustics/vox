function voxtest_guisweep(voxdir, outfile)
%VOXTEST_GUISWEEP  Run the callback of every control of the VOX main window
%   voxtest_guisweep(voxdir, outfile) starts VOX in voxdir (a copy of
%   VOX/matlab) and calls the callback of every control of the main window:
%   popups with every entry (back to the start value at the end), radio
%   buttons and checkboxes on and off, push buttons once, sliders and edit
%   fields with their current value. The duration is set to 10 ms after
%   every callback, so the calculations stay short.
%   File dialogs and message boxes are replaced by the stubs in
%   tests/stubs (cancel), so nothing waits for input.
%   Not run: play and record (audio devices), quit/closevox (at the end).
%   outfile gets struct S: nrun, errors (cellstr "callback: message",
%   without line numbers, for the comparison with a baseline).
%   Run it hidden (see runvoxtests): VOX opens its windows.

global TMAX Hndl %#ok<GVMIS> VOX is driven through its globals
fprintf('MATLAB %s, GUI sweep in %s\n', version, voxdir);
here = fileparts(mfilename('fullpath'));
warning('off', 'MATLAB:dispatcher:nameConflict');
addpath(fullfile(here, 'stubs'));
cd(voxdir);
S = struct('nrun', 0, 'errors', {{}});
nwarn = 0;
try
    vox;
catch err
    S.errors = {['initialize: ' err.message]};
    save(outfile, 'S');
    fprintf('RESULT FAIL initialize: %s\n', err.message);
    exit(1);
end
setdur(10);
skip  = {'play', 'record', 'quit', 'closevox'};
ctrls = findall(Hndl.figureNumber, 'Type', 'uicontrol');
ctrls = flipud(ctrls(:));                          % creation order
style = get(ctrls, 'Style');
order = [find(~strcmp(style, 'pushbutton')); find(strcmp(style, 'pushbutton'))];
for k = order(:)'
    h = ctrls(k);
    if ~ishghandle(h), continue, end
    cb = get(h, 'Callback');
    if ~ischar(cb) || ~startsWith(strtrim(cb), 'vox(')
        continue
    end
    if any(cellfun(@(s) contains(cb, ['''' s '''']), skip)), continue, end
    st = get(h, 'Style');
    switch st
        case 'popupmenu'
            str = get(h, 'String');
            if iscell(str), n = numel(str); else, n = size(str, 1); end
            v0 = get(h, 'Value');
            vals = [setdiff(1:n, v0), v0];
        case {'radiobutton', 'checkbox', 'togglebutton'}
            v0 = get(h, 'Value');
            vals = [1-v0, v0];
        otherwise
            vals = get(h, 'Value');
    end
    for v = vals
        if ~ishghandle(h), break, end
        if ~any(strcmp(st, {'pushbutton', 'edit'})), set(h, 'Value', v); end
        lastwarn('');
        S.nrun = S.nrun + 1;
        t0 = tic;
        try
            evalin('base', cb);
            drawnow;
            [w, wid] = lastwarn;
            if ~isempty(w) && ~strcmp(wid, 'MATLAB:dispatcher:nameConflict')
                nwarn = nwarn + 1;
                fprintf('WARN  %-40s value %g: [%s] %s\n', cb, v, wid, w);
            end
        catch err
            S.errors{end+1} = sprintf('%s: %s', cb, err.message);
            fprintf('ERROR %-40s value %g: %s (%s line %d)\n', cb, v, err.message, ...
                err.stack(1).name, err.stack(1).line);
        end
        if toc(t0) > 20
            fprintf('      %-40s value %g took %.0f s\n', cb, v, toc(t0));
        end
        setdur(10);
    end
end
try
    vox('closevox');
catch err
    S.errors{end+1} = ['closevox: ' err.message];
end
S.errors = unique(S.errors);
save(outfile, 'S');
fprintf('RESULT PASS %d callbacks, %d errors, %d warnings\n', S.nrun, numel(S.errors), nwarn);

    function setdur(ms)
        if ~ishghandle(Hndl.DurationStr), return, end
        TMAX = ms;
        set(Hndl.DurationStr, 'string', num2str(ms));
        vox('refreshDuration', 'strsli');
    end
end
