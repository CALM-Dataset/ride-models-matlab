function names = list()
%LIST Names of the available models.
%   A model is a folder src/+ride/+models/+<name> with an info.m, or a model
%   added with ride.models.register.
%
%   See also ride.models.get, ride.models.validate.
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
