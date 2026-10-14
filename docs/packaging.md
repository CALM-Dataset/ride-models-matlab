# Packaging

## MATLAB toolbox

`toolbox/package_toolbox.m` builds a `.mltbx` installer with the repository contents, `src` on the path, and the version you pass:

```matlab
setup
package_toolbox('1.0.0')       % writes dist/ride-models-1.0.0.mltbx
```

It needs MATLAB R2019b or newer. Double-click the file to install the toolbox.

## Publishing

- GitHub: attach the `.mltbx` to a release.
- MATLAB File Exchange: link the GitHub repository, and it picks up the releases.

## Simulink

`simulink/build_quartercar.m` builds the quarter-car as a Simulink model, and `simulink/test_quartercar_simulink.m` checks it against the reference runs. A Simulink library with the half-car and a mask for the parameters is the next step.
