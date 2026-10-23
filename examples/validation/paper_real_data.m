function paper_real_data(config)
%PAPER_REAL_DATA The comparison with the recorded drives as figures for a paper.
%   paper_real_data('paths.json') reads results.mat written by run_real_data (and runs
%   analyse_real_data for the spectra) and writes to figures/paper, as PDF, SVG and PNG:
%     sim2real_scatter   a_w of the half-car against the IMU per road, and the error distribution
%     sim2real_traces    measured and simulated body acceleration on a typical training road and a
%                        typical evaluation road (held out)
%     sim2real_spectra   median spectra of the measured and simulated body acceleration
%   Palatino, LaTeX labels, no title or footer, 27 cm wide.
here = fileparts(mfilename('fullpath'));
run(fullfile(here, '..', '..', 'setup.m'));
paths = jsondecode(fileread(config));
source = paths.output;
if isempty(source)
    source = fullfile(ride.root(), 'figures', 'real_data');
end
saved = load(fullfile(source, 'results.mat'));
r = saved.results(~saved.results.low_confidence, :);
series = saved.series;
output = fullfile(ride.root(), 'figures', 'paper');
if ~isfolder(output)
    mkdir(output);
end
style = struct('font', 'Palatino Linotype', 'size', 15, 'imu', [0 64 247] / 255, 'imu_raw', [0.62 0.74 1.0], ...
    'aligned', [197 14 31] / 255, 'band', [0.93 0.93 0.93]);
scatter_figure(r, style, output);
traces_figure(r, series, style, output);
analysis = analyse_real_data(config);
spectra_figure(analysis.spectra, style, output);
end

function scatter_figure(r, style, output)
[fig, layout] = paper_figure(style, [27 11], [1 2]);
ax = paper_axes(layout, style);
limit = [0.06 1.4];
fill(ax, [limit fliplr(limit)], [limit * 0.7 fliplr(limit) * 1.3], style.band, 'EdgeColor', 'none', 'DisplayName', '$\pm 30\,\%$');
plot(ax, limit, limit, 'k--', 'LineWidth', 0.8, 'HandleVisibility', 'off');
train = r.paper_split == "train";
scatter(ax, r.a_w_measured(train), r.a_w_aligned(train), 36, style.aligned, 'o', 'filled', 'MarkerFaceAlpha', 0.75, ...
    'MarkerEdgeColor', 'k', 'LineWidth', 0.3, 'DisplayName', sprintf('training roads (%d)', nnz(train)));
scatter(ax, r.a_w_measured(~train), r.a_w_aligned(~train), 60, style.imu, 'd', 'filled', 'MarkerFaceAlpha', 0.85, ...
    'MarkerEdgeColor', 'k', 'LineWidth', 0.3, ...
    'DisplayName', sprintf('evaluation roads, held out (%d)', nnz(~train)));
set(ax, 'XScale', 'log', 'YScale', 'log');
axis(ax, [limit limit]);
xlabel(ax, '$a_w$ measured by the IMU in $\mathrm{m/s^2}$', 'Interpreter', 'latex');
ylabel(ax, '$a_w$ of the half-car in $\mathrm{m/s^2}$', 'Interpreter', 'latex');
legend(ax, 'Location', 'northwest', 'Box', 'off', 'Interpreter', 'latex', 'FontSize', style.size - 3);
ax = paper_axes(layout, style);
edges = -80:10:120;
e = 100 * r.error_aligned;
patch(ax, [-30 30 30 -30], [0 0 40 40], style.band, 'EdgeColor', 'none');
histogram(ax, min(max(e, edges(1)), edges(end) - 1), edges, 'FaceColor', style.aligned, 'FaceAlpha', 0.85, ...
    'EdgeColor', 'k', 'LineWidth', 0.3);
