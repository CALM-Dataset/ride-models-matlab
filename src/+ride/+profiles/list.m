function names = list()
pkg = meta.package.fromName('ride.profiles.builtin');
names = {pkg.FunctionList.Name};
extra = keys(ride.profiles.registry());
names = sort([names, extra(:)']);
end
