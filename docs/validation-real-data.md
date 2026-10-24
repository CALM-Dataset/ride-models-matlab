# Against the recorded car

[validation.md](validation.md) shows that the code computes what the equations say. This page asks whether the equations describe the car: the simulation is driven with the speed of each recorded drive over the road of that drive, and compared with what the car's IMU measured.

## Data

The CALM recordings (CALM-Germany and CALM-Italy `sequences`) hold, for every drive window around a labelled bump, the car pose, the excitation reconstructed under each wheel, the raw IMU export and a `meta.yaml`. The CALM-Scenarios dataset holds the trimmed road profile of each scenario and the `split.yaml` of the study. Both are gated research data: they are read in place and are not part of the package. All 159 scenarios have a recording. 54 carry a low-confidence flag and are reported separately; the other 105 are the usable roads that the results below refer to, 91 of them in the study's training split and 14 in its evaluation split. The RL policy never saw the evaluation roads, so below they are called held out.

## Running it

```matlab
% copy examples/validation/paths.example.json and fill in your folders
results = run_real_data('my_paths.json');
results = run_real_data('my_paths.json', 'reuse', true);   % redraw only
```

The script writes `results.csv` (one row per road), `summary.csv`, `summary.tex`, `results.mat` and the figures below to `figures/real_data`. Three more scripts build on it:

| Script | Writes |
| --- | --- |
| `analyse_real_data(config)` | `geometry.csv`, `spectra.csv` and `real_spectra`: the error by bump size and the comparison in frequency |
| `check_calibration(config)` | `calibration.csv` and `calibration`: the error over a grid of suspension factors, about 10 minutes |
| `paper_real_data(config)` | three summary figures in `figures/paper`, see [figures.md](figures.md) |

The building blocks are in `ride.validation`:

| Function | Does |
| --- | --- |
| `load_recording(folder)` | distance, speed on the 20 ms grid, vertical IMU acceleration, wheel tracks and meta of one window |
| `window_road(source, rec, scenario)` | the road under the window: the scenario profile, or a raw wheel track |
| `compare(rec, scenario)` | simulates and returns `a_w` of both, the time-domain measures and the checks |
| `find_windows`, `find_scenarios` | the recordings and the scenario list with splits |

`tests/core/test_validation.m` builds a synthetic window in the same file format, with a known speed, offset and IMU signal, and checks the loader and the comparison on it.

## Method

Distance comes from the front-left wheel track, interpolated onto the pose timestamps. Speed is its Savitzky-Golay derivative (window 51, order 3, 20 ms), the same as in the CALM environment, with negative values set to zero.

The measured signal is the vertical IMU axis with its mean removed, cut to the time span of the poses. Its `a_w` is the Wk-weighted RMS at the IMU's own rate of 250 Hz.

The simulated signal is the body heave acceleration of the calibrated half-car, driven over the scenario road at the recorded speeds and sampled at 50 Hz.

The error of one road is $e = (a_{w,\text{sim}} - a_{w,\text{IMU}}) / a_{w,\text{IMU}}$.

For the timing, both signals are low-passed at 10 Hz (Butterworth, zero phase). The lag between them is the shift within ±0.5 s that maximises their cross-correlation, positive when the measurement comes later. Around the bump, from 0.5 s before the crossing to 1.5 s after, we also compute the correlation and the ratio of the peaks.

## Checks on the data

| Check | Result |
| --- | --- |
| Measured `a_w` against the study's `a_w_imu` | equal within 0.0008 m/s² on all 105 roads |
| Derived speed against the staged human profile | within 5e-5 m/s |
| Not-shifted replay against the study's simulated `a_w` | median 0.15 %, largest 6.8 % |
| IMU axes | gravity on the vertical axis at 9.70 to 9.83 m/s²; horizontal mean up to 1.55 m/s² (tilt or braking, about 1 % on the amplitude) |
| IMU clock | 250 Hz, first sample 0 to 4 ms after the first pose |
| Bump position | labelled bump and pose distance agree to 0.008 m at the median |

## Alignment

The scenario profiles are trimmed around the bump, and `meta.trim.offset_m` says by how much. The original replay of the CALM study ignored that offset, so on the 37 trimmed usable roads the simulated bump arrived at the wrong place. Shifting the road by the offset puts the two in step:

| 37 trimmed roads | Not shifted | Aligned |
| --- | --- | --- |
| Median lag | 0.22 s | 0.04 s |
| Median correlation around the bump | 0.52 | 0.66 |
| Median $\lvert e\rvert$ | 17.3 % | 13.1 % |

The level of `a_w` changes less than the timing: the aligned road gives the closer `a_w` on 18 of the 37. Everything below is aligned unless stated.

## Results

All 105 roads:

| Variant | Median $\lvert e\rvert$ | Median $e$ | Middle half of $e$ | Within 10 / 20 / 30 % | Pearson | Spearman |
| --- | --- | --- | --- | --- | --- | --- |
| Half-car, calibrated, aligned | 15.8 % | +3.1 % | -11.7 to +17.3 % | 32 / 63 / 80 % | 0.56 | 0.53 |
| Half-car, calibrated, not shifted | 17.1 % | +3.2 % | -11.7 to +17.3 % | 32 / 63 / 81 % | 0.54 | 0.53 |
| Half-car, nominal suspension | 30.5 % | +15.1 % | -18.1 to +54.3 % | 11 / 34 / 50 % | 0.42 | 0.46 |
| Quarter-car | 53.9 % | +52.7 % | +9.8 to +96.5 % | 16 / 25 / 37 % | 0.43 | 0.45 |
| Half-car on the raw front-left track | 144 % | +144 % | +96 to +207 % | 0 / 1 / 3 % | 0.49 | 0.57 |
| Half-car on the mean of the raw front tracks | 135 % | +135 % | +86 to +213 % | 1 / 1 / 2 % | 0.47 | 0.54 |

