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

The code base dates from 1999–2023 and is currently being cleaned up for current
MATLAB releases. Known problems are tracked in the
[issues](https://github.com/musicacoustics/vox/issues); some features (WAV import,
recording, movie export) rely on functions that no longer exist in current MATLAB
and are being replaced.

## Requirements

- MATLAB (tested with R2026a; R2022b is expected to work)
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

Select the operation mode in the **Input** menu (Folds, Tract, VF*VT, Combi), set
the parameters and press **Calc**. **Quit** stops a calculation without saving,
**Break** stops it and keeps the results.

On MATLAB R2025a and later with a dark desktop theme, set
*Home > Settings > MATLAB > Appearance > Figure Theme* to *Light* until
[#3](https://github.com/musicacoustics/vox/issues/3) is fixed.

## Contributing

Contributions are welcome, also from students. Please work on a branch and open a
pull request; small, focused changes are easiest to review. Changes to numerical or
physical behaviour must be checked against reference results.

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
