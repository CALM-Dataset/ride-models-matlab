function i = info()
i.name = 'quartercar';
i.title = 'Quarter-car';
i.description = 'one wheel and one body, heave only (6 states)';
i.load = @ride.models.quartercar.params.load;
i.simulate = @ride.models.quartercar.sim.simulate;
i.frame = @ride.models.quartercar.view.frame;
i.panels = @ride.models.quartercar.view.panels;
i.hud = @ride.models.quartercar.view.hud;
end
