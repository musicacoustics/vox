# VOX – voice production model (MATLAB)

VOX simulates human voice production: a multi-mass model of the vocal folds and a
vocal tract model (stair or tube segments), computed separately, convolved, or
coupled in time ("combi" mode), all driven from a MATLAB GUI. Originally written
1999–2001 by Malte Kob (RWTH Aachen) with contributions from students' theses,
extended until 2023. Rights: Malte Kob. Maintained by Malte Kob, Detmold University
of Music (Music Acoustics). The maintainer writes German; keep code, comments and
commit messages in English.

Repository: github.com/musicacoustics/vox, imported in November 2026 from
github.com/voiceresearch/models (the owner account of that repository is no longer
accessible; do not push there).

## Layout (VOX/matlab)

- `vox.m` – main GUI controller (one big `switch action`), `voxgui.m` builds the GUI
- `foldsig.m` → `siggi.m` (script) – vocal fold time loop; forces in `aerforc.m`,
  `contforc.m`, `cplforc.m`, `dampforc.m`; integration in `deq16m.m`
- `tractsig.m`, `ctim2.m`, `voctract.m`, `propagator.m` – vocal tract
- `combicalc.m` – coupled fold/tract simulation
- `noisesig.m` – turbulence noise
- `foldmod.m`, `areas3.m` – interactive editors for fold and tract geometry
- `controlfile.m`, `parametermode.m` – batch and parameter modes
- `out/` – example results (generated data, should not be version-controlled)

## Environment

- MATLAB R2026a (R2022b also installed on some machines), Signal Processing Toolbox
  (`decimate`, `resample`, `fftfilt`)
- Start: `cd VOX/matlab` then `vox`
- MATLAB is reachable through the MATLAB MCP server (MATLAB Agentic Toolkit). Prefer
  the user's shared MATLAB session when available.

## Rules

- Work on a branch per issue; never commit directly to `main`. Small, focused commits.
- Do not change numerical or physical behaviour without comparing against reference
  outputs; report any deviation instead of hiding it.
- No new global variables. No `try` without a `catch` that reports the error.
- Compare strings with `strcmp`/`isequal`, build paths with `fullfile` (no hard-coded
  `'\'`), handle cancelled `uigetfile`/`uiputfile` dialogs (they return `0`).
- Replace removed MATLAB functions completely and keep behaviour: `wavread` →
  `audioread` (two outputs), `wavrecord` → `audiorecorder`, `avifile`/`addframe` →
  `VideoWriter`/`writeVideo` including `close`.
- Do not reformat whole files; keep existing comments and author notes.
- Never commit generated results (`.mat`, `.wav`, `.avi`), autosaves (`.asv`) or
  machine-specific files.
- Before finishing a change: run the Code Analyzer on the changed files, run the
  affected feature in MATLAB, and state clearly what was tested and what was not.

## History and known issues (analysis November 2026)

Full history, earlier versions and the Java port: `docs/HISTORY.md`.

- The first commit (upload March 2025, code state May 2023) is the clean baseline.
  An automated patch session in July 2026 damaged a local copy (broken
  `safe_contains.m`, missing `end` in `combicalc.m`); do not reintroduce those changes.
- Open issues in the baseline: removed functions `wavread` (WAV import), `wavrecord`
  (recording), `avifile`/`addframe` (movie export in vox, combicalc, plotmass,
  noisesig); obsolete `figflag`; `tractdispmode` sets `outzfm` instead of `outzfg` for
  Imp-glottis; `tractsave` concatenates `datetime` as text; cancelled file dialogs not
  handled; Windows-only paths and a missing separator in `save([path,'out',…])`;
  `LASTPATH` only set when `out/` is newly created; old `.mat` import check
  `exist('data')` is always true; phonovibrogram colormap is 100×1 without negative
  values; `parametermode.m` loads `parameters.mat`, which is not in the repository.
- Architecture debt: ~84 global variables, many `try` blocks without `catch`,
  computation and GUI interleaved. Long-term goal: port to Python, with the same
  reference tests as acceptance criteria.
