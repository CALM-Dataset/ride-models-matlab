function names = list()
%LIST Metric names: the built-ins and the registered ones.
pkg = meta.package.fromName('ride.metrics.builtin');
names = {pkg.FunctionList.Name};
extra = keys(ride.metrics.registry());
names = sort([names, extra(:)']);
end
