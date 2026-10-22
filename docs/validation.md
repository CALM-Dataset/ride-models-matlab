# Validation

## Reference runs

`data/models/<model>/reference` holds six drives, three per model, computed by an independent Python implementation of the same equations:

| Model | Drive |
| --- | --- |
| Quarter-car | a 6 cm, 2 m bump at 6 m/s; a speed change between 3.5 and 8.5 m/s over a 5 cm, 3 m bump; two bumps (7 cm and 4 cm) at speeds between 3 and 8 m/s |
| Half-car | the same three roads and speed sequences |

Each file holds the road, the speed at every 20 ms step and the expected body heave acceleration, the wheel accelerations, the pitch acceleration (half-car) and `a_w`. The tests replay each drive with the model's simulate function and compare at every step the body heave acceleration, the wheel acceleration (quarter-car) and the pitch acceleration (half-car), and `a_w` over the whole drive. On MATLAB R2025b the largest difference, relative to the peak of the signal, is:

| | Body heave | Wheels | Pitch | `a_w` |
| --- | --- | --- | --- | --- |
| Quarter-car | 2.2e-16 to 2.3e-16 | 9.7e-16 to 1.1e-15 | | 1.0e-13 to 1.6e-13 |
| Half-car | 3.4e-16 to 8.0e-16 | | 5.2e-16 to 6.7e-16 | 1.2e-13 to 1.4e-13 |

The test tolerances are 1e-6 for the signals and 2 % for `a_w`. `examples/paper/fig4_validation.m` plots two of the drives against the reference.

The Simulink blocks are checked against the same runs (`test_quartercar_simulink`, `test_halfcar_simulink`). They agree to 1e-13 to 7e-12 on body heave, pitch and wheel accelerations, after the input-timing convention described in [simulink.md](simulink.md); their tolerance is 1e-9. These tests live in `simulink/`; `runtests('tests')` runs them when Simulink is installed, `tests/run_tests.m` does not.

What this shows: the MATLAB code, the Simulink blocks and the Python implementation compute the same thing from the same equations and parameters. It does not show that the equations or the parameters describe a real car; the reference was written from the same model description, not measured. The comparison with the car's own measurements is below.

## The CALM comfort study

The CALM comfort study was computed by the CALM Python environment, which exports, for every road and driver, the speed and the body acceleration at every step and the road heights of the measured roads. `examples/paper/replay_calm_profiles.m` drives this package's half-car with those speed profiles and compares. It reads the export folder in place (the folder with `comfort_profiles/` and `comfort_scores.csv`); the data are not part of the package.

On the study's export (1012 profiles: constant speed, MPC and RL on 540 synthetic drives; human, constant, MPC and RL on 472 measured-road drives):

| | Synthetic roads | Measured roads |
| --- | --- | --- |
| Largest step difference in body acceleration, relative to the peak | 0.31 % (median 0.018 %) | 2.9 % (median 0.011 %) |
| `a_w`, replay against the exported acceleration | median 6e-6, max 1.8e-4 | median 7e-6, max 3.2e-3 |
| `a_w`, replay against `comfort_scores.csv` | | median 8.6e-5, max 2.9e-3 (420 profiles) |

The exported speeds, accelerations and road heights are rounded (speeds to 0.001 km/h, accelerations to 1e-4 m/s^2, heights to 0.01 mm), which bounds how close the replay can get; the largest step difference, on one measured road, was not traced further. Synthetic roads are rebuilt from this package's catalog, so the agreement also confirms that the catalog's sizes and layout match the study.

## Against the measured car

The CALM export also holds, for each of the 105 recorded human drives on the measured roads, `a_w_imu`: the ISO 2631-1 weighted RMS of the vertical acceleration that the car's IMU measured on that drive. `examples/paper/compare_with_imu.m` replays the recorded speeds over the measured road heights with three vehicles and compares their `a_w` with the IMU. The error is $e = (a_{w,\text{sim}} - a_{w,\text{IMU}}) / a_{w,\text{IMU}}$.

| Model | Median $\lvert e\rvert$ | Median $e$ | Middle half of $e$ | Roads within 30 % | Spearman | Road pairs ordered alike |
| --- | --- | --- | --- | --- | --- | --- |
| Half-car, calibrated suspension | 16.9 % | +3.1 % | -11.8 to +17.2 % | 81 % | 0.52 | 69 % |
| Half-car, nominal suspension | 27.4 % | +16.5 % | -17.5 to +48.3 % | 51 % | 0.46 | 66 % |
| Quarter-car | 55.2 % | +53.6 % | +10.7 to +94.9 % | 36 % | 0.45 | 66 % |

For the calibrated half-car, by group:

