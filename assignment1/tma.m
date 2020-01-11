function res = tma(x, omega, alpha)
    % Trimmed moving average filter implementation.
    % Parameter x represents the signal. 
    % Parameter omega represents length of window.

    % Add padding to input signal.
    res = [zeros(1,omega/2), x, zeros(1,omega/2)];
    k = ceil(omega*alpha/2);
    
    % Apply filtering.
    for idx = 1+omega/2:length(res)-omega/2
        sorted = sort(res(idx-omega/2:idx+omega/2));
        res(idx) = 1/(omega - 2*k)*sum(sorted(k+1:omega-k));
    end
    
    % Remove padding from output signal.
    res = res(omega/2+1:end-omega/2);
end
