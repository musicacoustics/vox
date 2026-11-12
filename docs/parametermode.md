# Parameter mode (Para) and FE mode: analysis and proposal (#74)

Status: analysis and proposal, no code change. The decisions in section 6
are the maintainer's.

## Summary

- **Para** (button *Para*, window "Parametermode") keeps a list of
  *profiles*, each a complete set of VOX settings, in a `.mat` file and
  runs one combi calculation per profile.
- **FE mode** (checkbox *FE*, list *FE inputs*) drives the fold model
  during a combi calculation with time series of the left and right fold
  positions from `FE*.txt` files; Para can run such a file as well.
- All code files are unchanged since October 2010 (apart from the
  November 2026 clean-up). Missing in the repository are `parameters.mat`
  (replaced by `voxprofile.m` in #15) and `samplepara.mat` (needed for FE
  files in Para); both exist in the old copies on the maintainer's computer.
- A trial run on `main` shows that Para never calculated its profiles with
  *start* (also in the 2010 code), that *save settings* starts a
  calculation and keeps adding profiles afterwards, that profiles overwrite
  each other's results, and that the FE time axis and column order are
  inconsistent (section 4).
- Proposal: repair Para in the existing window in small steps with tests
  (stage 1), and later separate the calculation from the GUI and turn Para
  into a general parameter study (stage 2, with #18 and the Python port).

## 1. What Para and FE do

### Para: a list of combi runs

The window `parametermode_gui.fig` has these controls:

| control | callback | what it does |
|---|---|---|
| *create new file* | `parametermode('new')` | save dialog for `para*.mat`; writes one profile of the current state (template, since #15 from `voxprofile`) |
| *load existing file* | `parametermode('load')` | open dialog for `.mat` or `FE*.txt`; a `.mat` provides the profiles, an `FE*.txt` uses `samplepara.mat` from the same folder |
| *save settings* | `parametermode('save')` | sets `PROFILE = 1` and calls `vox('combicalc')`; `combicalc` stores the current state as the next profile (`parametermode('getdata')`) and then calculates |
| *profilenumber* | `parametermode('refresh')` | sets duration, Fs, pressure, stress, register, vowel, input, tract mode, checkboxes and the GUI data of the chosen profile |
| *start* | `parametermode('start')` | for every profile `i`: `vox('initialize','parameterfile_var')`, which applies the profile through `parameterfile_var.m` and calls `vox('combicalc')` |
| *close* | `parametermode('close')` | closes the window |
| file name, path | edit fields | the parameter file |

A profile (`datas(i)`) holds `data` (GUI data: area function, tract
properties, batch modulation), `Infold` (fold parameters), the switches
`PARA`, `BATCH`, `TRACH`, `FOLD`, `TRACT`, `NOISE`, `MODFOLD`, and `vowel`,
`iniinput`, `TVAKT`, `PTG`, `TMAX`, `Fs`, `MAXSEGMENTS`, `MAXDEVLIMIT`,
`XI`, `Xi0`, `MAXM`, `GRON`.

### FE mode: fold positions over time

The checkbox *FE* in the main window (`vox('FEchange')`) lists the files
`FE*.txt` of the current folder (the VOX folder) in the popup *FE inputs*;
choosing one (`vox('paradisplay')`) makes it the input of the next
Combicalc. `combicalc` then reads the file row by row during the
calculation and sets the fold positions, optionally also the active stress:

| column | content (as `combicalc` reads it) |
|---|---|
| 1 | time of the row |
| 2–4 | `Infold.wmaxla`: x, y, z of the left fold, anterior |
| 5–7 | `Infold.w0lp`: x, y, z of the left fold, posterior |
| 8–10 | `Infold.wmaxra`: right, anterior |
| 11–13 | `Infold.w0rp`: right, posterior |
| 14 | active stress `Infold.tvakt` (used when > 0) |

The values are multiplied by 1000 (`refactor`), i.e. mm in the file, µm in
VOX. `params.m` uses x as the distance of the fold from the midline at the
posterior (`w0`) and anterior (`wmax`) end and z for the vertical position;
`interpvf.m` interpolates the rest positions of all masses between them.
A new row is taken when the time of the calculation passes the time of the
row. With the window *ModFold* open, its sliders follow the file.

"FE" is not explained anywhere in the code. The values look like the
output of a finite-element model of the larynx: the movement of the vocal
processes over a few seconds (`FE005unilatmitzeit` = unilateral, with time;
`FE006phonmitzeit` = phonation, with time; `FE_AG003` unknown). The
comments name the author "basti" (a student; the files date from 2010). This is an
assumption; see the decisions in section 6.

Para with an FE file: *load existing file* with an `FE*.txt` loads
`samplepara.mat` (one profile) from the folder of that file; *start* applies
it through `parameterfile_var.m`, which also reads the first row of the FE
file. Results are saved as `out_cF<vowel><flags>_<nnn>` (`nnn` = characters
3–5 of the FE file name).

## 2. Files

| file | role | in the repository | in the old copies |
|---|---|---|---|
| `parametermode.m` | callbacks of the Para window | yes (2010 code, #15 fixes) | yes, 2010 |
| `parametermode_gui.fig` | Para window (GUIDE) | yes, identical to 2010 | yes |
| `parameterfile_var.m` | applies a profile; contains `function parameterfile1`, called with `eval` from `vox.m` | yes, identical to 2010 | yes |
| `voxprofile.m` | profile of the current state (template for a new file) | yes, new in #15 (November 2026) | – |
| `combicalc.m` | stores a profile (`PROFILE`), FE input (`isfe`), result names for Para/FE | yes | yes |
| `vox.m` | `initialize` with `'parameterfile_var'`, `Parametermode`, `FEchange`, `paradisplay`, Para branch of `input` | yes | yes |
| `voxgui.m` | button *Para*, checkbox *FE*, popup *FE inputs* | yes | yes |
| `foldmod.m`, `params.m`, `interpvf.m` | left/right fold positions | yes | yes |
| `parameters.mat` | template: one profile (vowel 18, Fs 44100, TMAX 100 ms, ModFold on) | **no** (#15: replaced by `voxprofile`) | yes, 19.10.2010, 0.9 MB |
| `samplepara.mat` | the profile for FE runs (vowel /a/, Fs 22050, modal, w0 = wmax = 25 µm) | **no** | yes, 19.10.2010, 17 kB |
| `FE005unilatmitzeit.txt`, `FE006phonmitzeit.txt`, `FE_AG003.txt` | FE inputs, 175/224/201 rows × 14 columns | yes | yes (same content) |
| `PositionFE.txt` | 5 rows × 13 numbers | yes | yes; **read by no code** |
| `12.mat` | a saved fold result (`foldsave`), 220 samples, 0.55 MB | no | yes; not part of Para |

Old copies found on this computer (FamilieKob-PC) on 12 November 2026:

| copy | state | Para files |
|---|---|---|
| `Dropbox/Matlab/vox/vox.zip` (= `Sciebo_HfM/Software/Matlab/vox/vox.zip`), dated 3.4.2017 | files of 2010–2015 | all of the table, incl. `parameters.mat`, `samplepara.mat`, `12.mat` |
| `Dropbox/Matlab/vox/` | code state May 2023 (= first commit of this repository) | the same files |
| `Sciebo_HfM/Software/Matlab/vox/` | July 2026 copy (damaged by the patch session) | the same files |
| `Dropbox/Matlab/voxupdate.zip`, 16.4.2018 | 8 files of the tube model, `siggi`, `combicalc` | none |
| first commit `8dbf0dd` (March 2025) | May 2023 | code and `FE*.txt`, no `.mat` |

The Para code is identical in all of them except for the character
encoding and line endings; `combicalc.m` and `vox.m` changed elsewhere,
not in the Para and FE parts. The Subversion working copies (2005–2009)
and the 2010/2011 snapshot named in `docs/HISTORY.md` are not on this
computer; they could show whether Para or FE was ever more complete.

## 3. How it was used, as far as the code shows

- Profiles were collected with *save settings*, which also calculated each
  one; *start* was meant to recalculate a whole file.
- FE inputs were used from the main window (checkbox *FE*), one file per
  Combicalc, or in Para with `samplepara.mat`.
- Results stayed in the VOX folder under the usual combi names (now in
  `out/`, #29).

## 4. Findings (trial run on `main`, R2026a, hidden, 12 November 2026)

The trial used a copy of `main` with `samplepara.mat` from the 2017
archive; file dialogs were replaced by stubs that return fixed names.

1. **_start_ calculates nothing for an ordinary parameter file.**
   `vox('initialize','parameterfile_var')` sets `PARA = 1`, but the
   following `vox('refreshPopup')` calls `vox('input')`, which sets
   `PARA = 0` again because the file name does not contain "FE"; the final
   `if PARA, vox('combicalc'), end` is skipped. The 2010 code does the
   same. Only *save settings* and FE files ever led to a calculation.
2. **_save settings_ calculates, and keeps collecting.** It runs a full
   combi calculation (comment in the code: "basti: is this right??? to
   start calc if save is pressed?"). `PROFILE` stays 1 afterwards, so every
   later Combicalc, also outside the Para window, appends another profile
   (trial: 3 profiles after 2 saves and one ordinary Combicalc).
3. **A profile is not applied completely.**
   - `vox('initialize', ...)` first resets all settings to the defaults
     (e.g. Fs, duration, graphics on) and only then applies the profile.
   - The controls of the main window are not set to the profile, and
     `refreshPopup` takes the vowel and the area function from the vowel
     popup, not from the profile.
   - `parameterfile_var` builds `Infold` from a few fields: fold positions
     from the register (25/175/1 µm), fixed `k1`, `k2`, mass factors 1.
     Changes made in the fold editor and fields added later are lost.
     With `samplepara.mat` of 2010 the calculation stops in `params.m`:
     "Unrecognized field name vflength" (the fold length of the 2023
     editor).
4. **Results overwrite each other.** A Para result gets the name of an
   ordinary combi result (`out_cs_a10000`; with `PARA` still 1 a `B` at
   position 5, for FE `out_cF…_<nnn>`). The suffix `para<i>`/`fem<i>`
   (`data.suffix`) is computed but not used. Profiles that differ only in
   pressure, stress, duration, Fs, batch modulation etc. write the same
   file; only the last one remains.
5. **FE time axis.** Column 1 runs from 0 to 3.48, 4.46 or 4 in steps of
   0.02. `combicalc` takes the maximum as the duration in **ms** (trial:
   3.48 ms, 77 samples instead of 3.48 s), but compares the row times with
   the time of the calculation in **seconds**. In seconds the files cover
   3.5–4.5 s at 50 rows per second, which fits movements of the vocal
   processes.
6. **FE columns.** `parameterfile_var` reads columns 2–4 as `w0lp`, 5–7 as
   `w0rp`, 8–10 as `wmaxla`, 11–13 as `wmaxra`, and reads 13 instead of 14
   numbers per row (so its duration is taken from shifted columns);
   `combicalc` reads the order of the table in section 1. In all three
   files columns 5–7 and 11–13 are zero. The x values of the left side are
   negative (FE005: −1.95 mm), while VOX treats x as a distance from the
   midline (`w0` without, `wmax` with `abs`). Which column is posterior or
   anterior, and the sign convention, are not documented.
7. **FE files and `samplepara.mat` are looked for in different places.**
   The FE list comes from the current folder only; *load existing file*
   reads `samplepara.mat` from the folder of the FE file, *start* from the
   current folder.
8. **Smaller points.** If a parameter file cannot be used, `vox` falls
   back to a full restart of its window. `parameterfile_var` is called
   with `eval` under another function name. `PositionFE.txt` is never
   read.

## 5. Proposal

Goal: a parameter study is a list of runs; every run is a complete,
reproducible set of settings (optionally with time functions such as the
FE positions); every result is kept together with its settings; running
the list does not depend on the state of the GUI.

### Stage 1: repair in the existing window (small PRs, each with a test)

1. **Profile = complete state, applied completely.**
   `voxprofile` (exists) collects the state; a new `voxapplyprofile(p)`
   sets the globals, `Infold` and `data` from the profile (fields missing
   in old profiles from the defaults of `iniinfold`/`datainit`, e.g.
   `vflength`) and updates the controls through the existing
   callbacks (`refreshDuration`, `refreshptg`, `refreshtvakt`, register,
   vowel, checkboxes with `'strsli'`). It replaces `parameterfile_var.m`
   and the `eval` call; `vox('initialize')` is no longer called per profile.
2. ***save settings* only stores.** `parametermode('save')` appends
   `voxprofile()` to the file; no calculation, no `PROFILE` flag (the
   `PROFILE` block at the start of `combicalc` goes).
3. ***start* calculates every profile and keeps every result.**
   For profile `i`: `voxapplyprofile`, Combicalc, save the result as
   `out/para_<file>_<i>.mat` (with `data.profile` = the profile). The
   profile popup then shows the profile and its result; a short summary
   (number, varied parameters, file) appears in the Command Window.
   *Quit*/*Break* stop the series.
4. **FE as an optional part of a profile.** A profile may name an FE file;
   the combi run takes the positions from it. Fixes: time in seconds
   (duration = 1000 × last time in ms), one column order for all readers
   (decision 6.1), 14 columns, the FE file looked for in `examples/` or the
   folder chosen in a dialog instead of the current folder;
   `samplepara.mat` is no longer needed (the current state is the profile).
   Linear interpolation between the rows instead of steps is possible but
   changes results; only on request.
5. **Files.** `parameters.mat`, `samplepara.mat` and `12.mat` are not
   added to the repository. The `FE*.txt` move to `examples/` with a README
   on their columns and units (after decision 6.1); `PositionFE.txt` is
   explained or removed (decision 6.2). Parameter files are written to
   `out/` (done in #73).
6. **Tests** (`tests/voxtest_paramode.m`, `tests/voxtest_fe.m`):
   - two profiles that differ in pressure and vowel give two result files,
     each bit-identical to an ordinary Combicalc with the same settings;
   - *save settings* does not calculate; a Combicalc after Para does not
     add profiles; an old profile without `vflength` runs;
   - FE005: the duration follows the file, the positions follow the rows
     at their times, a cancelled dialog changes nothing.

Order and size: 1 + 2 (one PR), 3 (one PR), 4 (one PR, after decision
6.1), 5 (with 4), tests with each PR. Results of ordinary Fold, Tract and
Combi calculations stay bit-identical (regression test).

### Stage 2: parameter study without GUI (later, with #18 and the port)

- `voxrun(profile)` calculates one run from a profile without reading or
  writing GUI controls; the GUI and Para only build profiles and show
  results.
- A study is described by a base profile plus a table of the varied
  parameters (e.g. pressure 400:200:1200 × vowels /a/, /i/, /u/), readable
  as CSV or JSON, so that series can be written and versioned without the
  GUI; results are collected in one table (file, parameters, f0, levels).
- FE positions and the batch modulation of `controlfile` (pressure,
  stress, tract radius over time) become one kind of input: time
  functions of parameters.
- The same profiles and results serve as reference tests for the Python
  port.

## 6. Decisions for the maintainer

1. **FE mode:** keep it? If yes: unit of the time column (seconds?),
   meaning of the column groups (which are posterior and anterior, left
   and right), sign convention of x, origin of the data (thesis, FE
   model) and its reference, to be written into `examples/README.md`.
2. **`PositionFE.txt`:** what is it (5 rows, 13 numbers: number and
   positions?), keep or remove?
3. **_save settings_:** only store (proposal), or store and calculate as
   before?
4. **Result names:** `out/para_<file>_<i>.mat` (proposal), or a folder per
   parameter file?
5. **Profile format for stage 2:** `.mat` only, or also a readable table
   (CSV/JSON) for series?
6. **Old copies:** are the Subversion working copies available somewhere?
   They could contain a more complete FE/Para state or the thesis that
   introduced it.
