function y = wk_weight(x, dt, oversample)
if nargin < 3
    oversample = 10;
end
x = x(:);
n = numel(x);
if n < 2
    y = zeros(size(x));
    return
end
fs = oversample / dt;
if exist('resample', 'file')
    up = resample(x, oversample, 1);
else
    up = interp1((0:n - 1)', x, (0:oversample * n - 1)' / oversample, 'pchip', 'extrap');
end
[num, den] = wk_sections(fs);
z = up;
for k = 1:size(num, 1)
    b = num(k, :);
    a = den(k, :);
    z = filter(b, a, z, lfilter_zi(b, a) * z(1));
end
y = z(1:oversample:end);
y = y(1:n);
end

function [num, den] = wk_sections(fs)
w = @(f) 2 * pi * f;
w1 = w(0.4); w2 = w(100.0); w3 = w(12.5); w4 = w(12.5); w5 = w(2.37); w6 = w(3.35);
Q4 = 0.63; Q5 = 0.91; Q6 = 0.91; K = 0.5;
r2 = sqrt(2);
c = 2 * fs;
nA = w2 ^ 2 * [1 0 0];            dA = [1 r2 * w1 w1 ^ 2];
nB = [0 w4 ^ 2 / w3 w4 ^ 2];      dB = [1 r2 * w2 w2 ^ 2];
nC = K * [1 / w5 ^ 2, 1 / (Q5 * w5), 1];  dC = [1 w4 / Q4 w4 ^ 2];
nD = [0 0 1];                     dD = [1 / w6 ^ 2, 1 / (Q6 * w6), 1];
nums = [nA; nB; nC; nD];
dens = [dA; dB; dC; dD];
num = zeros(4, 3);
den = zeros(4, 3);
for k = 1:4
    b = bilinear_poly(nums(k, :), c);
    a = bilinear_poly(dens(k, :), c);
    num(k, :) = b / a(1);
    den(k, :) = a / a(1);
end
end

function p = bilinear_poly(s, c)
p = s(1) * c ^ 2 * [1 -2 1] + s(2) * c * [1 0 -1] + s(3) * [1 2 1];
end

function zi = lfilter_zi(b, a)
b = b / a(1);
a = a / a(1);
n = numel(a) - 1;
C = zeros(n);
C(1, :) = -a(2:end);
C(2:n, 1:n - 1) = eye(n - 1);
zi = (eye(n) - C') \ (b(2:end) - a(2:end) * b(1))';
zi = zi(:)';
end
