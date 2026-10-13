function i = info()
i.name = 'halfcar';
i.title = 'Half-car';
i.description = 'two axles, heave and pitch, load transfer from longitudinal acceleration (11 states)';
i.load = @ride.models.halfcar.params.load;
i.simulate = @ride.models.halfcar.sim.simulate;
i.frame = @ride.models.halfcar.view.frame;
i.panels = @ride.models.halfcar.view.panels;
i.hud = @ride.models.halfcar.view.hud;
end
