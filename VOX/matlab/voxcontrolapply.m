function S = voxcontrolapply(action, S, ii, mode)
%VOXCONTROLAPPLY Apply a control file during a calculation.
%   S = VOXCONTROLAPPLY('init', FILE, T) reads the control file FILE
%   (voxcontrolread), interpolates its columns linearly at the times T [s]
%   of the samples (before the first and after the last row the first and
%   the last value hold) and remembers the values that VOX has now: the
%   subglottal pressure, the active stress and the positions of the vocal
%   folds in Infold, and the area function of the vocal tract.
%   VOXCONTROLAPPLY('apply', S, II) sets these quantities to their values
%   of sample II; the vocal fold model (params) and the vocal tract
%   (tractsig) read them in every time step.
%   VOXCONTROLAPPLY('restore', S) sets them back to the remembered values,
%   so that a later calculation without control file is not changed.
%
%   The result S of 'init' also contains the values used per sample
%   (S.names, S.values, absolute values, one row per sample), which
%   combicalc stores with the result (data.control).
%
%   The mouth opening scales the radii of the last 1 cm of the vocal tract;
%   only the stairs model reads the area function in every time step, so
%   the column mouth is ignored with tubes (with a warning).
%   S = VOXCONTROLAPPLY('init', FILE, T, 'fold') is the same for a fold
%   calculation (Fold Calc, voxfoldcontrol): there is no vocal tract, the
%   column mouth is ignored (with a warning).
%
%   See also voxcontrolread, combicalc, voxfoldcontrol.

global Infold Hndl %#ok<GVMIS> the vocal fold model and the GUI data

switch action
    case 'init'
        file = S;
        t    = ii;
        ctrl = voxcontrolread(file);
        tt = min(max(t(:), ctrl.t(1)), ctrl.t(end));
        if isscalar(ctrl.t)
            V = repmat(ctrl.values, numel(tt), 1);
        else
            V = interp1(ctrl.t, ctrl.values, tt, 'linear');
        end
        data = get(Hndl.figureNumber, 'UserData');
        S = struct('file', file, 'format', ctrl.format, 'names', {{}}, 'values', [], ...
            'field', {{}}, 'index', [], 'base', struct(), 'radius', data.radius, 'mouthidx', []);
        for f = {'ptg', 'tvakt', 'w0lp', 'w0rp', 'wmaxla', 'wmaxra'}
            S.base.(f{1}) = Infold.(f{1});
        end
        for k = 1:numel(ctrl.names)
            name = ctrl.names{k};
            v = V(:, k);
            switch name
                case {'ptg', 'tvakt'}
                    add(name, name, 1, v);
                case {'ptg_factor', 'tvakt_factor'}
                    f = name(1:end-7);
                    add(f, f, 1, S.base.(f)*v);
                case 'w0'
                    add('w0lp_x', 'w0lp', 1, v);
                    add('w0rp_x', 'w0rp', 1, v);
                case 'wmax'
                    add('wmaxla_x', 'wmaxla', 1, v);
                    add('wmaxra_x', 'wmaxra', 1, v);
                case 'mouth'
                    if nargin >= 4 && strcmp(mode, 'fold')
                        warning('vox:control', ['Control file %s: the mouth opening needs the ' ...
                            'vocal tract (Combi); it is ignored in Fold Calc.'], file);
                        continue
                    end
                    if get(Hndl.TractCalcMode, 'value') ~= 1
                        warning('vox:control', ['Control file %s: the mouth opening needs the ' ...
                            'stairs model; it is ignored.'], file);
                        continue
                    end
                    nseg = max(1, round(0.01/data.spacing));   % last 1 cm
                    S.mouthidx = numel(data.radius) - nseg + 1 : numel(data.radius);
                    add('mouth', 'mouth', 1, v);
                otherwise   % w0lp_x ... wmaxra_z
                    parts = split(name, '_');
                    add(name, parts{1}, find(strcmp(parts{2}, {'x', 'y', 'z'})), v);
            end
        end
        % NaN in the file: keep the value at the start of the calculation
        for k = 1:numel(S.field)
            col = S.values(:, k);
            if any(isnan(col))
                if strcmp(S.field{k}, 'mouth')
                    col(isnan(col)) = 1;
                else
                    b = S.base.(S.field{k});
                    col(isnan(col)) = b(S.index(k));
                end
                S.values(:, k) = col;
            end
        end

    case 'apply'
        for k = 1:numel(S.field)
            v = S.values(ii, k);
            if strcmp(S.field{k}, 'mouth')
                data = get(Hndl.figureNumber, 'UserData');
                data.radius(S.mouthidx) = S.radius(S.mouthidx)*v;
                set(Hndl.figureNumber, 'UserData', data);
            else
                Infold.(S.field{k})(S.index(k)) = v;
            end
        end

    case 'restore'   % only the controlled quantities (the batch mode keeps its own)
        for f = reshape(unique(S.field(~strcmp(S.field, 'mouth'))), 1, [])   % a row (0x1 runs once)
            Infold.(f{1}) = S.base.(f{1});
        end
        if ~isempty(S.mouthidx)
            data = get(Hndl.figureNumber, 'UserData');
            data.radius = S.radius;
            set(Hndl.figureNumber, 'UserData', data);
        end
end

    function add(name, field, index, v)
        % one controlled quantity: name, field of Infold (or 'mouth'),
        % element of the field, values per sample
        S.names{end+1} = name;
        S.field{end+1} = field;
        S.index(end+1) = index;
        S.values(:, end+1) = v;
    end
end
