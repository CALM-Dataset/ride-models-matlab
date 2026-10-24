# Development

## Tests

```matlab
setup
run('tests/run_tests.m')         % models, plug-ins, terrain, comfort; about 3 s
test_quartercar_simulink         % Simulink blocks against the reference runs
test_halfcar_simulink
results = runtests('tests')      % all of the above through matlab.unittest
```

The tests compare against the reference runs in `data/models/*/reference` or check invariants: a constant drive has its speed as mean speed, a taller bump is less comfortable, metrics stop at the end of the road, plug-ins registered by a test are removed again. There are no stored golden numbers. Do not edit the reference runs or the parameter files to make a test pass.

## Continuous integration

`.github/workflows/tests.yml` runs `runtests('tests')` with `matlab-actions/setup-matlab` and `matlab-actions/run-tests` on R2025b with Simulink and the Signal Processing Toolbox. MathWorks licenses these actions without a token for public repositories, so the workflow runs on every push. For a private copy:

1. Get a batch licensing token from MathWorks and store it as the repository secret `MLM_LICENSE_TOKEN`.
2. Set the repository variable `RUN_MATLAB_TESTS` to `true`.

In a private copy the workflow is skipped until the variable is set, so it shows no failing runs.

## Generated files

| File | Built by |
| --- | --- |
| `simulink/ride_lib.slx` | `build_ride_lib` |
| `simulink/ride_demo_*.slx` | `build_demo('halfcar')`, `build_demo('quartercar')` |
| `examples/live/*.mlx` | `examples/live/build_live_scripts.m`, from `examples/live/source/*.m` |
| `dist/*.mltbx` | `toolbox/package_toolbox.m` |
| `figures/*` | the scripts listed in [figures.md](figures.md) |

Edit the sources and rebuild; do not edit the generated files by hand.

## Code style

Package folders with a `+` prefix, `snake_case` names, small functions. Public functions carry help text; there are no other comments, so names have to explain the code. Errors use `ride:` identifiers and say what to do.
