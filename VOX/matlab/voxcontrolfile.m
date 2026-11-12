function varargout = voxcontrolfile(action, file)
%VOXCONTROLFILE Control file chosen in the main window of VOX.
%   FILE = VOXCONTROLFILE returns the full name of the control file that
%   the next combi calculation uses: checkbox "Control" on and a file
%   chosen in the list below it. Otherwise FILE is ''.
%
%   VOXCONTROLFILE('select', FILE) switches the control on and chooses
%   FILE (added to the list if necessary); FILE = '' switches it off.
%   VOXCONTROLFILE('list') fills the list with the control files in
%   examples/control/, in out/ and old FE*.txt files in the VOX folder,
%   and the entry "other file..." (open dialog).
%   VOXCONTROLFILE('choose') is the callback of the list.
%   TAG = VOXCONTROLFILE('tag') returns the part of the result name that
%   names the control file ('' without control), e.g. '_vibrato_ptg'.
%
%   The choice is kept in the controls themselves (checkbox Hndl.FE, list
%   Hndl.PARAM; its UserData holds the full names and the chosen one),
%   because the data of the main window are replaced whenever a result is
%   loaded.
%
%   See also voxcontrolread, voxcontrolapply, vox.

global Hndl %#ok<GVMIS>

if nargin < 1
    action = 'get';
end
other = 'other file...';
switch action
    case 'get'
        varargout{1} = current();

    case 'tag'
        f = current();
        if isempty(f)
            varargout{1} = '';
        else
            [~, name] = fileparts(f);
            name = regexprep(name, '[^A-Za-z0-9_]', '_');
            varargout{1} = ['_' name(1:min(end, 30))];
        end

    case 'list'
        vdir  = fileparts(mfilename('fullpath'));
        paths = {};
        for d = {fullfile(vdir, 'examples', 'control', '*.txt'), fullfile(voxoutdir, '*.txt'), ...
                fullfile(vdir, 'FE*.txt')}
            f = dir(d{1});
            f = f(~[f.isdir]);
            paths = [paths, fullfile({f.folder}, {f.name})]; %#ok<AGROW>
        end
        ud = stored();
        if ~isempty(ud.sel) && ~any(strcmp(paths, ud.sel))
            paths{end+1} = ud.sel;
        end
        show(paths, ud.sel);

    case 'select'
        if isempty(file)
            set(Hndl.FE, 'Value', 0);
            set(Hndl.PARAM, 'String', {' '}, 'Value', 1, 'UserData', struct('paths', {{}}, 'sel', ''));
            varargout{1} = '';
            return
        end
        if ~isfile(file)
            error('vox:control', 'Control file "%s" not found.', file);
        end
        f = dir(file);   % full name
        file = fullfile(f.folder, f.name);
        set(Hndl.FE, 'Value', 1);
        voxcontrolfile('list');
        paths = stored().paths;
        if ~any(strcmp(paths, file))
            paths{end+1} = file;
        end
        show(paths, file);
        varargout{1} = file;

    case 'choose'   % callback of the list
        ud = stored();
        k = get(Hndl.PARAM, 'Value');
        if k > numel(ud.paths)   % "other file..."
            [name, folder] = uigetfile({'*.txt', 'control files (*.txt)'; '*.*', 'all files'}, ...
                'choose control file', voxoutdir);
            if ischar(name)
                voxcontrolfile('select', fullfile(folder, name));
            else   % cancelled: back to the previous choice
                show(ud.paths, ud.sel);
            end
        else
            show(ud.paths, ud.paths{k});
        end
        varargout{1} = current();
end

    function out = current()
        % chosen file, '' without control
        out = '';
        if isempty(Hndl) || ~isfield(Hndl, 'FE') || ~ishghandle(Hndl.FE) || get(Hndl.FE, 'Value') ~= 1
            return
        end
        ud = stored();
        kk = get(Hndl.PARAM, 'Value');
        if kk >= 1 && kk <= numel(ud.paths)
            out = ud.paths{kk};
        end
    end

    function ud = stored()
        % full names and chosen file, kept in the UserData of the list
        ud = get(Hndl.PARAM, 'UserData');
        if ~isstruct(ud) || ~isfield(ud, 'paths')
            ud = struct('paths', {{}}, 'sel', '');
        end
    end

    function show(paths, sel)
        % list entries (file names) and full names; select sel if present
        lab = cell(size(paths));
        for j = 1:numel(paths)
            [~, n, e] = fileparts(paths{j});
            lab{j} = [n e];
        end
        idx = find(strcmp(paths, sel), 1);
        if isempty(idx)
            idx = 1;
        end
        if isempty(paths)
            s = '';
        else
            s = paths{idx};
        end
        set(Hndl.PARAM, 'String', [lab, {other}], 'Value', idx, ...
            'UserData', struct('paths', {paths}, 'sel', s));
    end
end
