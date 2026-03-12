clear; clc;

% =========================================================================
% --- MDI Protocol Calculation ---
% =========================================================================

% --- System Parameters (MDI) ---
L = linspace(0, 500, 10^5);          % Distance (Alice/Bob to Charlie) (km)
L_att = 44;                          % Attenuation length (km)
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
%   1.0 0.0 1.0;      % Magenta (Commented out in original)
%   0.1 0.9 1.0;      % Cyan (Commented out in original)
%   0.5 0.5 1.0;      % Purple (Commented out in original)
%   0.0 0.0 0.0       % Black (Commented out in original)
];

% --- Figure Setup ---
h1 = figure;
ax = gca;
ax.ColorOrder = mycolors;
% ax.NextPlot = 'add';               % Similar to 'hold on'
ax.YScale = 'log';                   % Set y-axis to logarithmic scale
% title('SDI-QKD vs QKD', 'FontSize', 12);
hold on;
grid on;

for n = [2 4 6 8]

    P_OS = eta_OS^(3*n - 3);                                         % Optical switch transmission probability
    t_A = (2 * L) ./ C + (1 * L) ./ (C * P_s);                       % Time for Alice
    t_B = (2 * L) ./ C;                                              % Time for Bob
    
    % Error rates
    e_p_AC = (1 - exp(-t_A/T2)) / 2;                                 % Phase error rate (Alice-Charlie)
    e_b_AC = (1 - exp(-t_A/T1)) / 2;                                 % Bit error rate (Alice-Charlie)
    e_p_BC = (1 - exp(-t_B/T2)) / 2;                                 % Phase error rate (Bob-Charlie)
    e_b_BC = (1 - exp(-t_B/T1)) / 2;                                 % Bit error rate (Bob-Charlie)
    
    % Error rates considering dark counts
    e_p_AC_dc = (e_p_AC .* (P_OS .* P_s) + 0.5 * ((1 - (P_OS .* P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS .* P_s)) * P_dc);
    e_b_AC_dc = (e_b_AC .* (P_OS .* P_s) + 0.5 * ((1 - (P_OS .* P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS .* P_s)) * P_dc);
    e_p_BC_dc = (e_p_BC .* (P_OS .* P_s) + 0.5 * ((1 - (P_OS .* P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS .* P_s)) * P_dc);
    e_b_BC_dc = (e_b_BC .* (P_OS .* P_s) + 0.5 * ((1 - (P_OS .* P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS .* P_s)) * P_dc);
    
    % Combined error rates
    e_p_dc = e_p_AC_dc + e_p_BC_dc - 2 .* e_p_AC_dc .* e_p_BC_dc;
    e_b_dc = e_b_AC_dc + e_b_BC_dc - 2 .* e_b_AC_dc .* e_b_BC_dc;
            
    % Error composition under entanglement swapping
    H2p = -(e_p_dc .* log2(e_p_dc) + (1 - e_p_dc) .* log2(1 - e_p_dc));
    H2b = -(e_b_dc .* log2(e_b_dc) + (1 - e_b_dc) .* log2(1 - e_b_dc));

    % Raw and final key rate calculation
    mux_raw_key_rate = n * (1 - H2b - H2p);
    mux_raw_key_rate(mux_raw_key_rate < 0) = 0;                      % Floor key rate at 0
    mux_raw_key_rate_final = 1 * ((P_OS .* P_s + (1 - (P_OS .* P_s)) .* P_dc) .* mux_raw_key_rate);
    % mux_raw_key_rate_final = mux_raw_key_rate_final * 10^8;
    
    plot(L, mux_raw_key_rate_final, '-', 'LineWidth', 1.5);
    
end


% =========================================================================
% --- Lo-Chau Protocol Calculation ---
% =========================================================================

% --- System Parameters (Lo-Chau) ---
L = linspace(0, 500, 10^5);          % Distance (km)
L_att = 22;                          % Attenuation length (km) (Updated for Lo-Chau)
C = 2*10^5;                          % Speed of light in fiber (km/s)
eta_s = 0.712;                       % Source efficiency
eta_d = 0.98;                        % Detector efficiency
eta_OS = 0.99;                       % Optical switch efficiency
P_s = eta_s * eta_d * exp(-L/L_att); % Photon event probability
P_dc = 10^(-8);                      % Dark count probability
T1 = 10;                             % Relaxation time (s)
T2 = 500 * 10^(-3);                  % Coherence time (s)

for n = [2 4 6 8]
    
    P_OS = eta_OS^(3*n - 3);                                         % Optical switch transmission probability
    t = (3 * L) / C;                                                 % Time
    e_p = (1 - exp(-t/T2)) / 2;                                      % Phase error rate
    e_b = (1 - exp(-t/T1)) / 2;                                      % Bit error rate
    
    % Error rates considering dark counts
    e_p_dc = (e_p .* (P_OS * P_s) + 0.5 * ((1 - (P_OS * P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS * P_s)) * P_dc);
    e_b_dc = (e_b .* (P_OS * P_s) + 0.5 * ((1 - (P_OS * P_s)) * P_dc)) ./ (P_OS * P_s + (1 - (P_OS * P_s)) * P_dc);
    
    % Binary entropies
    H2p = -(e_p_dc .* log2(e_p_dc) + (1 - e_p_dc) .* log2(1 - e_p_dc));
    H2b = -(e_b_dc .* log2(e_b_dc) + (1 - e_b_dc) .* log2(1 - e_b_dc));

    % Raw and final key rate calculation
    mux_raw_key_rate = n * (1 - H2b - H2p);
    mux_raw_key_rate(mux_raw_key_rate < 0) = 0;                      % Floor key rate at 0
    mux_raw_key_rate_final = 1 * ((P_OS * P_s) + (1 - (P_OS * P_s)) * P_dc) .* mux_raw_key_rate;
    % mux_raw_key_rate_final = mux_raw_key_rate_final * 10^8;
    
    plot(L, mux_raw_key_rate_final, '--', 'LineWidth', 1.5);
    
end

% --- Plot Formatting and Legend ---
ylim([1e-8, 1e+2]);                  % Adjust upper/lower bounds based on data requirements
xlim([0, 650]);                      % Extend x-axis limit to 650

% Linear domain plotting settings (Commented out in original)
% xlim([0 60]);
% ylim([0, 4.5]);

% Dummy plots for constructing the line style legend
h_solid = plot(nan, nan, 'k-', 'LineWidth', 1.5);
h_dash  = plot(nan, nan, 'k--', 'LineWidth', 1.5);

% Dummy plots mapping to the custom color palette
c2 = plot(nan, nan, 'Color', mycolors(1,:), 'LineWidth', 1.5);
c4 = plot(nan, nan, 'Color', mycolors(2,:), 'LineWidth', 1.5);
c6 = plot(nan, nan, 'Color', mycolors(3,:), 'LineWidth', 1.5);
c8 = plot(nan, nan, 'Color', mycolors(4,:), 'LineWidth', 1.5);

% --- Display Single-Column Legend ---
h_lgd = [h_solid; h_dash; c2; c4; c6; c8];
labels = {'n-MUX MDI', ...
          'n-MUX Lo-Chau', ...
          'n=2', ...
          'n=4', ...
          'n=6', ...
          'n=8'};

legend(h_lgd, labels, ...
       'FontName', 'Times New Roman', ...
       'FontSize', 12, ...
       'Location', 'northeast');     % Can be changed to 'best' if needed

xlabel('Distance (km)', 'FontSize', 14);

ylabel('Secret Key Rate (bits/channel use)', 'FontSize', 14);
