function [xs, ys] = spring_xy(x_c, y_top, y_bot, n, w)
n_pts = 2 * n + 2;
ys = linspace(y_top, y_bot, n_pts);
xs = x_c * ones(1, n_pts);
idx = 2:n_pts - 1;
sign_pattern = ones(size(idx));
sign_pattern(mod(idx - 1, 2) == 0) = -1;
xs(idx) = x_c + w * sign_pattern;
end
