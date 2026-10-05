function r = rms(x)
x = x(:);
if isempty(x)
    r = 0;
else
    r = sqrt(mean(x .^ 2));
end
end
