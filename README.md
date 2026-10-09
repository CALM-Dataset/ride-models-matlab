# Ride models

Quarter-car and half-car ride models in MATLAB, with scene rendering and time-series charts.

- quarter-car: 6 states, nonlinear spring and damper, tyre stiffness and damping
- half-car: 11 states, the same elements on two axles, pitch, and load transfer from longitudinal acceleration
- ISO 2631-1 Wk weighted RMS (`a_w`) of the body acceleration

## Quick start

```matlab
addpath(pwd)
model = 'halfcar';
P = ride.load(model);
road = terrain.bumps([20 0.06 2.0]);
speeds = 6 * ones(700, 1);
out = ride.simulate(model, P, road, speeds);
aw = comfort.a_w(out.z_B_ddot, P.DT)
render.animate(P, road, out)
```

Use `model = 'quartercar'` for the quarter-car. `terrain.bumps` rows are `[start_m height_m length_m]`, raised-cosine bumps. `speeds` has one value per `P.DT`.

## Layout

```
+terrain                 bumps.m  height.m  height_dot.m
+comfort                 wk_weight.m  rms.m  a_w.m
+suspension              spring_nonlin.m  damper.m
+halfcar                 +params  +dynamics  +sim
+quartercar              +params  +dynamics  +sim
+ride                    load.m  simulate.m
+render
  +scene                 geometry  colors  style  rgb  spring_xy  damper_xy  draw_wheel  draw_background  hud_create  hud_update
  +halfcar               frame.m
  +quartercar            frame.m
  +plots                 signals.m
  frame_figure.m  animate.m
examples                 single_bump  show_frame  animate_drive  compare_speed_profiles
tests                    run_tests.m and the individual checks
data
  halfcar                params.json  reference
  quartercar             params.json  reference
```

## Parameters

`data/<model>/params.json` holds the vehicle and the integration step. The half-car axles use the calibrated suspension (k_S x1.06, D x0.16); the nominal values are under `nominal`.

## Tests

```matlab
run('tests/run_tests.m')
```

- `test_halfcar_reference`, `test_quartercar_reference`: accelerations and `a_w` against the reference runs in `data/<model>/reference`, computed with an independent implementation of the same equations
- `test_halfcar_equilibrium_and_scaling`, `test_quartercar_equilibrium_and_scaling`: flat road gives no acceleration, taller bump gives larger `a_w`
- `test_wk_weighting`: constant offset rejected, 4 Hz weighted above 0.1 Hz

## Examples

Set `model` at the top of each script.

- `single_bump`: weighted RMS and the time-series charts
- `show_frame`: one frame with header and charts, saved as `<model>_frame.png`
- `animate_drive`: animation of a drive with a dip before the bump
- `compare_speed_profiles`: travel time and weighted RMS for two speed profiles

## Requirements

MATLAB R2016b or newer. `resample` from the Signal Processing Toolbox is used for Wk when available.

## Citation

Cite the thesis in `CITATION.cff`: Mohammed El Said Azab Abdelazim, *Comfort-Aware Speed Planning over Road Anomalies: A Reinforcement-Learning Approach*, Technische Universität Berlin, 2026.

## Licence

MIT
