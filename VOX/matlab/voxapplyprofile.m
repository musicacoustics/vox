function voxapplyprofile(p)
%VOXAPPLYPROFILE Set VOX to a profile of the parameter mode.
%   VOXAPPLYPROFILE(P) sets the settings of VOX and the controls of the
%   main window to the profile P (one element of the struct array datas
%   in a parameter file, see voxprofile): switches, duration, sampling
%   rate, register, vowel, tract model, control file, the data of the main
%   window (area function, batch modulation) and the vocal fold parameters
%   (Infold), with the subglottal pressure P.PTG and the active stress
%   P.TVAKT. The next vox('combicalc') calculates the profile.
%
%   Fields that older profiles do not have keep their current values (e.g.
%   Infold.vflength of the fold editor of 2023, control). It replaces
%   parameterfile_var.m, which vox('initialize') called through eval after
%   resetting all settings, and which applied a profile only in part (#74).
%
%   See also voxprofile, parametermode, voxcontrolfile.

global Hndl Infold MODFOLD BATCH TRACH FOLD TRACT NOISE TMAX Fs ...
    MAXSEGMENTS MAXDEVLIMIT XI Xi0 MAXM GRON %#ok<GVMIS> VOX keeps its settings in globals

% switches and values
BATCH = p.BATCH;  TRACH = p.TRACH;  FOLD = p.FOLD;  TRACT = p.TRACT;  NOISE = p.NOISE;
TMAX  = p.TMAX;   Fs    = p.Fs;     MAXM = p.MAXM;  GRON  = p.GRON;   MODFOLD = p.MODFOLD;
MAXSEGMENTS = p.MAXSEGMENTS;  MAXDEVLIMIT = p.MAXDEVLIMIT;  XI = p.XI;  Xi0 = p.Xi0;
set(Hndl.trach, 'Value', TRACH);
set(Hndl.fold,  'Value', FOLD);
set(Hndl.tract, 'Value', TRACT);
set(Hndl.noise, 'Value', NOISE);
set(Hndl.batch, 'Value', BATCH);
set(Hndl.gron,  'Value', GRON);
set(Hndl.ModFold, 'Value', MODFOLD);
set(Hndl.Fs, 'Value', Fs);          % vox('input') reads Fs from here
set(Hndl.FsStr, 'String', num2str(Fs));
vox('refreshDuration', 'strsli');
reg = p.Infold.register;            % 1 modal, 2 head, 3 falsetto, 0 fold file
set(Hndl.modal,   'Value', reg == 1);
set(Hndl.head,    'Value', reg == 2);
set(Hndl.falsett, 'Value', reg == 3);

% control file (profiles since #74); a moved file is looked for by its
% name in examples/control/ and out/
ctrl = '';
if isfield(p, 'control') && ~isempty(p.control)
    ctrl = p.control;
    if ~isfile(ctrl)
        [~, n, e] = fileparts(ctrl);
        vdir = fileparts(mfilename('fullpath'));
        cand = {fullfile(vdir, 'examples', 'control', [n e]), voxoutdir([n e])};
        k = find(cellfun(@isfile, cand), 1);
        if isempty(k)
            warning('vox:profile', 'Control file "%s" of the profile not found; calculated without it.', ctrl);
            ctrl = '';
        else
            ctrl = cand{k};
        end
    end
end
voxcontrolfile('select', ctrl);

% vowel, tract model, input; refreshPopup sets the names of the results
% (SD_NAMES) and shows the result of these settings, if there is one
set(Hndl.VOWEL, 'Value', p.vowel);
if isfield(p.data, 'properties') && isfield(p.data.properties, 'mode')
    set(Hndl.TractCalcMode, 'Value', p.data.properties.mode);
end
set(Hndl.INPUT, 'Value', p.iniinput);
vox('refreshPopup');

% data of the main window and vocal fold parameters of the profile: after
% refreshPopup, because vox('input') takes them from the loaded result
set(Hndl.figureNumber, 'UserData', p.data);
for f = fieldnames(p.Infold)'
    Infold.(f{1}) = p.Infold.(f{1});
end
Infold.ptg      = p.PTG;            % as parameterfile_var did
Infold.tvakt    = p.TVAKT;
Infold.calctime = TMAX/1000;
vox('refreshptg', 'strsli');
vox('refreshtvakt', 'strsli');
end
