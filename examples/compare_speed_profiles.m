run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup.m'));
cfg = ride.config();
names = cfg.compare.profiles;
for i = 1:numel(names)
    cfg.drive.profile = names{i};
    r = ride.run(cfg);
    fprintf('%-10s', names{i});
    for field = fieldnames(r.metrics)'
        fprintf('  %s %.3f', field{1}, r.metrics.(field{1}));
    end
    fprintf('\n');
end
