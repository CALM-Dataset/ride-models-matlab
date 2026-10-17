function wire(sys, from, from_port, to, to_port, name)
src = get_param(from, 'PortHandles');
dst = get_param(to, 'PortHandles');
connection = add_line(sys, src.Outport(from_port), dst.Inport(to_port), 'autorouting', 'smart');
if nargin > 5
    set_param(connection, 'Name', name);
end
end
