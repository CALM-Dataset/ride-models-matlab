# Packaging

## MATLAB toolbox

```matlab
setup
addpath toolbox
package_toolbox            % writes dist/ride-models-<version>.mltbx
```

The version comes from the `VERSION` file. The script rebuilds the Simulink library first, then packs `config`, `data` (without the download cache), `docs`, `examples`, `simulink`, `src`, `templates`, `tests` and the top-level files. Installing the `.mltbx` (double-click it, or `matlab.addons.toolbox.installToolbox`) puts `src` and `simulink` on the path; `setup` is not needed. Downloads from Hugging Face go to `data/cache` inside the installed toolbox unless `RIDE_CACHE` points elsewhere.

The toolbox was built and installed on MATLAB R2025b, and the examples and the test suite pass from the installed copy. Older releases are not tested.

## Publishing

Nothing is published automatically. The steps for a release are in [releasing.md](releasing.md).
