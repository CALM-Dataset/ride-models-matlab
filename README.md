# Ride models

How much does a car shake over a speed bump, and does driving slower help? Quarter-car and half-car models in MATLAB, with real and synthetic roads, comfort scores and an animated view.

![Half-car on a bump](docs/images/halfcar_frame.png)

```matlab
setup
r = ride.run(ride.config());      % half-car, a medium bump, a dip before it
disp(r.metrics)                   % a_w, vdv, peak_acc, travel_time, mean_speed
ride.render.animate(r.P, r.road, r.out)
```

## What is in it

| | |
| --- | --- |
| **Models** | quarter-car (6 states) and half-car with pitch (11 states) |
| **Scenarios** | 185 synthetic roads from a size-code catalog, 159 measured roads from Hugging Face, your own files or functions |
| **Speed profiles** | constant, reactive driver, recorded MPC and human drives, dip before the bump, ramp, table, or any function |
| **Metrics** | ISO 2631-1 weighted RMS `a_w`, `vdv`, peaks, trip time, pitch and suspension travel |
| **Views** | animated scene with charts, one-frame export, video |

Everything is a plug-in. A new model, scenario, speed profile or metric is one folder or one function, and the whole tool works with it.

## Pick what to run

All in `config/default.json`, or as overrides:

```matlab
r = ride.run(ride.config('model', 'quartercar', 'scenario', 'synthetic:02_two_bumps/s_l'));
r = ride.run(ride.config('scenario', 'real:germany/eval/stuttgart_sb01'));   % after ride.scenarios.real.sync('germany/eval')
```

## Add your own

```matlab
ride.scenarios.register('washboard', @() ride.scenarios.make('washboard', ...
    ride.core.terrain.from_function(@(s) 0.03 * sin(2 * pi * s / 5), 60, 0.02)));
ride.metrics.register('peak_wheel_acc', @(out, P, sc) max(abs(out.z_W_ddot)));
r = ride.run(ride.config('model', 'quartercar', 'scenario', 'registered:washboard', 'metrics', {'a_w', 'peak_wheel_acc'}));
```

## Guides

| | |
| --- | --- |
| [Getting started](docs/getting-started.md) | install, first run, what a simulation returns |
| [Concepts](docs/concepts.md) | models, comfort, symbols, units |
| [Scenarios](docs/scenarios.md) | synthetic names, Hugging Face roads, your own roads |
| [Profiles and metrics](docs/profiles-and-metrics.md) | built-ins and how to add one |
| [Adding a model](docs/add-a-model.md) | the folder contract and the check |
| [Packaging](docs/packaging.md) | build the MATLAB toolbox, Simulink |

## Tests

```matlab
setup
run('tests/run_tests.m')
```

The models are replayed against reference runs from an independent implementation of the same equations. The scenario, profile, metric and model layers are checked on invariants, not stored numbers.

## Layout

```
setup.m  config/default.json
src/+ride
├── run  config  load  simulate  root
├── +core         terrain  comfort  suspension
├── +models       halfcar  quartercar  (+ list get register validate)
├── +scenarios    synthetic  real  (+ get list register make from_file)
├── +profiles     builtin  (+ speeds list register)
├── +metrics      builtin  (+ evaluate list register)
└── +render       scene  plots  (+ animate frame_figure)
data/models  data/scenarios  docs  examples  simulink  tests  toolbox
```

## Requirements

MATLAB R2016b or newer. Packaging as a toolbox needs R2019b. The Signal Processing Toolbox `resample` is used for the Wk filter when present.

## Citation

Mohammed El Said Azab Abdelazim, *Comfort-Aware Speed Planning over Road Anomalies: A Reinforcement-Learning Approach*, Technische Universität Berlin, 2026. See `CITATION.cff`.

## Licence

MIT
