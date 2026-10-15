# Speed profiles and metrics

## Speed profiles

A profile is a struct with a `type` and its parameters. `ride.profiles.speeds(profile, dt, n, scenario)` returns the speed at `n` steps. In the config, profiles live under `profiles` and `drive.profile` picks one. Setting `speed_mps` to `"scenario"` uses the scenario's suggested speed.

| Type | Parameters |
| --- | --- |
| `constant` | `speed_mps` |
| `dip` | `speed_mps`, `depth_mps`, `center_s`, `width_s` |
| `dip_at_bump` | `speed_mps`, `depth_mps`, `lead_m`, `width_s`: a dip centred `lead_m` before the first feature |
| `ramp` | `from_mps`, `to_mps`, `start_s`, `duration_s` |
| `reactive` | `speed_mps`, `v_min_mps`, `preview_m`, `steep_full_slow`, `hole_severity`, `brake_margin`, `a_brake`, `a_accel`: a rule-based driver that brakes early enough to cross each bump at a speed set by its steepness, then speeds up again |
| `mpc` | recorded speeds of the model predictive planner for the scenario |
| `human` | recorded speeds of the human drive on the scenario |
| `recorded` | `source`: the same for any source in a profile file |
| `table` | `t_s`, `v_mps`: interpolated points, for a recommended speed from a planner |
| `handle` | `fn`: a function of time, from code only |

`mpc`, `human` and `recorded` replay a profile file. Pass one with the `file` field, or let the profile library find the file of the scenario by name: `ride.profiles.library.sync('stuttgart_sb01')` downloads `profiles/<scenario>.json` from the scenarios dataset into the cache, and `ride.profiles.library.list()` shows what is cached. Recorded profiles exist for the real scenarios only. A file looks like this, with the speed at every `dt_s`:

```json
{"name": "stuttgart_sb01", "dt_s": 0.02,
 "sources": {"mpc": {"v_mps": [8.3, 8.3, 8.2]}, "human": {"v_mps": [7.1, 7.2, 7.2]}}}
```

A profile shorter than the drive holds its last speed, and one with a different time step is resampled. The reactive driver is deterministic, runs on any scenario, and matches the rule-based baseline of the original study speed for speed.

Add a type for the session:

```matlab
ride.profiles.register('stop_and_go', @(p, dt, n, sc) ...);   % returns n speeds
```

To keep one, add a function `+ride/+profiles/+builtin/<name>.m` with the signature `v = name(profile, dt, n, sc)`.

## Metrics

A metric is `value = f(out, P, scenario)`. All built-ins score the trip up to the end of the road.

| Metric | Meaning |
| --- | --- |
| `a_w` | Wk-weighted RMS body acceleration |
| `vdv` | vibration dose value |
| `peak_a_w`, `peak_acc` | largest weighted / raw body acceleration |
| `rms_acc` | unweighted RMS body acceleration |
| `travel_time`, `mean_speed`, `min_speed` | trip time and speeds |
| `pitch_rms` | RMS pitch angle, half-car only |
| `susp_travel_peak` | largest suspension deflection |

```matlab
ride.metrics.list()
ride.metrics.evaluate(r.out, r.P, r.scenario, {'a_w', 'travel_time'})
```

Add your own, for anything the simulation signals can tell you:

```matlab
ride.metrics.register('tyre_load_peak', @(out, P, sc) max(abs(out.z_W_ddot)) * 50);
```

Metrics set in the config under `metrics` are computed by `ride.run`. A registered metric works there too, as long as it is registered before the run.
