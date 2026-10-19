# Getting started

You need MATLAB. Simulink is only needed for the Simulink blocks. The package was verified on R2025b.

## Install

Either install the toolbox file (`ride-models-<version>.mltbx`, double-click it in MATLAB), or clone the repository and run `setup` once per MATLAB session:

```matlab
cd ride-models-matlab
setup
```

`setup` puts `src` and `simulink` on the path. With the toolbox installed there is nothing to do.

## Your first ride

```matlab
r = ride.run();                            % settings from config/default.json
disp(r.metrics)                            % a_w, vdv, peak_acc, travel_time, mean_speed
ride.render.animate(r.P, r.road, r.out)    % watch it
```

This drives the half-car over a medium speed bump, slowing down before it. Everything above works offline: the synthetic roads are built on your machine.

The same walk-through with plots is in `examples/live/getting_started.mlx`.

`r` holds everything:

| Field | Content |
| --- | --- |
| `r.model`, `r.P` | the vehicle and its parameters |
| `r.scenario`, `r.road` | the road scenario and its terrain |
| `r.speeds` | the speed at every time step |
| `r.out` | the simulation signals, see below |
| `r.metrics` | the scores you asked for |

## What a simulation returns

`r.out` is a struct of column vectors, one value per time step `P.DT` (20 ms):

| Field | Meaning | Unit |
| --- | --- | --- |
| `t`, `s`, `v` | time, distance driven, speed | s, m, m/s |
| `z_B`, `z_B_ddot` | body heave and its acceleration | m, m/s^2 |
| `z_W` / `z_Wf`, `z_Wr` | wheel heave (quarter / half) | m |
| `phi`, `phi_ddot` | pitch angle and acceleration (half-car) | rad, rad/s^2 |

## Change what you run

The model, the scenario, the speed profile and the metrics are set in `config/default.json`. Override them with name and value pairs:

```matlab
r = ride.run(ride.config('model', 'quartercar', 'scenario', 'synthetic:s_l', 'drive.profile', 'constant'));
```

| Setting | Values |
| --- | --- |
| `model` | `halfcar`, `quartercar` (`ride.models.list()`) |
| `scenario` | `synthetic:<code>` (`ride.scenarios.synthetic.list()`), `real:<folder>/<name>`, `file:<path>`, `registered:<name>` |
| `drive.profile` | a name under `profiles` in the config: `constant`, `dip`, `reactive`, `mpc`, `human` |
| `drive.duration_s` | `"auto"` (until 5 m past the road) or seconds |
| `metrics` | names from `ride.metrics.list()` |

A frame for a report: `examples/show_frame.m` writes `figures/<model>_frame.png`. A video: `ride.render.animate(r.P, r.road, r.out, 'video', 'drive.mp4')`.

## Measured roads

The 159 measured roads are in a private Hugging Face dataset, `CALM-Dataset/CALM-Scenarios`. With an account that has access, create an access token on huggingface.co and set it in MATLAB:

```matlab
setenv('HF_TOKEN', 'hf_...')
ride.scenarios.real.sync('germany/eval')
r = ride.run(ride.config('scenario', 'real:germany/eval/stuttgart_sb01'));
```

Without the token you get an error that says so; nothing else needs the network. The recorded MPC and human drives for these roads (the `mpc` and `human` profiles) are not in the dataset yet; until they are, pass a profile file in the profile's `file` field.

Next: [concepts](concepts.md), [scenarios](scenarios.md), [profiles and metrics](profiles-and-metrics.md), [adding a model](add-a-model.md), [Simulink](simulink.md).
