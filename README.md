# VOX – a physical model of the human voice

VOX simulates human voice production in MATLAB. It combines a multi-mass model of
the vocal folds with a model of the vocal tract and computes them separately,
convolved, or coupled in the time domain. A graphical user interface lets you set
the parameters, run the simulations, and look at and listen to the results.

VOX was developed from 1999 at RWTH Aachen University and is being revived and
modernised at the Detmold University of Music (Music Acoustics).

## Features

- **Vocal folds:** multi-mass model with modal, head and falsetto register;
  interactive editor for the fold configuration; subglottal pressure and vocalis
  stress as main parameters
- **Vocal tract:** area functions for a set of vowels, computed as stair segments
  or conical tube segments; interactive editor for the area function; transfer
  function and input impedance
- **Coupling:** convolution of fold and tract signals, or simultaneous ("combi")
  calculation including trachea, glottal interaction and turbulence noise
- **Batch and parameter modes** for series of simulations
- **Output:** time signal, spectrum, spectrogram, mass deflection,
  phonovibrogram, WAV export

## Status

The code base dates from 1999–2023 and was cleaned up for current MATLAB releases
in November 2026. Removed MATLAB functions have been replaced, among them WAV
import, recording and movie export. The tube model of the vocal tract is now
stable. The graphics follow the light or dark figure theme. Open problems are
tracked in the [issues](https://github.com/musicacoustics/vox/issues).

## Requirements

- MATLAB R2022b or newer (tested with R2022b, R2025a and R2026a)
- Signal Processing Toolbox (`decimate`, `resample`, `fftfilt`)

## Getting started

```
git clone https://github.com/musicacoustics/vox.git
```

In MATLAB:

```matlab
cd vox/VOX/matlab
vox
```

VOX stays in this folder and saves its results there.

1. Choose the operation mode in the **Input** menu (upper right): Folds, Tract,
   VF*VT or Combi. VOX shows a result of this mode that was calculated before, if
   there is one. It also sets **Duration of signal** (upper left) to the default
   of the mode: 200 ms for Folds and Combi, 20 ms for Tract. Loading files and
   changing the configuration (checkboxes, register, vowel) keep the duration.
2. Set the parameters and start the calculation:
   - Folds: **Calc** in the vocal fold panel
   - Tract: **Calc** in the vocal tract panel
   - VF*VT: both, then the convolution is shown
   - Combi: **Combicalc** (the Calc buttons are disabled in this mode)
3. **Quit** stops a calculation without saving, **Break** stops it and keeps the
   results.

## Contributing

Contributions are welcome, also from students.

- Start with an issue, work on a branch and open a pull request. The template
  asks for a test report. `main` accepts changes only through pull requests.
- Small, focused changes are easiest to review.
- Changes to numerical or physical behaviour must be checked against reference
  results.
- The test suite in [tests/](tests/README.md) runs hidden in the background:
  `matlab -noFigureWindows -batch "cd tests; runvoxtests"`. It compares a change
  with `main` (Code Analyzer, bit-identical regression runs, GUI sweep, tube model).

Recommended setup: VS Code with the MATLAB extension, connected to MATLAB, and
optionally an AI coding agent (Claude Code or GitHub Copilot) via the MATLAB
Agentic Toolkit. The rules for agents are in [CLAUDE.md](CLAUDE.md) and
[AGENTS.md](AGENTS.md).

## History

See [docs/HISTORY.md](docs/HISTORY.md) for the origin of VOX, earlier versions,
the Java port and the state of the code in November 2026.

## Citation

If you use VOX in your work, please cite it as described in
[CITATION.cff](CITATION.cff) (GitHub shows a "Cite this repository" button).

## License

VOX is free software under the GNU General Public License, version 3 or later;
see [LICENSE](LICENSE).

Copyright (c) 1999–2026 Malte Kob

## Contact

Malte Kob, Detmold University of Music (Music Acoustics),
[ORCID 0000-0002-9159-2712](https://orcid.org/0000-0002-9159-2712)
