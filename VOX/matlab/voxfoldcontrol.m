function tc = voxfoldcontrol(action, tc, n)
%VOXFOLDCONTROL Pressure and tension over time in a fold calculation.
%   TC = VOXFOLDCONTROL('init', NSAMPLES) prepares, for Fold Calc
%   (vox('foldcalc')), the variation of the subglottal pressure and the
%   vocal fold tension (active stress) over the NSAMPLES time steps:
%   - batch mode (checkbox Batch, window "controlfile"): periodic or
%     linear modulation of the active stress and/or the subglottal pressure,
%     computed by controlfile('call') as for Combicalc; the modulation of
%     the vocal tract needs Combi and is ignored (message);
%   - control file (checkbox Control, voxcontrolfile): columns ptg, tvakt,
%     their factors and the positions of the vocal folds; mouth needs
%     Combi and is ignored (warning).
%   TC is [] when neither is switched on; Fold Calc is then unchanged.
%   TC = VOXFOLDCONTROL('apply', TC, N) sets the values of time step N
%   (siggi calls it in its loop before params) and records the pressure
%   and the tension of every step (TC.trace, [ptg tvakt]).
%   VOXFOLDCONTROL('restore', TC) sets pressure, tension and positions back
%   to their values before the calculation (also in the main window), so
%   that the next calculation starts from them; the batch mode left the
%   last modulated values before (#74).
%
%   Combi: combicalc does the same with all three quantities (pressure,
%   tension, vocal tract / mouth opening).
%
%   See also controlfile, voxcontrolapply, siggi, combicalc.

global Hndl Infold BATCH Fs %#ok<GVMIS> VOX keeps its settings in globals

switch action
    case 'init'
        nsamples = tc;
        ctrlfile = voxcontrolfile();
        tc = [];
        if ~BATCH && isempty(ctrlfile)
            return
        end
        tc = struct('batch', logical(BATCH), 'c1', '', 'c2', '', 'timevector', [], ...
            'timeindex', 1, 'ctrl', [], 'file', ctrlfile, ...
            'base', struct('ptg', Infold.ptg, 'tvakt', Infold.tvakt), 'trace', zeros(nsamples, 2));
        if BATCH
            data = get(Hndl.figureNumber, 'UserData');
            if data.batch.trac == 1
                disp('Fold Calc: the batch modulation of the vocal tract needs Combi; it is ignored.');
            end
            modvar.actstr = Infold.tvakt;
            modvar.subpre = Infold.ptg;
            modvar.radius = data.radius;
            [tc.c1, tc.c2, ~, tc.timevector] = controlfile('call', nsamples, '', Fs, modvar);
        end
        if ~isempty(ctrlfile)
            disp(['Fold Calc: control file ' ctrlfile]);
            tc.ctrl = voxcontrolapply('init', ctrlfile, (0:nsamples-1)/Fs, 'fold');
        end

    case 'apply'
        if tc.batch && tc.timeindex <= numel(tc.timevector) && n/Fs*1000 >= tc.timevector(tc.timeindex)
            % the control strings of controlfile, e.g.
            % Infold.ptg=1029;vox('refreshptg','strsli');  (as combicalc)
            eval(tc.c1(tc.timeindex, :));
            eval(tc.c2(tc.timeindex, :));
            tc.timeindex = tc.timeindex + 1;
        end
        if ~isempty(tc.ctrl)   % after the batch mode: the control file wins
            voxcontrolapply('apply', tc.ctrl, n);
        end
        tc.trace(n, :) = [Infold.ptg, Infold.tvakt];

    case 'restore'
        if ~isempty(tc.ctrl)
            voxcontrolapply('restore', tc.ctrl);
        end
        Infold.ptg   = tc.base.ptg;
        Infold.tvakt = tc.base.tvakt;
        vox('refreshptg', 'strsli');
        vox('refreshtvakt', 'strsli');
end
end
