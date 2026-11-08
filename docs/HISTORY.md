# History of VOX

This document records where VOX comes from, which earlier versions exist, and the
state of the code when it was revived in November 2026.

## Timeline

| Period | What happened |
|---|---|
| 1999–2001 | VOX written by Malte Kob at RWTH Aachen University (Department of Phoniatrics, Pedaudiology and Communication Disorders) as part of the doctoral research on physical modelling of the singing voice (thesis 2002). Students contributed individual functions in their theses (student research projects and diploma theses). |
| 2005–2009 | Development in a Subversion repository at RWTH Aachen. |
| 2008–2009 | Java port "JVOX" started by a further staff member (see below). |
| 2010–2015 | Further development; a snapshot from 2010/2011 with 91 m-files exists. The installation notes (`readme.txt`) date from 2015, Detmold. |
| 2018–2023 | Changes to the vocal tract (tube model) in 2018, to the fold editor and the GUI in 2023. |
| March 2025 | Upload to github.com/voiceresearch/models (code state of May 2023), during the maintainer's time at the mdw – University of Music and Performing Arts Vienna. |
| July 2026 | An automated modernisation attempt on a local copy broke several files (see below). These changes were discarded. |
| November 2026 | Analysis of all known versions, import into github.com/musicacoustics/vox, working environment and issue list set up. |

## Earlier versions

The following versions were found and compared in November 2026. They are kept in
the maintainer's archive and are not part of this repository.

- Subversion working copies from RWTH Aachen: an older trunk (2005–2008) and the
  last working copy (February 2009)
- A snapshot of 2010/2011 (91 m-files)
- The upload of March 2025 (92 m-files), which is the first commit of this repository
- A local working version of July 2026, damaged by the automated patch session

89 of the 92 m-files of the 2025 upload are identical to the latest local version.
The 2025 upload contains the only clean copy of `siggi.m` and is therefore the
baseline for all further work.

## The Java port (JVOX)

In 2008–2009 a Java port was started with a modular architecture: lung, glottis,
vocal tract and mouth as exchangeable sub-models with a common time-step interface,
and a Swing GUI. Only the vocal folds were implemented in substance, as a new
three-dimensional multi-mass model, with open points (glottal gap, intersections of
masses, signs of the tension forces). The vocal tract and the radiation at the mouth
remained empty stubs and the main solver loop was commented out. JVOX never became
a runnable complete model and was not compared with the MATLAB results. Its
architecture is a useful template for a future port; its code is not part of this
repository.

## The July 2026 patch session

An automated attempt to modernise a local copy changed `vox.m`, `combicalc.m`,
`siggi.m` and added `safe_contains.m`. It left `safe_contains.m` as a single line
with literal `\n` characters (a syntax error), removed an `end` in `combicalc.m`
(the coupled simulation no longer ran), replaced several removed MATLAB functions
only halfway and added colour overrides for the GUI. None of these changes affected
the physics. They were discarded; the modernisation is being redone step by step
through the issues of this repository.

## State of the code in November 2026

- About 92 m-files with about 14,400 lines (about 10,000 lines of code)
- Physical model (vocal folds, vocal tract, coupling, noise): about 3,000 lines of
  code in 51 files
- GUI and control (`vox.m`, `voxgui.m`, editors, batch and parameter modes): about
  5,900 lines of code in 21 files
- 84 global variables in 35 files; many `try` blocks without `catch`
- Several functions no longer exist in current MATLAB (`wavread`, `wavrecord`,
  `avifile`, `addframe`); since MATLAB R2025a figures follow the desktop theme,
  which mixes with the hard-coded colours of VOX
- Files are stored in Windows-1252 encoding

All known problems are listed as
[issues](https://github.com/musicacoustics/vox/issues).

## Plans

1. Clean up the MATLAB code for current releases (issues), protected by reference
   runs and regression tests
2. Port VOX to Python (NumPy/SciPy with a compiled time-step core), using the same
   reference tests as acceptance criteria, with computation and GUI separated

## Contributors

- Malte Kob – author and maintainer
- Students who contributed functions in their theses: *to be added*
- Author of the Java port JVOX: *to be added*
