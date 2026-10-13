function panels = common_panels(out)
c = ride.render.scene.colors();
speed = struct('data', {{out.v * 3.6}}, 'color', {{c.speed}}, 'style', {{'-'}}, 'name', {{'$v$'}}, 'label', '$v\ [\mathrm{km/h}]$');
accel = struct('data', {{out.z_B_ddot}}, 'color', {{c.accel}}, 'style', {{'-'}}, 'name', {{'$\ddot{z}_B$'}}, 'label', '$\ddot{z}_B\ [\mathrm{m/s^2}]$');
panels = {speed, accel};
end
