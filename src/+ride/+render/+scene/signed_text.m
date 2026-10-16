function text = signed_text(value, digits)
value = round(value, digits);
if value == 0
    value = 0;
end
text = sprintf(sprintf('%%+.%df', digits), value);
end
