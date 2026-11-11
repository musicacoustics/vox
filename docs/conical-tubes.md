# Conical segments in the time domain without instability (#64)

Research notes for the tube model of VOX. Status: **research in progress**.

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

(to be filled in)

## 2. Interface of the stairs model

(to be filled in)

## 3. Why conical segments become unstable

(to be filled in)

## 4. Methods in the literature

(to be filled in)

## 5. Recommendation

(to be filled in)

## References

(to be filled in)
