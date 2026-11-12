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
- `tractsig.m`, `voctract.m` – vocal tract, stairs; `ctim2.m` with `coneprepare.m`
  and `conestep.m` – vocal tract, tubes (conical segments, see
  `docs/conical-tubes.md`; `propagator.m`, `preparation.m` etc. are the former,
  unstable formulation, unused)
- `combicalc.m` – coupled fold/tract simulation
- `noisesig.m` – turbulence noise
- `foldmod.m`, `areas3.m` – interactive editors for fold and tract geometry
- `controlfile.m`, `parametermode.m` – batch and parameter modes; `voxcontrol*.m` –
  control files (parameters over time in a combi run, #74)
- `out/` – everything VOX writes (results, session files, WAV, movies, CSV); ignored
  by git. Build every path of a file that VOX writes or reads back with
  `voxoutdir(name)`; `voxmoveoutput.m` moves files of older versions from next to
  `vox.m` into `out/` at the start (#29)
- `examples/` – example results of older versions (tracked; VOX does not write there)
- `tests/` (repository root) – test suite, see Testing

## Environment

- MATLAB R2025a or newer for development and tests (R2026a on some machines; keep
  VOX itself runnable on R2022b where possible: guard newer functions), Signal
  Processing Toolbox (`decimate`, `resample`, `fftfilt`)
- Start: `cd VOX/matlab` then `vox`
- MATLAB is reachable through the MATLAB MCP server (MATLAB Agentic Toolkit). Use the
  user's shared MATLAB session for interactive work when available, but never run
  tests there (see Testing).
- Machine-specific settings (MATLAB install paths, which releases exist on a machine,
  paths of CLI tools such as `gh`) do not belong in this file or the repository; keep
  them in local, per-machine notes.

## Testing

- Run tests **hidden and in the background**, so the user's screen and MATLAB stay
  usable: a separate MATLAB process with `-batch` plus `-noFigureWindows` (Windows) or
  `-nodisplay` (Linux, macOS). `-batch` alone still shows every figure, and VOX opens
  many windows and waitbars. Start long runs as background jobs and do not wait idle.
- Use the suite in `tests/`: `matlab -noFigureWindows -batch "cd tests; runvoxtests"`
  (see `tests/README.md`). It works on copies of `VOX/matlab` in `tempdir`, because VOX
  saves its results into its own folder (`out/`), and compares with the branch `main`:
  Code Analyzer of the changed files, bit-identical regression runs, GUI sweep over
  all controls of the main window (file dialogs stubbed as cancelled), tube model
  against a frequency-domain reference.
- Test scripts must run on MATLAB R2025a and newer. Add tests for a change as
  `tests/voxtest_<name>.m` (last output line `RESULT PASS ...`/`RESULT FAIL ...`)
  instead of throw-away scripts, so that later sessions can reuse them.
- Report in the PR which tests ran, on which release, and what was not tested.

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
  affected feature in MATLAB (hidden, see Testing), and state clearly what was tested
  and what was not.
- Before starting, read the open issues and PRs that touch the same topic (`gh issue
  list`, `gh pr list`); earlier sessions are not remembered otherwise.

## Collaboration (several machines and people)

The maintainer, other contributors and Claude sessions work on several computers.
GitHub is the only shared state: unpushed branches, local Claude memory, scratchpad
scripts and chat transcripts are invisible to everyone else (in November 2026 two
machines solved the same task because it existed only in a chat).

- **Issue first.** Every task gets an issue before any code is written, also when it
  is asked for in a chat. Create it if it does not exist.
- **Claim it.** Assign the issue, add the label `in progress` and comment who works on
  it and on which machine. Do not start an issue that is `in progress` elsewhere;
  comment there instead.
- **Make it visible early.** Branch `fix/<issue>-<topic>` or `feature/<issue>-<topic>`;
  push after the first commit and open a draft PR (`Closes #<issue>`), so others see
  the work and the files it touches.
- **Start of a session:** `git fetch`, then `gh issue list`, `gh pr list` and the latest
  comments of the issues and PRs you continue.
- **End of a session or pause:** push everything and post a status comment on the PR
  (or the issue): done, tested (which release), not tested, next step, questions for
  the maintainer. The next session, on any machine, reads it with `gh`.
- **Someone else's branch:** pull before you change it, and say what you pushed in a
  PR comment.
- **Merging:** only through PRs (the PR template asks for the test report). Merge small
  PRs soon and update open branches afterwards (`git merge origin/main`). Remove
  `in progress` when the PR is merged or closed. GitHub enforces this for `main` with
  the ruleset `main` (no direct push, no force push, no deletion, 0 approvals);
  its export is `.github/rulesets/main.json` (Settings → Rules → Rulesets → Import).

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
- Parameter mode (Para) and control files (former FE mode): external programs or
  parameter files control the suspension (ends of the vocal folds), the vocal folds
  (subglottal pressure, tension) and the mouth opening over time, e.g. a vibrato;
  analysis of the 2010 state and implementation in `docs/parametermode.md` (#74),
  format in `VOX/matlab/examples/control/README.md`.
