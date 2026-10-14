# Getting started

## Install

Clone the repository and run `setup` once per MATLAB session. It adds `src` to the path.

```matlab
cd ride-models-matlab
setup
```

Installed from the `.mltbx` toolbox file, there is nothing to do: the path is set for you.

## Your first ride

```matlab
cfg = ride.config();             % settings from config/default.json
r   = ride.run(cfg);             % model + road + speed profile -> simulation + metrics
disp(r.metrics)                  % a_w, vdv, peak_acc, travel_time, mean_speed
ride.render.animate(r.P, r.road, r.out)
```

`r` holds everything:

| Field | Content |
| --- | --- |
| `r.model`, `r.P` | the vehicle and its parameters |
| `r.scenario`, `r.road` | the road scenario and its terrain |
| `r.speeds` | the speed at every time step |
| `r.out` | the simulation signals, see below |
| `r.metrics` | the scores you asked for |

## What a simulation returns

`r.out` is a struct of column vectors, one value per time step `P.DT`:

| Field | Meaning | Unit |
| --- | --- | --- |
| `t`, `s`, `v` | time, distance driven, speed | s, m, m/s |
| `z_B`, `z_B_ddot` | body heave and its acceleration | m, m/s^2 |
| `z_W` / `z_Wf`, `z_Wr` | wheel heave (quarter / half) | m |
| `phi`, `phi_ddot` | pitch angle and acceleration (half-car) | rad, rad/s^2 |

## Change what you run

Everything is in `config/default.json`: the model, the scenario, the speed profile and the metrics. Override from code with name and value pairs:

```matlab
r = ride.run(ride.config('model', 'quartercar', 'scenario', 'synthetic:02_two_bumps/s_l'));
```

Next: [concepts](concepts.md), [scenarios](scenarios.md), [profiles and metrics](profiles-and-metrics.md), [adding a model](add-a-model.md).
