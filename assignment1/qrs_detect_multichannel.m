function beat_positions = qrs_detect_multichannel(x, fs, desc, plt)
    % Detect heart beat positions from signal x with sampling frequency fs.
    % Parameter desc represents a cell array of channel descriptions for
    % each channel in x. The parameter plt specifies whether to plot detections.

    % Get beat positions by merging channels.
    beat_positions = merge_channels(x, fs, desc, plt);
end
