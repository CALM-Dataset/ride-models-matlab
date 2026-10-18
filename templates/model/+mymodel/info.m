function i = info()
[~, folder] = fileparts(fileparts(mfilename('fullpath')));
name = folder(2:end);
package = ['ride.models.' name];
i.name = name;
i.title = 'Linear quarter-car';
i.description = 'quarter-car with a linear spring and damper, a template for new models (5 states)';
i.load = str2func([package '.params.load']);
i.simulate = str2func([package '.sim.simulate']);
i.frame = str2func([package '.view.frame']);
i.panels = str2func([package '.view.panels']);
i.hud = str2func([package '.view.hud']);
end
