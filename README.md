# Ride models

A quarter-car and a half-car driving over speed bumps, in plain MATLAB. Simulate the ride, score the comfort, watch it happen.

![Half-car on a bump](docs/images/halfcar_frame.png)

- **Quarter-car**: one wheel, one body, 6 states.
- **Half-car**: two axles, heave and pitch, 11 states. Braking tips the car forward and the model feels it.

Comfort is the ISO 2631-1 weighted RMS of the body acceleration, `a_w`.

## Try it

```matlab
setup
model = 'halfcar';                                % or 'quartercar'
P     = ride.load(model);
road  = ride.core.terrain.bumps([20 0.06 2.0]);   % start, height, length in m
v     = 6 * ones(700, 1);                         % speed per 20 ms step in m/s
out   = ride.simulate(model, P, road, v);
ride.core.comfort.a_w(out.z_B_ddot, P.DT)
ride.render.animate(P, road, out)
```

The speed profile is yours to choose: constant, a dip before the bump, or whatever a planner recommends. The model returns the ride.

## Examples

Set `model` at the top of each script.

| Script | Does |
| --- | --- |
| `single_bump` | weighted RMS and the time-series charts |
| `show_frame` | one frame with header and charts, saved as `<model>_frame.png` |
| `animate_drive` | a drive with a dip before the bump |
| `compare_speed_profiles` | travel time and `a_w` for two speed profiles |

## Tests

```matlab
setup
run('tests/run_tests.m')
```

- Both models are replayed against reference runs from an independent implementation of the same equations.
- A flat road must give no acceleration, and a taller bump must be less comfortable.
- The Wk filter must reject a constant offset and weight 4 Hz above 0.1 Hz.

## Layout

```
ride-models-matlab
├── setup.m
├── src/+ride
│   ├── load  simulate  root
│   ├── +core
│   │   ├── +terrain         bumps  height  height_dot
│   │   ├── +comfort         wk_weight  rms  a_w
│   │   └── +suspension      spring_nonlin  damper  assemble  damper_coefficients
│   ├── +models
│   │   ├── +halfcar         +params  +dynamics  +sim
│   │   └── +quartercar      +params  +dynamics  +sim
│   └── +render
│       ├── +scene           geometry  colors  style  draw_wheel  draw_background  hud_create  ...
│       ├── +plots           signals
│       ├── +halfcar         frame
│       ├── +quartercar      frame
│       └── frame_figure  animate
├── data/models
│   ├── halfcar              params.json  reference/
│   └── quartercar           params.json  reference/
├── tests                    run_tests.m  core/  models/
├── examples
└── docs/images
```

## Data

`params.json` is grouped by role:

```
integration   dt_s  dt_sim_s  substeps
body          m_B  (half-car: inertia, axle distances, load-transfer heights)
axle(s)       wheel_mass
              tyre     k_T  c_T
              spring   k_S  dz_S_stat  dz_cmp  dz_rbd  f1_cmp  f2_cmp  f1_rbd  f2_rbd  F_max
              damper   D  A  v_d  v_z
```

The half-car has `axles.front` and `axles.rear` with the calibrated suspension (k_S x1.06, D x0.16), plus the nominal values under `nominal`.

Reference runs in `reference/` follow the same idea:

```
name
road       bumps      start_m  height_m  length_m
drive      dt_s  speed_mps
expected   body       heave_acc_mps2  (pitch_acc_radps2 for the half-car)
           wheels     front_acc_mps2  rear_acc_mps2  (acc_mps2 for the quarter-car)
           weighted_rms_mps2
```

## Requirements

MATLAB R2016b or newer. The Signal Processing Toolbox `resample` is used for Wk when present.

## Citation

Mohammed El Said Azab Abdelazim, *Comfort-Aware Speed Planning over Road Anomalies: A Reinforcement-Learning Approach*, Technische Universität Berlin, 2026. See `CITATION.cff`.

## Licence

MIT
