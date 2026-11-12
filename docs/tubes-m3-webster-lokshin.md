# Tube model M3: Webster-Lokshin waveguides (#66, plan)

Status: **plan for later work**. Background, the other methods and the
literature: `docs/conical-tubes.md` (#64, branch `feature/64-conical-tubes`).

## Why

The tube model of #64 (method M2) is exact for lossless conical tubes. Its
wall losses are an approximation: half of the viscothermal loss of a tube is
applied to the waves entering and leaving it at each end. M3 describes every
tube piece with the Webster-Lokshin equation. That equation is the horn
equation with:

- the viscothermal boundary-layer loss (Lokshin, a derivative of order 3/2
  in time),
- the curvature of the profile.

Losses and taper are then treated together, in the segments and in the
junctions. Mignot, Hélie and Matignon showed how to arrange the resulting
transfer functions so that every part is stable by construction, also for a
chain of N pieces.

## Model

- Webster-Lokshin equation for the quasi-plane pressure in a pipe with
  radius R(z): curvature term R''/R and loss coefficient depending on R
  (Hélie, Mignot, Matignon 2007; Mignot, Hélie, Matignon 2010a).
- One piece with constant curvature and loss coefficient: the solution
  consists of two delays and transfer functions with an irrational, but
  stable, part. The standard form chooses the internal reflections so that
  all sub-systems are stable (Mignot 2009, chapter on N pieces).
- Diffusive parts (fractional derivatives, square roots of s):
  approximated by sums of first-order filters with fitted poles (diffusive
  representation, Hélie and Matignon). These are stable and cheap.
- Conical pieces (curvature 0) without losses must reproduce M2 exactly:
  the first check of the implementation.

## Steps

1. One lossless cone, then one lossy cylinder: transfer functions against
   the frequency-domain reference `tuberef` of `tests/voxtest_tubes.m`.
2. Approximation of the diffusive parts; error over 0-10 kHz.
3. Chain of pieces with the interface of M2: plane-wave pressure at the
   tube ends, glottis end, radiation and output of the stairs model, combi
   coupling (`ctim2`, `coneprepare`/`conestep` as the contract).
4. Tests: accuracy (formants, bandwidths) against `tuberef` with losses,
   stability for 2 s and random geometries, comparison with M2 for all
   vowels.
5. Decide whether M3 replaces the losses of M2 or becomes a selectable
   variant.

## Effort

Large. The derivations are in the papers. The fitting of the diffusive
parts and the stability conditions of the standard form need careful work
and tests.

## References

- Hélie, T., Mignot, R., Matignon, D. (2007). Waveguide modeling of lossy flared acoustic pipes: derivation of a Kelly-Lochbaum structure for real-time simulations. IEEE WASPAA, 267-270.
- Mignot, R., Hélie, T., Matignon, D. (2008). Stable realization of a delay system modeling a convergent acoustic cone. MED'08, Ajaccio, 1574-1579. https://hal.science/hal-01106362
- Mignot, R. (2009). Réalisation en guides d'ondes numériques stables d'un modèle acoustique réaliste pour la simulation en temps-réel d'instruments à vent. PhD thesis, Télécom ParisTech. https://theses.hal.science/tel-00456997
- Mignot, R., Hélie, T., Matignon, D. (2010a). Digital waveguide modeling for wind instruments: building a state-space representation based on the Webster-Lokshin model. IEEE Trans. Audio, Speech, Lang. Process. 18(4), 843-854. https://oatao.univ-toulouse.fr/3901/
- Mignot, R., Hélie, T., Matignon, D. (2010b). Acoustic modelling of a convex pipe adapted for digital waveguide simulation. DAFx-10, Graz. https://dafx.de/paper-archive/2010/DAFx10/MignotHelieMatignon_DAFx10_P14.pdf
- Hélie, T., Matignon, D. (2006). Diffusive representations for the analysis and simulation of flared acoustic pipes with visco-thermal losses. Math. Models Methods Appl. Sci. 16(4), 503-536.
