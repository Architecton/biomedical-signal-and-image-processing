function rel_rr_vals = compute_rel_rr_rate(x, fs)
    % function rel_rr_vals = compute_rel_rr_rate(x, fs)
    % 
    % compute relative RR values for signal x with sampling frequency fs.

    % Compute beat indices.
    beat_positions = qrs_detect(x, fs, false);
    
    % Compute RR values and relative RR values.
    rr_vals = zeros(1, length(beat_positions-1));
    rel_rr_vals = zeros(1, length(beat_positions)-2);
    for idx = 1:length(beat_positions)-1
        time_1 = beat_positions(idx)/fs;
        time_2 = beat_positions(idx+1)/fs;
        rr_vals(idx) = time_2 - time_1;
        if idx > 1
            rel_rr_vals(idx-1) = rr_vals(idx)/rr_vals(idx-1);
        end
    end

end
