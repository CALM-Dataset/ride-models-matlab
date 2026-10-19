# Release notes

## 1.0.0

First release.

- Quarter-car (6 states) and half-car (11 states, pitch, load transfer) ride models, checked against reference runs of an independent Python implementation.
- Scenarios: 185 synthetic roads from a size-code catalog, measured roads from the CALM-Scenarios dataset on Hugging Face (needs an access token), and your own roads from files, functions or code.
- Speed profiles: constant, dip, dip before the bump, ramp, table, function, a reactive driver, and recorded MPC and human drives.
- Metrics: ISO 2631-1 Wk-weighted RMS `a_w`, VDV, peaks, pitch, suspension travel, trip time and speeds.
- Plug-in registries for models, scenarios, profiles and metrics; a model template.
- Animated scene with time-series charts, frame export and video.
- Simulink library with quarter-car, half-car, axle, road and drive blocks, checked against the same reference runs.
- Verified on MATLAB R2025b with Simulink and the Signal Processing Toolbox.
