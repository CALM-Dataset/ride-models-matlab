function names = list(suite)
%LIST Synthetic scenario names, as suite/key.
%   ride.scenarios.synthetic.list('02_two_bumps') lists one suite.
c = ride.scenarios.synthetic.catalog();
names = {};
for i = 1:numel(c.suites)
    s = c.suites(i);
    if nargin > 0 && ~strcmp(s.suite, suite)
        continue
    end
    names = [names; strcat([s.suite '/'], s.keys(:))];
end
end
