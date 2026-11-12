# Example results

Results of older VOX versions, part of the first upload of the repository
(March 2025). They were in `out/` until #29; since then VOX writes all its
files into `out/` (ignored by git), and the examples are kept here so that a
calculation cannot overwrite them. VOX does not write into this folder.

Open them in VOX with **Load** in the vocal fold or vocal tract panel, or with
the Input entry `*.mat` / `*.wav`. The dialogs start in `out/`; change to
`examples/` there.

The names follow the scheme of VOX: `out_vf_n<register><trach><fold><tract><noise>`
(vocal folds), `out_st_<vowel>` (tract, stairs), `out_ms<vowel>` (tract, stairs,
modified area function), `out_cs_<vowel>…` and `outmcs<vowel>…` (combi, stairs;
`m`: modified tract), `out_ft_<vowel>…` (VF*VT). `combi_a.wav` and `conv_a.wav`
are WAV exports (they were called `*.wav.wav` before).

`tests/voxtest_duration.m` uses `out_vf_n10000.mat` (a fold result of 200 ms).
