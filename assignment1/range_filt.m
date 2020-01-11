function res = range_filt(x, omega)
    % Range filter implementation. Parameter x represents
    % the signal. Parameter omega represents length of window.

    % Pad and copy signal.
    padded_x = [zeros(1, omega/2), x, zeros(1, omega/2)];
    res = padded_x;
    
    % Apply filter.
    for idx = 1 + omega/2:length(padded_x)-omega/2
        res(idx) = max(padded_x(idx-omega/2:idx+omega/2)) - min(padded_x(idx-omega/2:idx+omega/2));
    end
    
    % Remove padding from output signal. 
    res = res(omega/2+1:end-omega/2);

    % Remove artifacts due to padding.
    res(1:omega/2) = 0;
    res(end-omega/2:end) = 0;
end
