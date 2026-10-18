function names = list()
%LIST Speed profile types: the built-ins and the registered ones.
pkg = meta.package.fromName('ride.profiles.builtin');
names = {pkg.FunctionList.Name};
extra = keys(ride.profiles.registry());
names = sort([names, extra(:)']);
end
