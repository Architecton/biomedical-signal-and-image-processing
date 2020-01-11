function sel_msk = select_channels(val, fs)
    % Select channels to use in multichannel heartbeat detection.
    % Parameter val contains channels stacked as rows. Parameter
    % fs represents the sampling frequency of the signals.

    % Compute mask for channels to use in detection.
    sel_msk = zeros(1, size(val, 1));
    best_idx = -1;
    best_p = -1;

    % Subset indices to use for channel evaluation.
    subset_idxs = 1:min(fs*30, length(val(1, :)));
    for idx_channel = 1:size(val, 1)
        
        % Use channel if probability of relative RR rate lies on interval [0.8, 1.2]
        if ~all(val(idx_channel, subset_idxs) == val(idx_channel, 1))
            rel_rr_rate = compute_rel_rr_rate(val(idx_channel, subset_idxs), fs);
            p = sum(rel_rr_rate >= 0.8 & rel_rr_rate <= 1.2)/length(rel_rr_rate);
            if p > best_p
                 best_p = p;
                best_idx = idx_channel;
            end
            if p >= 0.8
                sel_msk(idx_channel) = 1;
            end
        end
    end
    
    % If no channels selected, select channel with highest p.
    if ~any(sel_msk)
        sel_msk(best_idx) = 1;
    end
end
