clear; clc;

% --- System Parameters ---
L = linspace(10^(-8), 500, 10^5);     % Distance (km)
L_att = 22;                           % Attenuation length (km)
C = 2*10^5;                           % Speed of light in fiber (km/s)
eta_s = 0.712;                        % Source efficiency
eta_d = 0.98;                         % Detector efficiency
eta_OS = 0.99;                        % Optical switch efficiency
P_s = eta_s * eta_d * exp(-L/L_att);  % Photon event probability
P_dc = 10^(-8);                       % Dark count probability
T1 = 10;                              % Relaxation time (s)
T2 = 500 * 10^(-3);                   % Coherence time (s)
alpha = 1;

% Adjust dark count probability with alpha
P_dc = 1 - (1 - P_dc)^alpha;

% --- Custom Color Palette ---
mycolors = [
    1.0 0.0 0.0;      % Red
    0.0 1.0 0.0;      % Green
    0.0 0.0 1.0;      % Blue
    1.0 0.6 0.0;      % Yellow
    0.1 0.9 1.0;      % Cyan
];

% --- Figure Setup ---
h1 = figure;
ax = gca;
ax.ColorOrder = mycolors;
ax.YScale = 'log';    % Set y-axis to logarithmic scale
% title('QKD Key Rate Comparison', 'FontSize', 12);
hold on;
grid on;

% --- MUX Scheme Calculation ---
for n = [2 4 6 8 28]
    
    P_OS = eta_OS^(3*n - 3);                                        % Optical switch transmission probability
    P_tot = 1 - (1 - P_OS .* P_s).^alpha;                           % Total detection probability
    t = (3 * L) / C;                                                % Transmission time
    e_p = (1 - exp(-t/T2)) / 2;                                     % Phase error rate
    e_b = (1 - exp(-t/T1)) / 2;                                     % Bit error rate
    
    % Error rates considering dark counts
    e_p_dc = (e_p .* P_tot + 0.5 * ((1 - P_tot) * P_dc)) ./ (P_tot + (1 - P_tot) * P_dc);
    e_b_dc = (e_b .* P_tot + 0.5 * ((1 - P_tot) * P_dc)) ./ (P_tot + (1 - P_tot) * P_dc);
    
    % Binary entropies for phase and bit errors
    H2p = -(e_p_dc .* log2(e_p_dc) + (1 - e_p_dc) .* log2(1 - e_p_dc));
    H2b = -(e_b_dc .* log2(e_b_dc) + (1 - e_b_dc) .* log2(1 - e_b_dc));
    
    % Raw and final key rate calculation
    mux_raw_key_rate = n * (1 - H2b - H2p);
    mux_raw_key_rate(mux_raw_key_rate < 0) = 0;                     % Floor key rate at 0
    mux_raw_key_rate_final = 0.5 * (P_tot + (1 - P_tot) * P_dc) .* mux_raw_key_rate;
    
    plot(L, mux_raw_key_rate_final, '-', 'LineWidth', 1.5);
    
end

% --- Non-MUX Scheme Calculation ---
for i = [2 4 6 8 28]
    
    mux_key_rate_final = zeros(1, size(L, 2));
    for n = 1:i

        P_tot = 1 - (1 - P_s).^alpha;                               % Total detection probability (no OS loss)
        t = (3 * L) / C + (n - 1) * (2 * L ./ (C * P_tot));         % Time with delay for non-MUX
        e_p = (1 - exp(-t/T2)) / 2;                                 % Phase error rate
        e_b = (1 - exp(-t/T1)) / 2;                                 % Bit error rate
        
        % Error rates considering dark counts
        e_p_dc = (e_p .* P_tot + 0.5 * ((1 - P_tot) * P_dc)) ./ (P_tot + (1 - P_tot) * P_dc);
        e_b_dc = (e_b .* P_tot + 0.5 * ((1 - P_tot) * P_dc)) ./ (P_tot + (1 - P_tot) * P_dc);
        
        % Binary entropies
        H2p = -(e_p_dc .* log2(e_p_dc) + (1 - e_p_dc) .* log2(1 - e_p_dc));
        H2b = -(e_b_dc .* log2(e_b_dc) + (1 - e_b_dc) .* log2(1 - e_b_dc));

        % Raw and final key rate calculation for individual channel
        mux_raw_key_rate = (1 - H2b - H2p);
        mux_raw_key_rate(mux_raw_key_rate < 0) = 0;
        mux_raw_key_rate_final = 0.5 * (P_tot + (1 - P_tot) * P_dc) .* mux_raw_key_rate;
        
        % Accumulate key rates
        mux_key_rate_final = mux_key_rate_final + mux_raw_key_rate_final;

    end
    
    % Average the accumulated key rate over the number of channels
    mux_key_rate_final = mux_key_rate_final / i;
    plot(L, mux_key_rate_final, '--', 'LineWidth', 1.5);
    
end

% --- Plot Formatting and Legend ---
ylim([1e-8, 1e+2]);  % Adjust upper/lower bounds based on data requirements

% Linear domain plotting settings (Commented out in original)
% xlim([0 60]);
% ylim([0, 4.5]);

% Dummy plots for constructing the line style legend
h_solid = plot(nan, nan, 'k-', 'LineWidth', 1.5);
h_dash  = plot(nan, nan, 'k--', 'LineWidth', 1.5);

% Dummy plots mapping to the custom color palette
c2  = plot(nan, nan, 'Color', mycolors(1,:), 'LineWidth', 1.5);
c4  = plot(nan, nan, 'Color', mycolors(2,:), 'LineWidth', 1.5);
c6  = plot(nan, nan, 'Color', mycolors(3,:), 'LineWidth', 1.5);
c8  = plot(nan, nan, 'Color', mycolors(4,:), 'LineWidth', 1.5);
c28 = plot(nan, nan, 'Color', mycolors(5,:), 'LineWidth', 1.5);

% Combine handles and define labels for a single-column legend
h_lgd = [h_solid; h_dash; c2; c4; c6; c8; c28];
labels = {'n-MUX', ...
          '1-MUX', ...
          'n=2', ...
          'n=4', ...
          'n=6', ...
          'n=8', ...
          'n=28'};

legend(h_lgd, labels, ...
       'FontName', 'Times New Roman', ...
       'FontSize', 12, ...
       'Location', 'northeast'); % Can be changed to 'best' if needed

xlabel('Distance (km)', 'FontSize', 14);

ylabel('Secret Key Rate (bits/channel use)', 'FontSize', 14);
