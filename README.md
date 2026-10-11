# Ride models

A quarter-car and a half-car driving over speed bumps, in plain MATLAB. Simulate the ride, score the comfort, watch it happen.

![Half-car on a bump](docs/images/halfcar_frame.png)

- **Quarter-car**: one wheel, one body, 6 states.
- **Half-car**: two axles, heave and pitch, 11 states. Braking tips the car forward and the model feels it.

Comfort is the ISO 2631-1 weighted RMS of the body acceleration, `a_w`.

## Try it

```matlab
setup
cfg = ride.config();                 % reads config/default.json
r   = ride.scenario.run(cfg);        % model, road and speed profile from the config
ride.core.comfort.a_w(r.out.z_B_ddot, r.P.DT)
ride.render.animate(r.P, r.road, r.out)
```

## Change anything in one place

Everything the examples use lives in `config/default.json`:

| Key | What |
| --- | --- |
| `model` | `halfcar` or `quartercar` |
| `road.bumps` | list of `start_m`, `height_m`, `length_m` |
| `profiles` | named speed profiles, `constant` or `dip` |
| `drive` | which profile to drive, and for how long |
| `compare` | profiles and duration for the comparison script |
| `render` | playback speed, frame rate, the moment `show_frame` captures, video file |

Overrides work from code too: `ride.config('model', 'quartercar', 'render.speed', 2)`. Pass a file name first to load your own config.

## Examples

Each script is a few lines on top of the config.

| Script | Does |
| --- | --- |
| `single_bump` | weighted RMS and the time-series charts |
| `show_frame` | one frame with header and charts, saved as `<model>_frame.png` |
| `animate_drive` | the animated drive |
| `compare_speed_profiles` | travel time and `a_w` for each profile in `compare` |

## Tests

```matlab
setup
run('tests/run_tests.m')
```

- Both models are replayed against reference runs from an independent implementation of the same equations.
- A flat road must give no acceleration, and a taller bump must be less comfortable.
- The Wk filter must reject a constant offset and weight 4 Hz above 0.1 Hz.
- Config overrides must work and speed profiles must behave.

## Simulink

`simulink/build_quartercar.m` builds the quarter-car as a Simulink model. `run('simulink/test_quartercar_simulink.m')` builds it for each reference case, simulates it with a fixed-step solver at 1 ms, and compares the body acceleration with the reference. The half-car model follows once this passes.

## Layout

```
ride-models-matlab
├── setup.m
├── config                   default.json
├── src/+ride
│   ├── load  simulate  root  config
│   ├── +scenario            speeds  build  run
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
├── simulink                 build_quartercar  road_velocity_input  test_quartercar_simulink
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