| Roads | Number | Median $e$ | Median $\lvert e\rvert$ |
| --- | --- | --- | --- |
| Germany | 64 | +3.9 % | 17.7 % |
| Italy | 41 | +2.5 % | 12.4 % |
| Bump width below 2 m | 46 | +7.3 % | 12.8 % |
| Bump width 2 to 4.5 m | 34 | -0.4 % | 18.6 % |
| Bump width 4.5 m and more | 25 | -3.6 % | 26.2 % |
| Bump height below 40 mm | 28 | -7.8 % | 12.4 % |
| Bump height 40 mm and more | 77 | +8.8 % | 17.6 % |

What this says:

- With its calibrated suspension the half-car gets the level of comfort right: no systematic bias (median error +3 %), four roads in five within 30 % of the measurement. A single road can still be off by up to about 75 %.
- It ranks roads only moderately well. Of two roads, the model calls the less comfortable one correctly in 69 % of pairs (50 % would be chance). Comparisons between methods on the same road, as in the CALM study, are less exposed to this than comparisons between roads.
- The calibration matters: with the nominal suspension the half-car overestimates comfort loss by 16 % at the median, and the quarter-car, which has no pitch and the nominal damper, by 54 %.
- The error depends on the geometry: bumps of 40 mm and more are overestimated (+8.8 % at the median), lower ones underestimated (-7.8 %), and the spread of the error grows with the bump width. The data do not say which part of the model causes this.

Caveats: the measured value is one number per drive, not a signal, so this does not check the shape of the response in time or frequency. The calibration factors of the half-car may have been chosen against these same drives; if so, the calibrated row is an in-sample fit and the nominal row is the out-of-sample reference. The IMU sits on the body, not at a seat, and the measured roads are reconstructed from LiDAR along the wheel paths, so part of the error belongs to the road reconstruction rather than to the vehicle model.

## Invariants

The other tests check properties that hold for any correct implementation, without stored numbers:

- A car on a flat road does not accelerate or pitch.
- A taller bump gives a higher `a_w`.
- A sampled road profile rides like the analytic bump it was sampled from (`a_w` within 2 %).
- The Wk filter rejects a constant offset, weights 4 Hz above 0.1 Hz, and matches the tabulated ISO 2631-1 gains at 1, 4, 6.3 and 8 Hz within 0.1 dB.
- Metrics stop at the end of the road, the travel time is distance over speed, and a constant drive has its speed as mean speed.
- Every synthetic scenario has one feature per code, no overlaps and the catalog's speed; trimming of measured profiles keeps the labelled bump on level ground.
- Every profile type gives the speeds it promises: constant is constant, a dip never speeds up, a ramp climbs, the reactive driver stays within its limits, slows more for steeper bumps and also slows for holes, and recorded profiles replay and resample their samples.
- Scenarios, profiles and metrics registered at run time work in `ride.run` together; a registered model is listed and validated; a model folder on the path is found without registration, passes `ride.models.validate` and runs in `ride.run`.

## Limits

- **Planar models.** The quarter-car has heave only; the half-car adds pitch. There is no roll, no left-right difference, no seat or occupant model, and the tyre is a point contact with a linear spring and damper that never leaves the road.
- **Parameters.** One vehicle (sources in [model-equations.md](model-equations.md)). The half-car suspension is calibrated (springs 1.06 times, dampers 0.16 times the nominal values); the quarter-car is not. Against the IMU of 105 measured drives the calibrated half-car is within 17 % at the median and the quarter-car overestimates `a_w` by about half (see above).
- **Road input.** Raised-cosine features are exact. Measured profiles are linearly interpolated between samples 5 cm apart, and their slope comes from finite differences, so features shorter than a few samples are smoothed.
- **Output rate.** The dynamics run at 1 ms, but the reported accelerations, and therefore `a_w` and VDV, are sampled every 20 ms (50 Hz). Content above 25 Hz is aliased. Short features at high speed excite such frequencies, for example the 0.3 m minor pothole; the irregular course of `a_w` over speed for the short potholes in `examples/paper/fig2_aw_vs_speed.m` is consistent with this, but was not traced to it.
- **Trip metrics.** `a_w` is the RMS over the whole trip, lead-in included, so it depends on how much flat road is around the features and on the trip time. Compare runs on the same scenario. `travel_time` ends when the rear axle (the wheel, for the quarter-car) has left the last feature, or is 3 m past the end of a measured profile.
- **Speed.** The speed profile is prescribed. There is no longitudinal tyre model and no driveline; acceleration enters only through the half-car's load transfer.
- **Releases.** Tested on MATLAB R2025b with Simulink and the Signal Processing Toolbox on macOS. Without the Signal Processing Toolbox the Wk filter upsamples with `pchip` instead of `resample`, and `a_w` differs slightly; the reference comparison of `a_w` was only run with the toolbox installed.
