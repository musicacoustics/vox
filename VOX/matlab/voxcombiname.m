function name = voxcombiname()
%VOXCOMBINAME File name of the combi result for the current settings.
%   NAME = VOXCOMBINAME() returns the name under which combicalc saves a
%   combi result and under which vox('input') looks for it, e.g.
%   'out_cs_a10110':
%     'out', '_' or 'm' (modified tract), 'cs' (stairs) or 'ct' (tubes),
%     vowel (SD_NAMES(2,7:8)), fold register, and the flags TRACH, FOLD,
%     TRACT, NOISE.
%   With a control file the name of the file follows, e.g.
%   'out_cs_a10000_vibrato_ptg' (#74), so that controlled results do not
%   overwrite the others; such names are longer than the 15 characters of
%   SD_NAMES.
%   Both places built the name separately and differently before, so a
%   result could be saved under one name and looked for under another.
%
%   See also combicalc, vox, voxcontrolfile.

global Hndl SD_NAMES Infold TRACH FOLD TRACT NOISE %#ok<GVMIS>

if get(Hndl.TractCalcMode, 'value') == 1   % stairs calc.
    fname = 'cs';
else
    fname = 'ct';
end
if get(Hndl.ModTract, 'value') == 1        % modified tract
    modflag = 'm';
else
    modflag = '_';
end
name = ['out' modflag fname SD_NAMES(2,7:8) num2str(Infold.register) ...
    num2str(TRACH) num2str(FOLD) num2str(TRACT) num2str(NOISE) voxcontrolfile('tag')];
end
