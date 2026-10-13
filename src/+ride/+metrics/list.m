function names = list()
pkg = meta.package.fromName('ride.metrics.builtin');
names = {pkg.FunctionList.Name};
extra = keys(ride.metrics.registry());
names = sort([names, extra(:)']);
end
