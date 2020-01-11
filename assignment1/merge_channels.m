function beat_positions_final = merge_channels(x, fs, desc, plt)
    % Compute beat positions by cross-checking detections from 'safe' channels.
    % Parameter x represents the singal with sampling frequency fs.
    % Parameter desc represents a cell array of channel descriptions for
    % each channel in x. Parameter plt specifies whether to plot the 
    % detections.
    %
    
    % Compute safe channels.
    sel_msk = select_channels(x, fs);

    % Compute beat indices for selected channels.
    beat_positions = cell(1, sum(sel_msk));
    idx_beat_positions = 1;
    for idx = find(sel_msk)
        beat_positions{idx_beat_positions} = qrs_detect(x(idx, :), fs, plt);
        idx_beat_positions = idx_beat_positions + 1;
    end
    
    % Set ECG reference if it is selected as a safe channel.    
    reference = [];
    if sel_msk(1)
        reference = beat_positions{1};
        ecg_reference = true;
    else
        ecg_reference = false;
    end
    
    % Fix delay with respect to reference channel or static delay if no reference selected.
    beat_positions = delay_correction(fs, reference, ecg_reference, beat_positions, desc(sel_msk == 1));
    
    % If more than one channel, cros  s-verify detections.    
    if sum(sel_msk) > 1

        % Allocate mask for verified beats.
        msk_verified = zeros(1, length(beat_positions{1}));
        
        % Verify beats of first safe channel against others.
        beat_positions_fst = beat_positions{1};
        for idx = 1:length(beat_positions_fst)
            val_nxt = beat_positions_fst(idx);

            % Check other channels for similar value.
            flg = true;
            for idx_channel = 2:length(beat_positions)
                channel_vals = beat_positions{idx_channel};
                if ~any(channel_vals > val_nxt - 0.15*fs & channel_vals < val_nxt + 0.15*fs)
                   flg = false;
                   break;
                end

            end
            if flg
               msk_verified(idx) = 1; 
            end
        end
        
        % Select verified beats.
        beat_positions_final = beat_positions_fst(msk_verified == 1);
    else
        beat_positions_final = beat_positions{1};
    end
end
