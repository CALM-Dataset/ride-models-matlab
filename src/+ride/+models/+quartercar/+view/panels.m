function panels = panels(out)
c = ride.render.scene.colors();
heave = struct('data', {{out.z_B * 100, out.z_W * 100}}, 'color', {{c.z_body, c.z_wf}}, ...
    'style', {{'-', '--'}}, 'name', {{'$z_B$', '$z_W$'}}, 'label', '$z\ [\mathrm{cm}]$');
shared = ride.render.plots.common_panels(out);
panels = {heave, shared{:}};
end