xline(ax, 0, 'k-');
xline(ax, median(e), 'k--', 'LineWidth', 1.2);
text(ax, 0.97, 0.96, {sprintf('%d roads', numel(e)), sprintf('median $|e|$ %.1f\\,\\%%', median(abs(e))), ...
    sprintf('median $e$ %+.1f\\,\\%%', median(e))}, 'Units', 'normalized', ...
    'Interpreter', 'latex', 'FontSize', style.size - 3, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
xlabel(ax, '$e = (a_{w,\mathrm{sim}} - a_{w,\mathrm{IMU}})\,/\,a_{w,\mathrm{IMU}}$ in \%', 'Interpreter', 'latex');
ylabel(ax, 'number of roads');
xlim(ax, edges([1 end]));
ylim(ax, [0 40]);
set(ax, 'Layer', 'top');
save_paper(fig, output, 'sim2real_scatter');
end

function traces_figure(r, series, style, output)
names = string({series.name});
train = r.paper_split == "train";
picks = [closest_to_median(r(train, :)), closest_to_median(r(~train, :))];
roles = ["training road", "evaluation road, held out"];
[fig, layout] = paper_figure(style, [27 13], [2 1]);
for k = 1:2
    row = r(r.scenario == picks(k), :);
    s = series(names == picks(k));
    ax = paper_axes(layout, style);
    span = [max(0, s.bump_t(1) - 3), min(s.t(end), s.bump_t(2) + 4)];
    yl = 1.15 * [min([s.measured_lp; s.simulated]) max([s.measured_lp; s.simulated])];
    patch(ax, s.bump_t([1 2 2 1]), yl([1 1 2 2]), style.band, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(ax, s.imu_t, s.a_z, '-', 'Color', style.imu_raw, 'LineWidth', 0.6, 'DisplayName', 'IMU raw');
    plot(ax, s.t, s.measured_lp, '-', 'Color', style.imu, 'LineWidth', 1.8, 'DisplayName', 'IMU filtered at 10\,Hz');
    plot(ax, s.t, s.simulated, '-', 'Color', style.aligned, 'LineWidth', 1.8, 'DisplayName', 'half-car model');
    xlim(ax, span);
    ylim(ax, yl);
    ylabel(ax, '$\ddot z_B$ in $\mathrm{m/s^2}$', 'Interpreter', 'latex');
    title(ax, sprintf('%s (%s): $a_w$ %.2f measured, %.2f simulated, %+.0f\\,\\%%', ...
        strrep(picks(k), '_', '\_'), roles(k), row.a_w_measured, row.a_w_aligned, round(100 * row.error_aligned) + 0), ...
        'Interpreter', 'latex', 'FontSize', style.size - 3, 'FontWeight', 'normal');
    ax.TitleHorizontalAlignment = 'left';
    if k == 1
        lg = legend(ax, 'Box', 'off', 'Interpreter', 'latex', 'FontSize', style.size - 3, 'NumColumns', 3);
        lg.Layout.Tile = 'north';
    else
        xlabel(ax, '$t$ in s', 'Interpreter', 'latex');
    end
end
save_paper(fig, output, 'sim2real_traces');
end

function name = closest_to_median(r)
[~, k] = min(abs(abs(r.error_aligned) - median(abs(r.error_aligned))));
name = r.scenario(k);
end

function spectra_figure(s, style, output)
[fig, layout] = paper_figure(style, [27 11], [1 2]);
ax = paper_axes(layout, style);
fill(ax, [s.f; flipud(s.f)], [s.measured_q(:, 1); flipud(s.measured_q(:, 2))], style.imu, 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill(ax, [s.f; flipud(s.f)], [s.simulated_q(:, 1); flipud(s.simulated_q(:, 2))], style.aligned, 'FaceAlpha', 0.12, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(ax, s.f, s.measured, '-', 'Color', style.imu, 'LineWidth', 1.8, 'DisplayName', 'IMU');
plot(ax, s.f, s.simulated, '-', 'Color', style.aligned, 'LineWidth', 1.8, 'DisplayName', 'half-car model');
set(ax, 'XScale', 'log', 'YScale', 'log');
xlim(ax, [0.3 20]);
xlabel(ax, '$f$ in Hz', 'Interpreter', 'latex');
ylabel(ax, 'PSD of $\ddot z_B$ in $\mathrm{(m/s^2)^2/Hz}$', 'Interpreter', 'latex');
legend(ax, 'Location', 'southwest', 'Box', 'off', 'Interpreter', 'latex', 'FontSize', style.size - 3);
ax = paper_axes(layout, style);
fill(ax, [s.f; flipud(s.f)], [s.ratio_q(:, 1); flipud(s.ratio_q(:, 2))], style.aligned, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
plot(ax, s.f, s.ratio, '-', 'Color', style.aligned, 'LineWidth', 1.6);
yline(ax, 1, 'k--', 'LineWidth', 0.8);
set(ax, 'XScale', 'log', 'YScale', 'log');
xlim(ax, [0.3 20]);
ylim(ax, [0.05 20]);
xlabel(ax, '$f$ in Hz', 'Interpreter', 'latex');
ylabel(ax, 'PSD ratio, model over IMU', 'Interpreter', 'latex');
save_paper(fig, output, 'sim2real_spectra');
end

function [fig, layout] = paper_figure(style, size_cm, grid)
fig = ride.validation.white_figure(size_cm(1), size_cm(2));
set(fig, 'DefaultAxesFontName', style.font, 'DefaultTextFontName', style.font, 'DefaultLegendFontName', style.font, ...
    'DefaultAxesFontSize', style.size, 'DefaultAxesBox', 'on', 'DefaultAxesXColor', 'k', 'DefaultAxesYColor', 'k', ...
    'DefaultAxesGridAlpha', 0.12, 'DefaultAxesLineWidth', 1.0);
layout = tiledlayout(fig, grid(1), grid(2), 'TileSpacing', 'compact', 'Padding', 'compact');
end

function ax = paper_axes(layout, style)
ax = nexttile(layout);
hold(ax, 'on');
grid(ax, 'on');
box(ax, 'on');
set(ax, 'FontName', style.font, 'FontSize', style.size, 'TickDir', 'out', 'TickLabelInterpreter', 'latex');
ax.Toolbar = [];
end

function save_paper(fig, output, name)
drawnow;
stem = fullfile(output, name);
exportgraphics(fig, [stem '.pdf'], 'ContentType', 'vector', 'BackgroundColor', 'white');
exportgraphics(fig, [stem '.png'], 'Resolution', 600, 'BackgroundColor', 'white');
set(fig, 'PaperPositionMode', 'auto');
print(fig, [stem '.svg'], '-dsvg', '-vector');
fprintf('wrote %s.pdf, .svg and .png in %s\n', name, output);
end
