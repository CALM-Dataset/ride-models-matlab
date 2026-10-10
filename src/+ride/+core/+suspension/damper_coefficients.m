function c = damper_coefficients(D, A)
z1 = 2 * D / (1 + A);
c.z1 = z1;
c.d1 = A * z1;
c.d2 = c.d1 / 0.25;
c.z2 = z1 / 0.40;
end
