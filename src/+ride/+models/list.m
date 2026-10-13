function names = list()
pkg = meta.package.fromName('ride.models');
names = {};
prefix = 'ride.models.';
for i = 1:numel(pkg.PackageList)
    sub = pkg.PackageList(i);
    if any(strcmp({sub.FunctionList.Name}, 'info'))
        names{end + 1} = sub.Name(numel(prefix) + 1:end); %#ok<AGROW>
    end
end
extra = keys(ride.models.registry());
names = sort([names, extra(:)']);
end
