# Tube model M5: finite differences of the Webster equation (#67, plan)

Status: **plan for later work**. Background, the other methods and the
literature: `docs/conical-tubes.md` (#64, branch `feature/64-conical-tubes`).

## Why

A finite-difference scheme of the Webster (horn) equation is stable for every
profile when it is written so that a discrete energy cannot grow (Bilbao
2009; Bilbao and Chick 2013). It does not use segments or waves at all and is
therefore an **independent time-domain reference** for the tube models (M2 of
#64, later M3 of #66). Two models computed in completely different ways that
give the same result are strong evidence that both are right. It could also
become a third tract mode next to stairs and tubes.

## Starting point: workshop code (Desvages and Kob, Detmold 2017)

The maintainer's file `WebsterEquationMK_m2.m` (not in the repository):

- grid spacing h = c/Fs with Courant number 1 (Fs = 88.2 kHz: h = 3.9 mm);
- profiles cylinder, cone, exponential, neck; tube length L = 0.5 m;
- excitation `E*vIn` at the left end (velocity), pressure output at the right
  end;
- radiation at the open end with the coefficients 2.0881 and 0.7407 (Bilbao),
  no wall losses.

To be corrected: the cone profile `r = r0 + (rL - r0)*x` must read `x/L`;
with L = 0.5 m the cone ends at 1.5·r0 instead of rL.

Open question: may the code (co-author Charlotte Desvages) be added to the
repository, or should the reference be written anew from Bilbao (2009)?

## Steps

1. Function `websterref(tubes, Fs, c, rho, T)` (test helper): profile from
   `data.tubes` (piecewise linear radius, same first and last radius as the
   stairs model), volume velocity of the glottis in, pressure at the mouth
   out; the same radiation load as the tube model (stairs model, `radimp`),
   so that the results can be compared sample by sample.
2. Check against the frequency-domain reference `tuberef` of
   `tests/voxtest_tubes.m` (lossless cones): formants within 1 % below 5 kHz.
3. Add it to `tests/voxtest_tubes.m` as the time-domain reference of the
   tube model: impulse responses of /a/, cones, random geometries.
4. Optional: wall losses (Bilbao and Chick 2013), and a third tract mode in
   the GUI.

## Effort

Small for the reference (the scheme exists), medium for a GUI mode.

## References

- Bilbao, S. (2009). Numerical Sound Synthesis: Finite Difference Schemes and Simulation in Musical Acoustics. Wiley.
- Bilbao, S., Chick, J. (2013). Finite difference time domain simulation for the brass instrument bore. J. Acoust. Soc. Am. 134(5), 3860-3871. https://doi.org/10.1121/1.4822479
- Desvages, C., Kob, M. (2017). Workshop code `WebsterEquationMK_m2.m`, Detmold (not published).
