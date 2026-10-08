# Half-car ride model

MATLAB implementation with scene rendering and time-series plots.

11 states, nonlinear spring and damper, road input at both axles, load transfer from longitudinal acceleration, ISO 2631-1 Wk weighted RMS (`a_w`).

## Quick start

```matlab
addpath(pwd)
P = halfcar.params.load();
road = halfcar.road.bumps([20 0.06 2.0]);
speeds = 6 * ones(700, 1);
out = halfcar.sim.simulate(P, road, speeds);
aw = halfcar.comfort.a_w(out.z_B_ddot, P.DT)
render.animate(P, road, out, 'speed', 1)
```

`road.bumps` rows are `[start_m height_m length_m]`, raised-cosine bumps. `speeds` has one value per `P.DT`.

## Layout

```
+halfcar                 model, used as halfcar.<package>.<function>
  +params                load.m
  +dynamics              spring_nonlin.m  damper.m  ode_rhs.m  rk4_step.m
  +road                  bumps.m  height.m  height_dot.m
  +sim                   simulate.m
  +comfort               wk_weight.m  rms.m  a_w.m
+render                  drawing, used as render.<package>.<function>
  +scene                 geometry.m  colors.m  style.m  rgb.m  spring_xy.m  damper_xy.m  draw_wheel.m  draw_frame.m  hud_create.m  hud_update.m
  +plots                 signals.m
  animate.m
examples                 single_bump.m  animate_drive.m  compare_speed_profiles.m
tests                    run_tests.m and the individual checks
data                     params.json and the reference runs in data/reference
```

## Parameters

`data/params.json` holds the vehicle: body, front and rear axle, and the integration step. The axles use the calibrated suspension (k_S x1.06, D x0.16); the nominal values are under `nominal`.

## Tests

```matlab
run('tests/run_tests.m')
```

- `test_reference`: body and pitch acceleration and `a_w` against the reference runs in `data/reference`, computed with an independent implementation of the same equations
- `test_equilibrium_and_scaling`: flat road gives no acceleration, taller bump gives larger `a_w`
- `test_wk_weighting`: constant offset rejected, 4 Hz weighted above 0.1 Hz

## Requirements

MATLAB R2016b or newer. `resample` from the Signal Processing Toolbox is used for Wk when available.

## Citation

Cite the thesis in `CITATION.cff`: Mohammed El Said Azab Abdelazim, *Comfort-Aware Speed Planning over Road Anomalies: A Reinforcement-Learning Approach*, Technische Universität Berlin, 2026.

## Licence

MIT
