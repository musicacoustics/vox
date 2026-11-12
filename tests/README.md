# VOX tests

Tests for VOX (`VOX/matlab`). They run **hidden and in the background** and do not change the repository.

## Requirements

- MATLAB **R2025a or newer** (`runvoxtests` stops on older releases)
- Signal Processing Toolbox (as VOX itself)
- `git` on the path (for the baseline; without it the comparisons are skipped)

## Running

From a shell, in the background, without any window:

```
matlab -noFigureWindows -batch "cd tests; runvoxtests"        % Windows
matlab -nodisplay -batch "cd tests; runvoxtests"              % Linux, macOS
```

or from MATLAB: `cd tests`, then `runvoxtests`. The MATLAB session that calls it waits, but every test runs in its own new MATLAB process of the same release, started with `-batch` and `-noFigureWindows` (Windows) or `-nodisplay` (Linux, macOS). VOX opens many windows and waitbars; without these options they appear on the screen and block the computer.

```matlab
runvoxtests                                   % all tests, baseline: git branch main
runvoxtests('Tests', {'regression'})          % only some tests
runvoxtests('Baseline', 'origin/main')        % other git ref
runvoxtests('Baseline', '')                   % no comparison
r = runvoxtests;  [r.passed]                  % results as struct array
```

VOX saves its results into its own folder (`VOX/matlab/out/`), so every test works on a copy of `VOX/matlab` in `tempdir/voxtests/<date_time>/`. The logs are kept there too.

## Tests

| test | checks | pass when |
|---|---|---|
| `codeanalyzer` | `checkcode` of the `.m` files in `VOX/matlab` that differ from the baseline (also uncommitted and new files) | no message ID occurs more often than on the baseline |
| `regression` | fold 30 ms, tract (stairs) 20 ms, combi (stairs) 30 ms with the default settings, on the change and on the baseline (`voxtest_regression`) | `y`, `z`, `Fs` bit-identical |
| `guisweep` | the callback of every control of the main window: popups with every entry, radio buttons on/off, push buttons, sliders, edits (`voxtest_guisweep`); file dialogs and message boxes are replaced by the stubs in `stubs/` (cancel); not: play, record | no error that does not also occur on the baseline |
| `tubes` | conical tube model (`ctim2`, `coneprepare`, `conestep`, #64): passivity of 300 random tubes; accuracy of 100 ms impulse responses against a frequency-domain reference (exact lossless cones, lossy cylinders, lossy cones as a fine staircase; radiation 1 and 2 of the stairs model); 2 s without wall losses (4 geometries); 20 ms with losses (40 random geometries); combi interface over 1 s (`voxtest_tubes`) | scattering matrix norm ≤ 1, formants within 1 % (lossy cones 1.5 %), median level < 0.5 dB, energy does not grow, last 2 ms at least 20 dB below the maximum, periodic steady state, source and `pin_gl_ac` as `tractsig` |
| `tubestairs` | GUI, vowel /a/, tubes through all points of the radius vector against stairs: tract without wall losses (200 ms) and with the default damping of each model (50 ms); tubes with the default of 2 cones; combi 30 ms with both (`voxtest_tubestairs`) | formants below 4 kHz within 4 %, levels within 3 dB without wall losses, combi peaks within a factor 2, `Infold.pin_gl_ac` set |
| `plotmass3d` | 3D view of the window "Deflection of masses" (`testfill`, #70): seven positions of mucosa and vocalis (open, closed, over the midline, sunk, beside, with offsets), drawn new and as update; Fold Calc 10 ms with graphics (`voxtest_plotmass3d`) | no vertex at x < 0, full medial faces, front faces without overlap, visible mucosa front = its box minus the vocalis box, no error |
| `outfolder` | output folder `out/` (#29): files of an older VOX next to `vox.m` (result, `last_filename`, `recorded`, WAV, CSV, an identical and a different copy of a file in `out/`) at the start; Fold Calc, Tract Calc, VF*VT, Combicalc, background, WAV export, movie dialog, Fold Load and Tract Load of `examples/`, `*.mat` input, LastRec, parameter mode (`voxtest_outfolder`) | old files moved (identical copy removed, different one kept, nothing overwritten); results written to and shown from `out/`; dialogs start in `out/`; no file outside `out/` new or changed |
| `control` | control files (#74): reading (column names, old FE file, broken files); Combi 30 ms with a constant file, with vibrato of pressure, tension and mouth opening, with `FE005…txt` and `adduction.txt`; mouth opening with tubes; checkbox *Control* and its list; Combi without control afterwards (`voxtest_control`) | constant file bit-identical, values per sample as interpolated from the file, result changes with a vibrato, pressure, tension, positions and area function back afterwards, FE time in s and mm → µm, clear errors, result without control bit-identical to the first |
| `paramode` | parameter mode (#74): two profiles (vowel /a/; vowel /aa/ with pressure vibrato and 1100 Pa), *save settings*, *start*, a profile of an older version with `parametermode('run', file)`, *refresh*, *load* with a `.txt` (`voxtest_paramode`) | *save* calculates nothing and later Combicalcs add no profile; every `out/para_<file>_<n>.mat` bit-identical to a Combicalc of its settings; old profile runs; refresh sets vowel, control file and pressure |
| `batch` | variation over time in Fold Calc and Combi (#74): batch window (periodic 50 Hz, 10 %, stress, pressure, tract) with Fold Calc 60 ms and Combi 30 ms, fold display (GRON), Fold Calc with a pressure vibrato file and a mouth file (`voxtest_batch`) | Fold Calc: pressure and tension vary within ±10 %, tract ignored with a message; Combi: pressure modulated; both: result changes, values back afterwards, second run bit-identical (no drift); control file followed, mouth ignored with a warning; without batch/control afterwards bit-identical to the first runs |

Further tests of a change: a function `voxtest_<name>(voxdir)` in this folder that prints `RESULT PASS ...` or `RESULT FAIL ...` as its last line and exits with `exit(1)` on failure; run it with `runvoxtests('Tests', {'<name>'})`.

## Known results

- On `main` (November 2026) the GUI sweep finds one error: Combi with fold data from a file (register 0) uses `PARFOLD.var.flow` of an empty `PARFOLD` (`combicalc.m`).
- Not covered: real mouse actions in axes (tract and fold editors), audio devices, movie export with a real file name.
