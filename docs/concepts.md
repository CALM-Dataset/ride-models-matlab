# Concepts

A car drives over a road at some speed. How much does the body shake? This package answers that with two small vehicle models.

## The pieces

- **Model**: the vehicle. Quarter-car: one wheel and a quarter of the body, heave only. Half-car: two axles, heave and pitch. Braking and accelerating shift load between the axles.
- **Scenario**: the road. A list of bumps and holes, or a measured height profile.
- **Speed profile**: the speed at every time step. Constant, a dip before the bump, a ramp, or any signal you provide.
- **Metric**: a score computed from the simulation. The default is the weighted RMS acceleration `a_w`.

`ride.run` combines the four.

## Comfort in one paragraph

People feel vertical vibration most between about 4 and 8 Hz and hardly at all below 0.5 Hz. ISO 2631-1 captures this with the Wk weighting filter. `a_w` is the RMS of the Wk-weighted body acceleration over the trip, in m/s^2. Higher means less comfortable. `vdv` is the vibration dose value, which weights shocks more strongly.

Slower is not always better. In the synthetic catalog, `a_w` over the shallow and minor potholes peaks at an intermediate speed and falls again at higher speeds, and on the medium bump the reactive driver, who slows down for it, gets a higher half-car `a_w` than a constant speed. `examples/paper/fig2_aw_vs_speed.m` and `fig3_profiles.m` reproduce both.

## Symbols

| Symbol | Meaning |
| --- | --- |
| `z_B` | body heave displacement |
| `z_W`, `z_Wf`, `z_Wr` | wheel heave (front, rear) |
| `phi` | body pitch angle |
| `v`, `s` | speed, distance along the road |
| `k_S`, `D` | suspension spring stiffness, damper coefficient |
| `k_T`, `c_T` | tyre stiffness, tyre damping |
| `DT` | time step of the outputs, 0.02 s |

Parameters live in `data/models/<model>/params.json`.

## Conventions

SI units everywhere. A bump is a raised cosine given by its start, height and length. A negative height is a hole. The road starts at `s = 0` where the front axle begins.
