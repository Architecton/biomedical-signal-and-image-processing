function beat_positions = delay_correction(fs, reference, ecg_reference, beat_positions, desc)
    % function beat_positions = delay_correction(fs, reference, ecg_reference, beat_positions)
    %
    % Correct delay for blood pressure channels. If present, the reference ECG channel is contained in the
    % reference variable. The presence of reference ECG channel is specified by the ecg_reference flag.
    % The parameter beat_positions contains the detected beat positions for
    % all channels. The parameter desc contains cell array of channel
    % descriptions (one for each channel in beat_positions.
    %


    % Compute distances to nearest reference ECG beat positions.
    for idx_channel = 1:size(beat_positions, 2)
        
        % Ignore delay correction for reference channel (if in selection).
        if idx_channel > 1 && ecg_reference
            
            % For each beat in channel, compute distance to closest in reference.
            for idx_beat = 1:length(beat_positions{idx_channel})
                dff = reference - beat_positions{idx_channel}(idx_beat);
                [~, idx_min] = min(abs(dff(dff < 0)));
                if idx_min
                    beat_positions{idx_channel}(idx_beat) = beat_positions{idx_channel}(idx_beat) + dff(idx_min);
                end
            end
        elseif ~ecg_reference
            delay = 0.32;
            if contains(desc{idx_channel}, 'ART')
               delay = 0.32; 
            end
            
            % TODO
            
            beat_positions{idx_channel} = beat_positions{idx_channel} - ceil(fs*delay);
        end
    end
    
end
