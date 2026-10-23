function d = savgol_derivative(x, window, order, dt)
%SAVGOL_DERIVATIVE First derivative of a uniformly sampled signal with a Savitzky-Golay filter.
%   d = ride.validation.savgol_derivative(x, window, order, dt) fits a polynomial of the given
%   order to each odd-length window of samples and returns its slope at the centre. The first
%   and last half windows use the polynomial fitted to the first and last full window,
%   evaluated at each sample, as scipy.signal.savgol_filter does with mode "interp".
x = x(:);
n = numel(x);
if mod(window, 2) ~= 1 || window <= order
    error('ride:validation:badFilter', 'the window must be odd and longer than the polynomial order');
end
if n < window
    error('ride:validation:shortSignal', 'the signal has %d samples, fewer than the window of %d', n, window);
end
half = (window - 1) / 2;
offsets = (-half:half)';
basis = offsets .^ (0:order);
fit = pinv(basis);
slope_weights = fit(2, :)';
d = zeros(n, 1);
for k = half + 1:n - half
    d(k) = slope_weights' * x(k - half:k + half);
end
derivative_basis = [zeros(window, 1), (1:order) .* offsets .^ (0:order - 1)];
head = fit * x(1:window);
d(1:half) = derivative_basis(1:half, :) * head;
tail = fit * x(end - window + 1:end);
d(end - half + 1:end) = derivative_basis(end - half + 1:end, :) * tail;
d = d / dt;
end
