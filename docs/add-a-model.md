# Adding a model

A model is a folder. Put it in `src/+ride/+models/+<name>` and it is found automatically.

```
+mymodel
  info.m                 what the model is, and handles to its parts
  +params/load.m         P = load()                     parameters, with P.DT
  +sim/simulate.m        out = simulate(P, road, speeds)
  +view/frame.m          frame(ax, P, road, out, k)     draw time step k
  +view/panels.m         panels = panels(out)           chart definitions
  +view/hud.m            [labels, values] = hud(out, k) header strip
```

`info.m`:

```matlab
function i = info()
i.name = 'mymodel';
i.title = 'My model';
i.description = 'one line';
i.load = @ride.models.mymodel.params.load;
i.simulate = @ride.models.mymodel.sim.simulate;
i.frame = @ride.models.mymodel.view.frame;
i.panels = @ride.models.mymodel.view.panels;
i.hud = @ride.models.mymodel.view.hud;
end
```

## The contract

`simulate` returns a struct of column vectors with one value per speed step. It must hold `t`, `s`, `v` and `z_B_ddot`, the vertical body acceleration. Everything else is yours, and metrics and charts read what they need. The road is read with `ride.core.terrain.height(road, s)` and `ride.core.terrain.height_dot(road, s, v)`. Nonlinear spring and damper forces are in `ride.core.suspension`.

Check a model against the contract:

```matlab
ride.models.validate('mymodel')                  % parameters, simulation, panels, header
ride.models.validate('mymodel', 'draw', true)    % also draws one frame
```

## Without touching the package

Register a model from your own code or folder:

```matlab
ride.models.register('mymodel', @my_model_info);
```

`my_model_info` returns the same struct as `info.m`. After that `ride.load`, `ride.simulate`, `ride.run`, the charts and the animation all accept `'mymodel'`.
