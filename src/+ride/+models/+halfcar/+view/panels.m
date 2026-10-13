function panels = panels(out)
c = ride.render.scene.colors();
heave = struct('data', {{out.z_B * 100, out.z_Wf * 100, out.z_Wr * 100}}, ...
    'color', {{c.z_body, c.z_wf, c.z_wr}}, 'style', {{'-', '--', ':'}}, ...
    'name', {{'$z_B$', '$z_{W,f}$', '$z_{W,r}$'}}, 'label', '$z\ [\mathrm{cm}]$');
pitch = struct('data', {{out.phi * 180 / pi}}, 'color', {{c.phi}}, 'style', {{'-'}}, ...
    'name', {{'$\varphi$'}}, 'label', '$\varphi\ [\mathrm{deg}]$');
shared = ride.render.plots.common_panels(out);
panels = {heave, pitch, shared{:}};
end
