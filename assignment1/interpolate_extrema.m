function interpolated_vals = interpolate_extrema(x, fs, extrema_type, window_length, polynomial_degree)
    % Interpolate signal extrema using polynomials. The parameter x represents the signal, the parameter
    % extrema_types specifies the type of the extrema to interpolate. Possible values are 'minima' and
    % 'maxima'. The parameter window_length specifies the length of the local extrema interpolation window..
    % The polynomial_degree specifies the polynomial degree to use.


    % Allocate vector for storing interpolated values.
    interpolated_vals = zeros(1, length(x));
    
    
    % Compute mask for extrema.       
    if strcmp(extrema_type, 'minima')
        [local_extrema, pr] = islocalmin(x, 'FlatSelection', 'first');
    elseif strcmp(extrema_type, 'maxima')
        [local_extrema, pr] = islocalmax(x, 'FlatSelection', 'first');
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
    
    % Interpolate filtered local extrema with polynomial splines.
    idx = 1;
    while idx < length(x)
        window_idxs = idx:idx + min(window_length, length(x) - idx);
        
        % Get signal values in window.
        x_local = x(window_idxs);
        
        % Find signal indices at local extrema.
        x_ext = find(local_extrema(window_idxs));
        
        % Compute signal amplitude at local extrema.
        if length(x_ext) > 1
            y_ext = medfilt1(x_local(local_extrema(window_idxs)), 5);
        else
            y_ext = x_local(local_extrema(window_idxs));
        end
        
        % interpolate spline and move sliding window.
        interp_coeff = polyfit(x_ext/window_length, y_ext, min(polynomial_degree, length(y_ext)-1));
        res = polyval(interp_coeff, (1:length(window_idxs))/window_length);
        interpolated_vals(window_idxs) = res;
        tmp = window_idxs(local_extrema(window_idxs));
        if tmp(end) > idx
            idx = tmp(end);
        else
            idx = window_idxs(end);
        end 
    end
    
end

