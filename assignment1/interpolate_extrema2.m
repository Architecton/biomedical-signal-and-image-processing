function interpolated_vals = interpolate_extrema2(x, fs, extrema_type, window_length, polynomial_degree)
    % Interpolate signal extrema using cubic splines. The parameter x represents the signal, the parameter
    % extrema_types specifies the type of the extrema to interpolate. Possible values are 'minima' and
    % 'maxima'. The parameter window_length specifies the length of the local extrema filtering window.
    % The polynomial_degree is currently unused for this function.

    % Allocate vector for storing interpolated values.
    interpolated_vals = zeros(1, length(x));
    
    
    % Compute mask for extrema.       
    if strcmp(extrema_type, 'minima')
        [local_extrema, pr] = islocalmin(x, 'FlatSelection', 'last');
    elseif strcmp(extrema_type, 'maxima')
        [local_extrema, pr] = islocalmax(x, 'FlatSelection', 'last');
    else
        return;
    end
    
    % Set local minima filtering window in seconds.
    window_len_sec = 4;
    for idx = 1:fs*window_len_sec:length(pr)
        window_idxs = idx:idx + min(fs*window_len_sec, length(pr)-idx);
        
        % Compute reference and filter local minima in window.
        ref = max(pr(window_idxs));
        msk = pr(window_idxs) < ref/2;
        pr(window_idxs(~msk)) = 0;
    end
    
    % Set local extrema mask with insufficient prominence to 0.
    local_extrema(pr > 0) = 0;
    
    % Interpolate extrema with cubic splines.
    y_ext = medfilt1(x(local_extrema), 5);
    % y_ext = x(local_extrema);
    x_ext = find(local_extrema)/length(x);
    interpolated_vals = spline(x_ext, y_ext, (1:length(x))/length(x));
    
end

