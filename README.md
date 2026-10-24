# Ride Models for MATLAB

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![MATLAB R2025b](https://img.shields.io/badge/MATLAB-R2025b-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Tests](https://github.com/CALM-Dataset/ride-models-matlab/actions/workflows/tests.yml/badge.svg)](https://github.com/CALM-Dataset/ride-models-matlab/actions/workflows/tests.yml)
[![DOI](https://zenodo.org/badge/1432558566.svg)](https://doi.org/10.5281/zenodo.23627533)

Quarter-car and half-car vehicle models for ride comfort analysis over road anomalies such as speed bumps, crosswalks and potholes. The package simulates the vertical dynamics of a car for a given road and speed profile and scores the ride with the ISO 2631-1 frequency-weighted acceleration. It includes a Simulink block library and an animated visualisation.

![Half-car crossing a speed bump](docs/images/halfcar_frame.png)

## Features

- Quarter-car (6 states) and half-car (11 states, pitch and longitudinal load transfer) models with nonlinear springs and dampers
- 185 synthetic road scenarios and 159 measured road profiles from the gated [CALM-Scenarios](https://huggingface.co/datasets/CALM-Dataset/CALM-Scenarios) dataset
- Speed profiles: constant, speed dip, ramp, rule-based driver, recorded drives, tables and custom functions
- Comfort metrics: weighted RMS acceleration `a_w`, vibration dose value, peak acceleration, travel time
- Simulink library with the same models
- Extensible: models, scenarios, speed profiles and metrics can be added without changing the package

## Installation

Download `ride-models-<version>.mltbx` from the [releases page](https://github.com/CALM-Dataset/ride-models-matlab/releases) and open it in MATLAB. Alternatively, clone the repository and run `setup` in each session.

Requirements: MATLAB R2025b. Simulink is required for the block library. The Signal Processing Toolbox is optional. The measured roads require approved access to the dataset on Hugging Face; everything else runs offline.

## Quick start

```matlab
setup
r = ride.run();
disp(r.metrics)
ride.render.animate(r.P, r.road, r.out)
```

The default configuration in `config/default.json` simulates the half-car over a medium speed bump with a speed reduction before it. Any setting can be overridden:

```matlab
r = ride.run(ride.config('model', 'quartercar', 'scenario', 'synthetic:02_two_bumps/s_l'));
```

## Examples

Body acceleration of the two models over the same bump at three speeds:

![Quarter-car and half-car over a medium bump](docs/images/quarter_vs_half.png)

Weighted RMS acceleration against constant speed for single bumps and potholes:

![Weighted acceleration against speed](docs/images/aw_vs_speed.png)

Further examples are in `examples/` and `examples/live/`.

## Documentation

See the [wiki](https://github.com/CALM-Dataset/ride-models-matlab/wiki) for the user guide, the model equations and the validation.

## Validation

The MATLAB and Simulink implementations agree with an independent Python implementation to within 1e-11 relative to the signal peak. Compared with IMU measurements from 105 recorded drives, the calibrated half-car reproduces the weighted RMS acceleration with a median absolute error of 15.8 % and a median bias of +3.1 %. See [Validation](https://github.com/CALM-Dataset/ride-models-matlab/wiki/Validation) for details and limitations.

Run the test suite with:

```matlab
setup
runtests('tests')
```

## Citation

If you use this software, please cite:

> M. E. A. Abdelazim, *Comfort-Aware Speed Planning over Road Anomalies: A Reinforcement-Learning Approach*, Bachelor's thesis, Technische Universität Berlin, 2026.

To cite the software itself, use the Zenodo archive: [doi:10.5281/zenodo.23627533](https://doi.org/10.5281/zenodo.23627533). A machine-readable citation is provided in `CITATION.cff`.

## License

Released under the [MIT License](LICENSE).