By group, calibrated half-car, aligned:

| Roads | Number | Median $\lvert e\rvert$ | Median $e$ | Within 30 % |
| --- | --- | --- | --- | --- |
| Paper training | 91 | 17.1 % | +3.2 % | 79 % |
| Paper evaluation (held out) | 14 | 12.1 % | -4.4 % | 86 % |
| Germany | 64 | 17.7 % | +4.0 % | 75 % |
| Italy | 41 | 11.7 % | +1.8 % | 88 % |
| Low confidence (not among the 105) | 54 | 23.5 % | -0.8 % | 61 % |


In time, around the bump, the median correlation is 0.69 (middle half 0.53 to 0.79) and the median peak ratio 1.00. Split by distance from the bump, the Wk-weighted RMS ratio of simulation to measurement is 1.05 near the bump (middle half 0.90 to 1.17) and 0.95 away from it (0.73 to 1.20). The error shows no trend with mean speed (correlation 0.02).

By bump size, from the scenario profile:

| Roads | Number | Median $e$ | Median $\lvert e\rvert$ | Within 30 % |
| --- | --- | --- | --- | --- |
| Bump width below 2 m | 46 | +7.7 % | 12.4 % | 96 % |
| Bump width 2 to 4.5 m | 34 | +0.2 % | 18.7 % | 71 % |
| Bump width 4.5 m and more | 25 | -6.7 % | 26.0 % | 64 % |
| Bump height below 40 mm | 25 | -7.7 % | 12.4 % | 88 % |
| Bump height 40 mm and more | 80 | +7.7 % | 17.6 % | 78 % |

Short and high bumps are overestimated, long and low ones underestimated, and the spread grows with the width.

The largest errors have clear causes. On the worst road (+104 %) the car crossed fast and the simulated suspension hits its bump stop. On a slow drive with a short window (+77 %) the bump dominates the RMS. On a road where the model is far too low (-71 %) the IMU shows sharp spikes that are not in the smooth reconstructed road.

## In frequency

The model puts about four times the measured power into its body mode near 1.2 Hz, and only half to two thirds of the measured power into 2 to 20 Hz. Per road, the median RMS ratio of model to IMU is 1.44 from 0.3 to 2 Hz, 0.78 from 2 to 8 Hz and 0.82 from 8 to 20 Hz. The Wk weighting gives most weight to 4 to 8 Hz, so in `a_w` the two errors mostly cancel. The model gets `a_w` right partly because its body mode is too lightly damped, which makes up for the content above 2 Hz that the smooth scenario road does not have.

## Calibration check

The calibrated suspension scales the nominal springs by 1.06 and the dampers by 0.16. `check_calibration` repeats the comparison for springs 0.9 to 1.3 and dampers 0.08 to 1.0 times nominal, chooses on the 91 training roads and scores on the 14 held-out roads:

| Suspension | Training median $\lvert e\rvert$ | Held-out median $\lvert e\rvert$ | All 105 | Within 30 % |
| --- | --- | --- | --- | --- |
| Calibrated (springs 1.06, dampers 0.16) | 17.1 % | 12.1 % | 15.8 % | 80 % |
| Best on training (springs 1.00, dampers 0.20) | 13.4 % | 8.0 % | 12.7 % | 77 % |
| Nominal (1.0, 1.0) | 27.3 % | 40.1 % | 30.5 % | 50 % |

Settings with dampers from 0.16 to 0.25 and springs from 0.9 to 1.15 all land within a few points of the best, on both sets of roads. The calibrated values are not the best on these roads once the trim offset is applied. We do not know whether they were fitted on these drives without the offset. In any case the held-out roads do no worse than the training roads. The better setting gains 2 to 4 points, about as much as neighbouring cells differ, so it was not adopted and the parameter files are unchanged.

## What this says

The calibrated half-car gets the level of comfort right. There is no bias to speak of (median +3 %), four roads in five are within 30 %, and the held-out roads do as well as the training roads. A single road can still be off by up to about 100 %.

It ranks roads less well (Spearman 0.53). Comparing speed profiles on the same road, as in the CALM study, is less affected by this than comparing one road with another.

Both the calibration and the pitch motion matter. With the nominal suspension the half-car overestimates `a_w` by 15 % at the median, and the quarter-car by 53 %.

The road input matters most. On the raw wheel tracks the model more than doubles `a_w`; only the smoothed scenario profiles give a usable comparison.

The calibration is not overfitted to these drives. It is not the best setting on them, and fitting on the training roads gains only 2 to 4 points.

In frequency the model is weaker than its `a_w` suggests, with too much body motion near 1.2 Hz and too little above 2 Hz. Use it for weighted comfort, not for spectra or for peak accelerations above the body mode.

## Limits

- The IMU sits on the body, not at a seat, and measures roll and the left-right difference that the planar model lacks.
- The road is a reconstruction from the vehicle's own sensors; part of the error belongs to it rather than to the vehicle model.
- Only 14 roads are held out, so the held-out numbers are uncertain by several points.
- `a_w` is over a whole window, whose length differs between roads; short windows weigh the bump more.
- Two roads have their best lag at the ±0.5 s limit, so their time-domain numbers are unreliable.
