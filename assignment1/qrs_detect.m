function beat_positions = qrs_detect(x, fs, plt)
    % Detect heart beat positions from signal x with sampling frequency fs.
    % The parameter plt specifies whether to plot detections.
    %
    
    % Normalize signal.
    normalized = (x - mean(x))/std(x);

    % Perform range filtering.
    omega_range = ceil(fs*0.2);
    range_filtered = range_filt(normalized, omega_range);
    range_filtered_normalized = (range_filtered - mean(range_filtered))/std(range_filtered);
    
    % Interpolate local maxima and minima and compute beat detection threshold.
    window_length = min(fs*5.0, length(x));
    interpolated_vals_min = interpolate_extrema2(range_filtered_normalized, fs, 'minima', window_length, 4);
    interpolated_vals_max = interpolate_extrema2(range_filtered_normalized, fs, 'maxima', window_length, 4); 
    % thresh = 0.95.*(interpolated_vals_max + interpolated_vals_min);
    
    dff = abs(interpolated_vals_max - interpolated_vals_min);
    thresh = interpolated_vals_max - 0.3*dff;

    % If plotting, plot detection setup.
    if plt
        figure(); hold on;
        plot(1:length(x), range_filtered_normalized);
        plot(1:length(x), interpolated_vals_min, 'r--', 'LineWidth', 2);
        plot(1:length(x), interpolated_vals_max, 'g--', 'LineWidth', 2);
        plot(1:length(x), thresh, 'k', 'LineWidth', 2);
    end
    
    % Find msk values for which the next fs/25 values correspond to
    % same amplitudes.
    msk = (range_filtered_normalized > thresh);

    % Find indices of first true value in mask in each sequence of true
    % values.
    for idx = find(msk)
       idx2 = idx + 1;
       while idx2 <= length(msk) && msk(idx2) == 1
           msk(idx2) = 0;
           idx2 = idx2 + 1;
       end
    end

    % Check if there is a value between value corresponding to current true value
    % in mask and next true value in mask, that is lower than threshold. If
    % no, set to false.
    idxs_true = find(msk);
    for idx = 1:length(idxs_true)-1
        start_idx = idxs_true(idx);
        stop_idx = idxs_true(idx+1);
        k = start_idx + 1;
        flg = false;
        while k < stop_idx && ~flg
            if range_filtered_normalized(k) <= thresh(k)
                flg = true;
            end
            k = k + 1;
        end
        if ~flg
           msk(idxs_true(idx)) = 0;
        end 
    end

    % Get final beat positions.
    static_delay = fs*0.11;
    beat_positions = find(msk) + ceil(static_delay);
    
    % If plotting, plot detections on original signal.
    if plt
        d = 1:length(x);
        plot(d(msk), thresh(msk), 'r*');
        figure(); hold on;
        plot(1:length(x), x);
        for idx = 1:length(beat_positions)
            xline(beat_positions(idx), 'g', {sprintf('%d', idx)});
        end
    end
end
