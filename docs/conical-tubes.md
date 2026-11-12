# Conical segments in the time domain without instability (#64)

Research notes and implementation of the tube model of VOX. Status: the
maintainer chose **M2** (section 5); it is implemented in `ctim2`,
`coneprepare` and `conestep` (section 6). M3 and M5 are planned for later
(#66 with draft PR #68, #67 with draft PR #69).

## Task

The original tube model (`ctim2`) describes the vocal tract as a chain of
conical segments in the time domain. It became unstable after about 15 ms
(maintainer's recollection with the MATLAB of the time). #45 made it stable by
dividing every cone into cylindrical sub-tubes; this duplicates the stairs
model (Kelly-Lochbaum, `voctract`) and is not wanted.

Goal: a stable time-domain implementation of conical segments, with

- the same input and output radii as the stairs model,
- the corresponding pressure and volume velocity at the input (glottis) and
  the output (mouth), so that both models are driven and read out alike.

## 1. What happened in the original code

The files of the original formulation named below were removed in #19;
their last version is in commit `e35c2d0` (see `docs/HISTORY.md`).

- Origin: the multiconvolution method of the Barcelona group for woodwind
  bores (Martínez, Agulló, Cardona 1988; Barjau, Keefe, Cardona 1999),
  ported from Mathematica (Catalan names in the comments: `canvitram` =
  change of tube, `extremtancat`/`extremobert` = closed/open end, holes and
  fingerings of the woodwind model are still in `preparation.m`). The tubes
  are built from the radius vector of the stairs model (`areaintpol`,
  `radiusconvert`, 2000): piecewise linear radius between selected nodes.
- Every taper change (`middleend.m`), the closed end (`closedend.m`) and the
  input end (`inputend.m`) has a reflection consisting of an instantaneous
  part and an exponential part `exp(nu*t)`, discretised with the
  time-interpolated convolution (`k10`, `k11`, `cosaexp`). Wall losses enter
  through a convolution kernel in every segment (`integralsigma.m`).
- The delay lines were advanced with `rotateright`, which is not in the
  repository; in the repository state it had been replaced by
  `bitshift(x,-1)`, which stops with an error at the first sample in every
  MATLAB release (#28). This is a coding error, not a property of the model.
- With the shift repaired (#34) the original model runs. After 20 ms the
  signal was still finite and plausible; afterwards it grows exponentially
  (vowel /a/: 5·10^27 after 100 ms). This agrees with the recollection of
  about 15 ms until the instability is visible. Two causes (#45):
  1. the `quadl` integration of the loss kernel sums to 1.10 instead of ≤ 1:
     every pass through a segment amplifies by 10 %, also in a cylinder;
  2. the exponential parts grow (`nu > 0`) at taper changes towards a
     smaller or more negative taper and at the closed end of a converging
     cone (section 3).

## 2. Interface of the stairs model (to be matched)

| | stairs (`voctract`, `tractsig`) | tubes (original `ctim2`) |
|---|---|---|
| geometry | radius vector `data.radius`, spacing `data.spacing` | cones through nodes of the same radius vector: same first (glottis) and last (mouth) radius |
| input, combi | pressure wave `out_vf_voc*2*Ag/(Ag+Av)` into the first section (`Ag` glottal area, `Av` first tract area); glottis end reflects with the area ratio | `zcar*out_vf_voc/(rho*c)` with `zcar = 412` (no area), i.e. about 10× louder (#50) |
| input, tract alone | pressure impulse at the glottis end, closed glottis (reflection +1) | velocity converted with `zcar` (`inputend`) |
| output | pressure at the mouth, with radiation filter (`radimp` 1 or 2) | pressure at the end of the last tube |
| feedback to the folds | pressure at the glottis `pin_gl_ac` | none (#50) |

A new conical model should use the plane-wave pressure and volume velocity
at its two ends, so that the glottis coupling, the closed end, the radiation
filter, the output and the feedback can be taken over from the stairs model
unchanged. This also settles #50.

## 3. Why conical segments become unstable

In a cone the pressure waves are spherical and scale with 1/r (r = distance
from the apex). At a junction of two cones (wavefront areas S1, S2,
B = S2/S1, apex distances r1, r2) the scattering contains, besides the
area-ratio coefficients of the Kelly-Lochbaum junction, a first-order filter
(van Walstijn 2007, eq. 7-10):

    Rj(s) = -alpha/(s + alpha),  alpha = (gamma2*S2 - gamma1*S1)/(S2 + S1),
    gamma = c/r  (gamma = 0 for a cylinder)

It is stable only if alpha > 0, i.e. 1/r2 > B/r1. For a taper change towards
a smaller (more negative) taper alpha < 0, and the impulse response grows like
exp(|alpha| t). This holds for about half of all cone combinations (Välimäki
and Karjalainen 1994). The same applies to the junction of a cylinder with a
converging cone: pole at s = c/(2·xi), xi = distance to the apex (Smith, PASP).

The continuous-time model of the whole bore is nevertheless stable (Gilbert,
Kergomard, Polack 1990; Agulló, Barjau, Martínez 1992): the growing part is
cancelled by the wave that returns from the other end of the cone. In discrete
time the cancellation is not exact, and the remainder grows (Smith; van
Walstijn and Smith 1998).

van Walstijn (2007, sec. 2.1 and 5) reports from many tests: with the
bilinear transform or the time-interpolated convolution, piecewise conical
bores **without** losses in the conical sections showed no growth; **with**
loss filters in the conical sections they became unstable. A probable cause:
the junctions are formulated with the lossless propagation constant, the
segments with the lossy one, so the returning wave no longer cancels the
growing part. The original VOX model has exactly this combination (loss
kernel in every cone, lossless junction terms), plus the kernel gain of 1.10.

## 4. Methods in the literature

| | method | stable because | fits VOX | effort |
|---|---|---|---|---|
| M1 | **Switched instances / TIIR** (van Walstijn and Smith 1998; van Walstijn 2007, sec. 3.3; Wang and Smith 1997): keep the unstable structure, run two copies, reset the idle copy every N samples (N longer than the impulse response) | the output only depends on the last N samples | keeps the original structure; the internal growth within N must stay small, which van Walstijn found not always true for narrow cones with high losses (vocal tract constrictions); switching logic | small |
| M2 | **Finite-time realization of the growing part** (Välimäki and Karjalainen 1994: vocal tract of conical sections; van Walstijn and Smith 1998; Mignot, Hélie, Matignon 2008: stable minimal realization of a convergent cone): the growing exponential is needed only until the cancelling wave returns, i.e. over the round trip 2L/c of the cone; it is computed as a finite impulse response over that time | no unstable recursion is left | conical segments as in the original idea; with plane-wave pressure and volume velocity at the segment ends the junctions, the glottis end, the radiation and the output are those of the stairs model; at 88.2 kHz a 2-5 cm cone has a round trip of 10-26 samples, so the finite response is a short direct convolution (no round-off growth, no resets) | medium |
| M3 | **Webster-Lokshin waveguides in a stabilised standard form** (Hélie, Mignot, Matignon 2007; Mignot, Hélie, Matignon 2010a/b; Mignot 2009, stability for N cones): every pipe piece as two delays plus six transfer functions with two free internal reflections, chosen stable | all sub-systems stable by construction, losses (Lokshin) and curvature included | most complete physics; transfer functions with fractional (diffusive) parts must be approximated by fitted recursive filters | large |
| M4 | **Plane-wave reflection and transmission functions per element** (Ducasse 2003) | no unstable element | assumes zero instantaneous reflection to avoid delay-free loops: inaccurate at strong discontinuities unless the sample rate is high; convolutions | medium |
| M5 | **Energy-stable finite differences of the Webster equation** (Bilbao 2009; Bilbao and Chick 2013; maintainer's workshop code `WebsterEquationMK_m2.m`, Desvages and Kob, Detmold 2017) | a discrete energy cannot grow (Courant number ≤ 1) | stable for any profile including cones, velocity input and pressure output as wanted; but a grid with spacing h = c/Fs (3.9 mm at 88.2 kHz), not segments: in cost and structure close to the stairs model | small (code exists) |

Notes on the workshop code (M5): the cone profile `r = r0 + (rL - r0)*x`
should read `x/L` (with L = 0.5 m the cone ends at 1.5·r0 instead of rL);
the scheme has radiation losses at the open end (coefficients 2.0881, 0.7407)
but no wall losses.

## 5. Recommendation and decision

Decision of the maintainer (11 November 2026): implement M2; M3 and M5 as
plans for later work. The proposal as written before the decision (what was
implemented differs in the points noted in section 6):

**M2**: conical segments with plane-wave pressure and volume velocity at their
ends; the growing part of every converging taper realized over the round
trip of its cone as a short finite impulse response.

- Junctions, glottis coupling (`2*Ag/(Ag+Av)`, area-dependent glottis end),
  radiation filter, output pressure at the mouth and the feedback
  `pin_gl_ac` taken over from the stairs model: same radii, same pressure
  and volume velocity at input and output (#50 solved with it).
- Losses: first the same damping as the stairs model (comparability), then
  the viscothermal kernel of #45 (`tubekernel`, sums to 1), included
  consistently in segments and junctions (van Walstijn 2007, sec. 5; M3 as
  the reference formulation).
- **M5 as an independent time-domain reference** (the workshop code turned
  into a test function, same piecewise linear profile, same input and
  output), together with the existing frequency-domain reference of exact
  cones (`tests/voxtest_tubes.m`, `tuberef`) and the stairs model for the
  same vowel.
- Open technical point, to be settled in the derivation: which group of
  elements is the smallest stable unit (one cone between two junctions, or a
  cone together with its neighbours, cf. "smallest enclosing stable model
  component", van Walstijn and Smith 1998; N cones: Mignot 2009, p. 91-95).
- M1 is the fallback if M2 proves too complex: it keeps the original code
  (with the kernel of #45), but it does not remove the instability, it only
  limits its effect.
- The staircase of #45 (`tubeprepare`, `tubekernel` in `ctim2`) is replaced;
  the former files stay for reference (#19).

Steps after the decision: derivation for one cone (lossless) → test against
`tuberef` and M5 → chain of cones with the VOX interface → losses → combi
→ stability tests (2 s impulse responses, random geometries, all vowels).

## 6. Implementation of M2

Files: `coneprepare.m` (geometry, kernels, coefficients), `conestep.m` (one
time step), `ctim2.m` (tract alone and combi, internal sampling rate).

### 6.1 One cone with plane waves at its ends

Each tube end is a port with plane pressure waves (reference impedance
rho·c/S of the end), as in the stairs model. Inside the cone the waves are
spherical. With the signed distances x1, x2 = x1 + L of the ends from the
apex (both negative for a converging cone), T = L/c, the delay D = e^(-sT),
g1 = c/(2·x1), g2 = c/(2·x2) and gam = c/(2·x1·x2) > 0, the continuity of
pressure and volume velocity at both ends gives exactly (lossless):

    p1 = ((1 - g2·B) a1 + (r2/r1) D a2) / Delta
    p2 = ((1 + g1·B) a2 + (r1/r2) D a1) / Delta,      Delta = 1 + gam·K

a1, a2: waves entering the cone at the left and right end; p1, p2: pressures
at the ends; leaving waves b = p - a. B and K are **finite** impulse
responses with the length of the round trip 2T of the cone:

    B(t) = 1,  K(t) = L - c·t/2   for 0 <= t < 2T

The integrators 1/s of the spherical waves, which produce the growing
exponentials at converging junctions (section 3), cancel exactly in this
form: B = (1 - e^(-2sT))/s and K = L/s - (c/2)·B/s have no pole at s = 0. This
is the cancellation by the returning wave of section 3, written so that it
holds in discrete time as well. A cylinder gives g1 = g2 = gam = 0 and
p1 = a1 + D a2, the pure delay of the stairs model. The equations also
describe "the smallest stable unit" (section 5): it is one cone between two
plane-wave ports; its neighbours are not needed.

### 6.2 Discretisation and stability

- Input interpolated linearly between two samples, kernels integrated
  exactly (the time-interpolated convolution of the original code); the
  delay T becomes a linear interpolation. Tube lengths need not be multiples
  of c·dt, but every tube must be at least c·dt long.
- Delta gives the recursion (1 + gam·K0)·p(n) = N(n) - gam·Σ K(m)·p(n-m) with
  coefficients that are positive and do not increase with m. By the
  Eneström-Kakeya theorem all its poles lie inside the unit circle if
  1 + gam·K0 >= gam·K1, which fails only for very steep cones at a coarse
  time step. `coneprepare` checks the poles of every cone; if one is not
  inside, `ctim2` raises the internal sampling rate.
- Passivity, checked numerically (`tests/voxtest_tubes.m`): the scattering
  matrix of power-normalized waves of 300 random tubes (lengths 4-64 mm,
  radii 1-21 mm, lossless and lossy) has a norm <= 1 at all frequencies. A
  chain of passive tubes with lossless junctions, a closed glottis end and a
  passive radiation load cannot gain energy.

### 6.3 Losses

The tube mode keeps the meaning of its damping value: the viscothermal
constant xi of the original code (`data.properties.damping`, default 0.135).
Half of the boundary-layer loss of a tube (kernel of `integralsigma`, closed
form as in the former `tubekernel.m`, coefficients >= 0, sum 1, |H| <= 1) is
applied at each end to the entering and to the leaving wave. The
transmission through a tube gets exactly the loss of its length. A wave that
the cone reflects gets the loss of the tube length as well, which is more
than its real path. In return every tube stays passive for every xi, which is
the condition van Walstijn (2007) found violated when losses are put inside
the cones. A consistent formulation is M3 (#66).

Not taken over: the frequency-independent damping `1 - Xi0` per sample of the
stairs model.

### 6.4 Chain, junctions and ends

- Junctions: plane-wave scattering with the area ratio, as in the stairs
  model; `radiusconvert` can produce radius jumps between tubes (when two
  points of `newradius` are neighbours), they are handled the same way.
- Every tube reflects a small part of a wave in the same sample (the
  kernels start at t = 0); the transmission is delayed by T >= one sample.
  The equations of the two tubes at a junction, of the glottis end and of
  the mouth end are therefore solved per sample as 2x2 systems; no delay is
  added.
- Glottis end: closed (reflection +1), as `voctract` and `tractsig`.
- Mouth: radiation of the stairs model. `radimp` 1: R(s) = -a/(s + a),
  a = c/(2r), discretised as in `voctract`. `radimp` 2: piston in an infinite
  baffle, 1 - 2·J1(kd)/(kd) + j·2·H1(kd)/(kd), as an FIR by frequency
  sampling, |R| <= 1 enforced. `voctract` divides the Struve term by (kd)^2
  and adds the transmitted and the reflected wave to the output; `initract`
  (combi) fits the magnitude only with `yulewalk`; the tube model uses the
  formula above in both modes.
- Output: pressure at the mouth (incident plus reflected wave), as
  `tractsig`.

### 6.5 Interface

| | stairs | tubes before (#45) | tubes now (M2) |
|---|---|---|---|
| tract alone, source | pressure wave 1 at the closed glottis end | `zcar/(rho*c)` ≈ 0.91 | pressure wave 1 at the closed glottis end |
| tract alone, output | `y` mouth pressure, `z` near the glottis | `y` mouth, `z` glottis end | `y` mouth pressure, `z` glottis pressure |
| radiation | `radimp` 1 or 2 | double pole of `openend.m` | `radimp` 1 or 2 (6.4) |
| combi, source | `out_vf_voc·2·Ag/(Ag+Av)` | `zcar/(rho*c)·out_vf_voc` | `out_vf_voc·2·Ag/(Ag+Av)` |
| combi, feedback | `Infold.pin_gl_ac = out_vf_voc·(Ag-Av)/(Ag+Av)` | not stored | the same value, stored in `Infold.pin_gl_ac` |
| noise sources | added at every junction | ignored | ignored (as before) |

`ctim2` gets two more inputs, `glotarea` and `radimp`; `combicalc` passes
`glotarea` and `radimproutine`, `vox('tractcalc')` passes
`data.properties.radimp`.

### 6.6 Open points

- `pin_gl_ac` of `tractsig` contains only the part of the fold signal that
  the glottis reflects: `ppT.junction(1)` is never set, so no wave returning
  from the tract reaches the folds (with `Infold.flags.VOC = 0`, the default,
  the value is not used at all). The tube model returns the same value, so
  that both models act alike; a real feedback would change both.
- The damping value of the GUI (`data.properties.damping`) has two
  meanings: the per-sample damping `Xi0` (0.005135) of the stairs mode and
  the viscothermal constant `XI` (0.135) of the tube mode. When the mode is
  switched, VOX loads the last result file of that mode (with the damping
  stored there) or, without one, sets the default of the mode
  (`datainit`). The value in use is shown in the tract editor.
- Default `MAXSEGMENTS = 2`: the tube model of a vowel consists of only two
  cones unless more are set in the tract editor.
- Noise sources (`PARNOISE`) are not fed into the tube model.

## References

- Agulló, J., Barjau, A., Martínez, J. (1992). On the time-domain description of conical bores. J. Acoust. Soc. Am. 91(2), 1099-1105.
- Barjau, A., Keefe, D. H., Cardona, S. (1999). Time-domain simulation of acoustical waveguides with arbitrarily spaced discontinuities. J. Acoust. Soc. Am. 105(5), 1951-1964.
- Benade, A. H. (1988). Equivalent circuits for conical waveguides. J. Acoust. Soc. Am. 83(5), 1764-1769.
- Bilbao, S. (2009). Numerical Sound Synthesis: Finite Difference Schemes and Simulation in Musical Acoustics. Wiley.
- Bilbao, S., Chick, J. (2013). Finite difference time domain simulation for the brass instrument bore. J. Acoust. Soc. Am. 134(5), 3860-3871. https://doi.org/10.1121/1.4822479
- Ducasse, E. (2003). A physical model of a single-reed wind instrument, including actions of the player. Computer Music J. 27(1), 59-70.
- Gilbert, J., Kergomard, J., Polack, J. D. (1990). On the reflection functions associated with discontinuities in conical bores. J. Acoust. Soc. Am. 87(4), 1773-1780.
- Hélie, T., Mignot, R., Matignon, D. (2007). Waveguide modeling of lossy flared acoustic pipes: derivation of a Kelly-Lochbaum structure for real-time simulations. IEEE WASPAA, 267-270.
- Martínez, J., Agulló, J., Cardona, S. (1988). Conical bores. Part II: Multiconvolution. J. Acoust. Soc. Am. 84(5), 1620-1627.
- Mignot, R., Hélie, T., Matignon, D. (2008). Stable realization of a delay system modeling a convergent acoustic cone. 16th Mediterranean Conf. on Control and Automation (MED'08), Ajaccio, 1574-1579. https://hal.science/hal-01106362
- Mignot, R. (2009). Réalisation en guides d'ondes numériques stables d'un modèle acoustique réaliste pour la simulation en temps-réel d'instruments à vent. PhD thesis, Télécom ParisTech. https://theses.hal.science/tel-00456997
- Mignot, R., Hélie, T., Matignon, D. (2010a). Digital waveguide modeling for wind instruments: building a state-space representation based on the Webster-Lokshin model. IEEE Trans. Audio, Speech, Lang. Process. 18(4), 843-854. https://oatao.univ-toulouse.fr/3901/
- Mignot, R., Hélie, T., Matignon, D. (2010b). Acoustic modelling of a convex pipe adapted for digital waveguide simulation. DAFx-10, Graz. https://dafx.de/paper-archive/2010/DAFx10/MignotHelieMatignon_DAFx10_P14.pdf
- Smith, J. O. Physical Audio Signal Processing (online book), sections "Conical Acoustic Tubes" and "Cylinder with Conical Cap". https://ccrma.stanford.edu/~jos/pasp/Cylinder_Conical_Cap.html
- Välimäki, V., Karjalainen, M. (1994). Digital waveguide modeling of wind instrument bores constructed of truncated cones. Proc. ICMC 1994, Århus, 423-430.
- Välimäki, V., Karjalainen, M. (1994). Improving the Kelly-Lochbaum vocal tract model using conical tube sections and fractional delay filtering techniques. Proc. ICSLP 1994, Yokohama, 615-618. http://users.spa.aalto.fi/vpv/publications/icslp94.pdf
- van Walstijn, M., Smith, J. O. (1998). Use of truncated infinite impulse response (TIIR) filters in implementing efficient digital waveguide models of flared horns and piecewise conical bores with unstable one-pole filter elements. Proc. ISMA 1998, Leavenworth, 309-314. https://ccrma.stanford.edu/~jos/tiirts/tiirts.pdf
- van Walstijn, M. (2007). Wave-based simulation of wind instrument resonators. IEEE Signal Processing Magazine 24(2), 21-31. https://pureadmin.qub.ac.uk/ws/files/2151869/paper.pdf
- Wang, A. L., Smith, J. O. (1997). On fast FIR filters implemented as tail-canceling IIR filters. IEEE Trans. Signal Process. 45(6), 1415-1427.
