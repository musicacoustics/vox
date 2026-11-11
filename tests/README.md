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

VOX saves its results into its own folder, so every test works on a copy of `VOX/matlab` in `tempdir/voxtests/<date_time>/`. The logs are kept there too.

## Tests

| test | checks | pass when |
|---|---|---|
| `codeanalyzer` | `checkcode` of the `.m` files in `VOX/matlab` that differ from the baseline (also uncommitted and new files) | no message ID occurs more often than on the baseline |
| `regression` | fold 30 ms, tract (stairs) 20 ms, combi (stairs) 30 ms with the default settings, on the change and on the baseline (`voxtest_regression`) | `y`, `z`, `Fs` bit-identical |
| `guisweep` | the callback of every control of the main window: popups with every entry, radio buttons on/off, push buttons, sliders, edits (`voxtest_guisweep`); file dialogs and message boxes are replaced by the stubs in `stubs/` (cancel); not: play, record | no error that does not also occur on the baseline |
| `tubes` | conical tube model (`ctim2`, `coneprepare`, `conestep`, #64): passivity of 300 random tubes; accuracy of 100 ms impulse responses against a frequency-domain reference (exact lossless cones, lossy cylinders, lossy cones as a fine staircase; radiation 1 and 2 of the stairs model); 2 s without wall losses (4 geometries); 20 ms with losses (40 random geometries); combi interface over 1 s (`voxtest_tubes`) | scattering matrix norm ≤ 1, formants within 1 %, median level < 0.5 dB, energy does not grow, last 2 ms at least 20 dB below the maximum, periodic steady state, source and `pin_gl_ac` as `tractsig` |
| `tubestairs` | GUI, vowel /a/: tract 50 ms with stairs and with tubes through all points of the radius vector; tubes with the default of 2 cones; combi 30 ms with both (`voxtest_tubestairs`) | formants below 4 kHz within 3 %, levels within 6 dB, combi peaks within a factor 2, `Infold.pin_gl_ac` set |

Further tests of a change: a function `voxtest_<name>(voxdir)` in this folder that prints `RESULT PASS ...` or `RESULT FAIL ...` as its last line and exits with `exit(1)` on failure; run it with `runvoxtests('Tests', {'<name>'})`.

## Known results

- On `main` (November 2026) the GUI sweep finds one error: Combi with fold data from a file (register 0) uses `PARFOLD.var.flow` of an empty `PARFOLD` (`combicalc.m`).
- Not covered: real mouse actions in axes (tract and fold editors), audio devices, the parameter mode with its files, movie export with a real file name.
