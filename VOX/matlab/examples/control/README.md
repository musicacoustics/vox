# Control files

A control file varies parameters of VOX over time during a **combi**
calculation: the suspension of the voice apparatus (positions of the ends
of the vocal folds) and the vocal folds (subglottal pressure, vocal fold
tension), and the mouth opening. External programs or parameter files can
control VOX this way, e.g. to produce a vibrato (#74). The FE mode of 2010
did this for the positions; its files (`FE*.txt`) are control files as well.

## Using a control file

- **Main window:** Input *Combi*, checkbox **Control**, then choose the file
  in the list below it (files in `examples/control/` and `out/`, or
  *other file...*). **Combicalc** applies it. The result is saved as the
  usual combi name plus the name of the control file, e.g.
  `out/out_cs_a10000_vibrato_ptg.mat`; the values used per sample are in
  `data.control`.
- **Parameter mode (Para):** *save settings* stores the chosen control file
  with the profile; *start* applies it for that profile. *load existing
  file* with a `.txt` chooses a control file.
- **Scripts and other MATLAB programs:**

  ```matlab
  vox                                           % start VOX
  vox('setcontrol', 'examples/control/vibrato_ptg.txt')
  vox('combicalc')                              % or parametermode('run', file)
  vox('setcontrol', '')                         % switch it off
  ```

- **Writing a vibrato file:** `voxvibrato('my_vibrato.txt', 'ptg', 0.1, 5.5, 2)`
  (pressure ±10 %, 5.5 Hz, 2 s, into `out/`); several quantities:
  `voxvibrato('v.txt', {'ptg', 'tvakt'}, [0.1 0.05], 5.5, 2)`.

After the calculation pressure, tension, positions and area function are
back at their values before it; a later calculation without control file
is not changed.

## Format

A text file. Lines starting with `%` or `#` are comments. The first other
line names the columns (separated by spaces, tabs, commas or semicolons),
every further line holds one number per column. The first column is the
time in **seconds**. Between the rows the values are interpolated linearly;
before the first and after the last row they stay at the first or last
value. `NaN` keeps the value of the start of the calculation.

| column | quantity | unit |
|---|---|---|
| `time` | time | s |
| `ptg` | subglottal pressure | Pa |
| `ptg_factor` | subglottal pressure as a factor of its value at the start | – |
| `tvakt` | active stress of the vocal folds (vocal fold tension) | as the GUI field |
| `tvakt_factor` | active stress as a factor of its value at the start | – |
| `mouth` | mouth opening: factor of the radii of the last 1 cm of the vocal tract (stairs model only) | – |
| `w0`, `wmax` | distance of both vocal folds from the midline at the posterior (`w0`) and the anterior (`wmax`) end | µm |
| `w0lp_x` … `w0lp_z`, `w0rp_*`, `wmaxla_*`, `wmaxra_*` | coordinates of the ends of the left (`l`) and right (`r`) vocal fold, posterior (`p`) and anterior (`a`) | µm |

Example (`vibrato_ptg.txt`, written by `voxvibrato`):

```
% VOX control file: vibrato ptg, depth 0.1, rate 5.5 Hz, 2 s (voxvibrato)
time ptg_factor
0 1
0.002 1.00691
...
```

### Old FE files

`FE*.txt` have no header line and 14 columns: time [s], then the x, y, z
coordinates of `wmaxla`, `w0lp`, `wmaxra`, `w0rp` in **mm**, and the active
stress (used where it is > 0). This is the order in which `combicalc` read
them before #74. VOX converts the coordinates to µm. Their origin
(finite-element model of the larynx, 2010), the meaning of the column groups
and the sign of the coordinates are not documented; see
`docs/parametermode.md`, decisions.

## Files

| file | content |
|---|---|
| `vibrato_ptg.txt` | subglottal pressure ±10 %, 5.5 Hz, 2 s |
| `vibrato_tvakt.txt` | vocal fold tension ±10 %, 5.5 Hz, 2 s |
| `vibrato_mouth.txt` | mouth opening ±20 %, 5.5 Hz, 2 s |
| `adduction.txt` | vocal folds close from 300 µm to 25 µm in 50 ms (onset) |
| `FE005unilatmitzeit.txt`, `FE006phonmitzeit.txt`, `FE_AG003.txt` | old FE files (2010), positions over 3.5–4.5 s |
