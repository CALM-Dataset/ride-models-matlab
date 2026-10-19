# Adding a model

A model is a folder. Put it in `src/+ride/+models/+<name>`, or in a `+ride/+models/+<name>` folder anywhere on the path, and it is found automatically: `ride.models.list()` shows it and `ride.run`, the charts and the animation accept its name.

## Start from the template

`templates/model/+mymodel` is a working model, a quarter-car with a linear spring and damper. Copy it and rename the folder:

```matlab
copyfile('templates/model/+mymodel', 'src/+ride/+models/+linear_qc')
ride.models.validate('linear_qc', 'draw', true)
r = ride.run(ride.config('model', 'linear_qc', 'drive.profile', 'constant'));
```

The template's `info.m` reads its own folder name, so the copy needs no edits to run. Then change what you need: the parameters in `+params/load.m`, the equations in `+sim/simulate.m`, the drawing in `+view`. The template's view files reuse the quarter-car drawing; replace them when your model has other signals.

## The folder

```
+mymodel
  info.m                 what the model is, and handles to its parts
  +params/load.m         P = load()                     parameters, with P.DT
  +sim/simulate.m        out = simulate(P, road, speeds)
  +view/frame.m          frame(ax, P, road, out, k)     draw time step k
  +view/panels.m         panels = panels(out)           chart definitions
  +view/hud.m            [labels, values] = hud(out, k) header strip
```

`info.m` returns a struct with `name`, `title`, `description` and the handles `load`, `simulate`, `frame`, `panels` and `hud`.

## The contract

`simulate` returns a struct of column vectors with one value per speed step. It must hold `t`, `s`, `v` and `z_B_ddot`, the vertical body acceleration. Everything else is yours, and metrics and charts read what they need. Speed step `k` lasts `P.DT` seconds at `speeds(k)`; report the values at the end of the step. Read the road with `ride.core.terrain.height(road, s)` and `ride.core.terrain.height_dot(road, s, v)`. The nonlinear spring and damper of the built-in models are in `ride.core.suspension`. If the model has a wheelbase, put it in `P.L`: the trip then ends when the rear axle leaves the road, and the charts shade the rear axle's crossing too.

A panel is a struct with `data` (a cell array of vectors), `color`, `style` and `name` (one per vector) and `label`. Names and labels are LaTeX.

Check a model against the contract:

```matlab
ride.models.validate('mymodel')                  % parameters, simulation, panels, header
ride.models.validate('mymodel', 'draw', true)    % also draws one frame
```

## Without a folder

Register a model from your own code:

```matlab
ride.models.register('mymodel', @my_model_info);
ride.models.unregister('mymodel');               % when done
```

`my_model_info` returns the same struct as `info.m`.
