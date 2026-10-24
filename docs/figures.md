# Figures

Each figure comes from a script and is drawn on a white background, whatever theme MATLAB or the system uses. Run `setup` first. Output goes to `figures/`, which is not tracked.

## Comparison with the recorded car

`examples/validation/paper_real_data.m` draws three summary figures in a paper style (Palatino, LaTeX labels, no title, 27 cm wide) to `figures/paper`, as PDF, SVG and PNG. They compare the calibrated half-car with the car's IMU on the 105 usable recorded drives. They need the gated CALM recordings, so they are not in the repository; see [validation-real-data.md](validation-real-data.md).

| Figure | Shows |
| --- | --- |
| `sim2real_scatter` | `a_w` of the model against the IMU for each road, and the spread of the error |
| `sim2real_traces` | body acceleration of the car and of the model on one training road and one evaluation road |
| `sim2real_spectra` | spectra of the measured and simulated body acceleration, and their ratio |

```matlab
run_real_data('examples/validation/paths.json');      % once, writes results.mat
paper_real_data('examples/validation/paths.json');
```

## Package figures

These carry a footer with the package version and the inputs they were made with, for the README, the docs and the thesis.

| Figure | Shows | Script |
| --- | --- | --- |
| `fig1_quarter_vs_half` | body acceleration of both models over the same bump | `examples/paper/fig1_quarter_vs_half.m` |
| `fig2_aw_vs_speed` | `a_w` against constant speed on the single-feature roads | `examples/paper/fig2_aw_vs_speed.m` |
| `fig3_profiles` | three speed profiles on four roads | `examples/paper/fig3_profiles.m` |
| `fig4_validation` | two reference drives against the Python implementation | `examples/paper/fig4_validation.m` |
| `architecture` | the package layout | `examples/paper/fig_architecture.m` |
| `calm_replay` | replay of the CALM comfort study profiles | `examples/paper/replay_calm_profiles.m` (needs the CALM export) |
| `<model>_frame` | one frame of the animated scene | `examples/show_frame.m` |

`examples/paper/make_all.m` draws the first five.

## Diagnostics of the comparison

Diagnostic figures in `figures/real_data`, from `examples/validation`.

| Figure | Shows | Script |
| --- | --- | --- |
| `real_scatter`, `real_errors`, `real_near_away`, `real_locations`, `real_examples`, `real_checks` | the results and the data checks | `run_real_data.m` |
| `real_spectra` | spectra of the measured and simulated acceleration | `analyse_real_data.m` |
| `calibration` | `a_w` error over a grid of spring and damper factors, training and held-out roads | `check_calibration.m` |
