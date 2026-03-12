clear; clc;

% --- System Parameters ---
L = linspace(0, 500, 10^5);          % Distance (km)
L_att = 22;                          % Attenuation length (km)
C = 2*10^5;                          % Speed of light in fiber (km/s)
eta_s = 0.712;                       % Source efficiency
eta_d = 0.98;                        % Detector efficiency
eta_OS = 0.99;                       % Optical switch efficiency
P_s = eta_s * eta_d * exp(-L/L_att); % Photon event probability
P_dc = 10^(-8);                      % Dark count probability
T1 = 10;                             % Relaxation time (s)
T2 = 500 * 10^(-3);                  % Coherence time (s)

% --- Custom Color Palette ---
mycolors = [
    1.0 0.0 0.0;      % Red
%   0.0 1.0 0.0;      % Green (Commented out in original)
%   0.0 0.0 1.0;      % Blue (Commented out in original)
%   1.0 0.6 0.0;      % Yellow (Commented out in original)
%   1.0 0.0 1.0;      % Magenta (Commented out in original)
%   0.0 1.0 1.0;      % Cyan (Commented out in original)
%   0.5 0.5 1.0;      % Purple (Commented out in original)
%   0.0 0.0 0.0       % Black (Commented out in original)
];

% --- Figure Setup ---
h1 = figure;
ax = gca;
ax.ColorOrder = mycolors;
ax.YScale = 'log';                   % Set y-axis to logarithmic scale
% title('QKD Key Rate Comparison', 'FontSize', 12);
hold on;
grid on;

% --- 28-MUX Scheme Calculation ---
bandwidth = 10;
N = 1400;
n = 28;
r = N / (n * bandwidth);
mux_key_rate_final = zeros(1, size(L, 2));

for i = 1:r
    
    P_OS = eta_OS^(3*n - 3);                                        % Optical switch transmission probability
    t = (3 * L) / C + (r - i) * (2 * L ./ (C * (P_OS * P_s)));      % Time cost considering delay
    e_p = (1 - exp(-t/T2)) / 2;                                     % Phase error rate
    e_b = (1 - exp(-t/T1)) / 2;                                     % Bit error rate
    
    % Error rates considering dark counts
    e_p_dc = (e_p .* (P_OS * P_s) + 0.5 * ((1 - (P_OS * P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS * P_s)) * P_dc);
    e_b_dc = (e_b .* (P_OS * P_s) + 0.5 * ((1 - (P_OS * P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS * P_s)) * P_dc);
    
    % Binary entropies for phase and bit errors
    H2p = -(e_p_dc .* log2(e_p_dc) + (1 - e_p_dc) .* log2(1 - e_p_dc));
    H2b = -(e_b_dc .* log2(e_b_dc) + (1 - e_b_dc) .* log2(1 - e_b_dc));

    % Raw and final key rate calculation
    mux_raw_key_rate = n * bandwidth * (1 - H2b - H2p);
    mux_raw_key_rate(mux_raw_key_rate < 0) = 0;                     % Floor key rate at 0
    mux_raw_key_rate_final = 0.5 * ((P_OS * P_s) + (1 - (P_OS * P_s)) * P_dc) .* mux_raw_key_rate;
    
    % Accumulate key rates
    mux_key_rate_final = mux_key_rate_final + mux_raw_key_rate_final;
    % mux_key_rate_final = mux_key_rate_final / (10 * r);           % Commented out in original
    
end

% Average the final key rate
mux_key_rate_final = mux_key_rate_final / (10 * r);
plot(L, mux_key_rate_final, '-', 'LineWidth', 1.5);

% --- 1-MUX Scheme Calculation ---
i = N / bandwidth;                   % Overwriting 'i' as upper limit for the next loop
mux_key_rate_final = zeros(1, size(L, 2));

for m = 1:i
    
    t = (3 * L) / C + (m - 1) * (2 * L ./ (C * P_s));               % Transmission time with delay
    e_p = (1 - exp(-t/T2)) / 2;                                     % Phase error rate
    e_b = (1 - exp(-t/T1)) / 2;                                     % Bit error rate
    
    % Error rates considering dark counts
    e_p_dc = (e_p .* P_s + 0.5 * ((1 - P_s) * P_dc)) ./ (P_s + (1 - P_s) * P_dc);
    e_b_dc = (e_b .* P_s + 0.5 * ((1 - P_s) * P_dc)) ./ (P_s + (1 - P_s) * P_dc);
    
    % Binary entropies
    H2p = -(e_p_dc .* log2(e_p_dc) + (1 - e_p_dc) .* log2(1 - e_p_dc));
    H2b = -(e_b_dc .* log2(e_b_dc) + (1 - e_b_dc) .* log2(1 - e_b_dc));

    % Raw and final key rate calculation
    mux_raw_key_rate = bandwidth * (1 - H2b - H2p);
    mux_raw_key_rate(mux_raw_key_rate < 0) = 0;                     % Floor key rate at 0
    mux_raw_key_rate_final = 0.5 * (P_s + (1 - P_s) * P_dc) .* mux_raw_key_rate;
    
    % Accumulate key rates
    mux_key_rate_final = mux_key_rate_final + mux_raw_key_rate_final;

end

% Average the final key rate
mux_key_rate_final = mux_key_rate_final / (10 * i);
plot(L, mux_key_rate_final, '--', 'LineWidth', 1.5);

% --- Plot Formatting and Legend ---
ylim([1e-8, 1e+2]);                  % Adjust upper/lower bounds based on data requirements

% Linear domain plotting settings (Commented out in original)
% xlim([0 60]);                      
% ylim([0, 2.5]);                    

legend('28-MUX', '1-MUX', 'FontName', 'Times New Roman', 'FontSize', 12);
xlabel('Distance (km)', 'FontSize', 14);
ylabel('Secret Key Rate (bits/channel use)', 'FontSize', 14);