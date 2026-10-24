function hf_error(err, what)
status = regexp(err.message, 'status (\d{3})', 'tokens', 'once');
has_token = ~isempty(getenv('HF_TOKEN'));
if ~isempty(status) && any(strcmp(status{1}, {'401', '403'}))
    if has_token
        error('ride:hfAccess', ['Hugging Face refused the HF_TOKEN for %s (HTTP %s). Check that the token is valid ', ...
            'and that its account has access to the dataset.'], what, status{1});
    end
    error('ride:hfAccess', ['%s needs a Hugging Face access token because the dataset is gated. Request access on its Hugging Face ', ...
        'page, then set the token in MATLAB with setenv(''HF_TOKEN'', ''hf_...'') and try again. Synthetic scenarios work without it.'], what);
end
if ~isempty(status) && strcmp(status{1}, '404')
    error('ride:hfNotFound', '%s was not found on Hugging Face (HTTP 404)', what);
end
error('ride:hfAccess', 'could not reach Hugging Face for %s: %s', what, err.message);
end
