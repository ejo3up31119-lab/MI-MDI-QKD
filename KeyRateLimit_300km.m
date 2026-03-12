clear; clc;

% --- System Parameters ---
L = 300;                             % Distance (km)
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
    0.0 1.0 0.0;      % Green
    0.0 0.0 1.0;      % Blue
    1.0 0.6 0.0;      % Yellow
    1.0 0.0 1.0;      % Magenta
    0.0 1.0 1.0;      % Cyan
    0.5 0.5 1.0;      % Purple
    0.0 0.0 0.0       % Black
];

% --- Figure Setup ---
h1 = figure;
ax = gca;
ax.ColorOrder = mycolors;
% ax.NextPlot = 'add';               % Similar to 'hold on'
% ax.YScale = 'log';                 % Set y-axis to logarithmic scale
% title('QKD Key Rate Comparison', 'FontSize', 12);
hold on;
grid on;

% --- Rate Ratio Calculation ---
key_rate_ratio = zeros(1, 22);
mux_raw_key_rate_final_1 = 1;        % Initial reference value

for n = 19:40
    
    P_OS = eta_OS^(3*n - 3);                                     % Optical switch transmission probability
    t = (3 * L) / C;                                             % Transmission time
    e_p = (1 - exp(-t/T2)) / 2;                                  % Phase error rate
    e_b = (1 - exp(-t/T1)) / 2;                                  % Bit error rate
    
    % Error rates considering dark counts
    e_p_dc = (e_p .* (P_OS * P_s) + 0.5 * ((1 - (P_OS * P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS * P_s)) * P_dc);
    e_b_dc = (e_b .* (P_OS * P_s) + 0.5 * ((1 - (P_OS * P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS * P_s)) * P_dc);
    
    % Binary entropies for phase and bit errors
    H2p = -(e_p_dc .* log2(e_p_dc) + (1 - e_p_dc) .* log2(1 - e_p_dc));
    H2b = -(e_b_dc .* log2(e_b_dc) + (1 - e_b_dc) .* log2(1 - e_b_dc));

    % Raw and final key rate calculation
    mux_raw_key_rate = n * (1 - H2b - H2p);
    mux_raw_key_rate(mux_raw_key_rate < 0) = 0;                  % Floor key rate at 0
    mux_raw_key_rate_final = 0.5 * ((P_OS * P_s) + (1 - (P_OS * P_s)) * P_dc) .* mux_raw_key_rate;
    
    % Calculate and store the ratio
    key_rate_ratio(1, n - 18) = mux_raw_key_rate_final / mux_raw_key_rate_final_1;
    mux_raw_key_rate_final_1 = mux_raw_key_rate_final;           % Update reference value for next iteration
    
end

% Extract the valid ratios corresponding to n = 20 to 40
key_rate_ratio = key_rate_ratio(2:22);

% --- Plotting ---
plot(20:40, key_rate_ratio, '-s', 'LineWidth', 1.5, ...
     'MarkerSize', 6, 'MarkerFaceColor', 'auto', 'MarkerEdgeColor', 'auto');

% --- Optional Plot Formatting ---
% ylim([1e-8, 1e+1]);                % Adjust upper/lower bounds based on data requirements (e.g., 1, 1e-1, 1e0)
% xlim([250 300]);                   % For Linear Domain Plot
% ylim([1e-4, 4]);                   % For Linear Domain Plot

% legend('2-MUX', '4-MUX', '6-MUX', '8-MUX', '16-MUX', '32-MUX', '36-MUX', '40-MUX', 'FontName', 'Times New Roman', 'FontSize', 12);
xlabel('n', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('r_n', 'FontName', 'Times New Roman', 'FontSize', 14);