clear; close all; clc;

%% Step 1: System Modeling
% Transfer function
s = tf('s');
G = input('Please enter the transfer function: ');

% Compensator aim
PO = input('Please enter the overshoot: ');
ts = input('Please enter the settlingtime: ');

% Settle the sampling period
T = input('Please enter the sampling period: ');

% A/D conversion
Gz = c2d(G, T, 'zoh');
display(Gz);

% Damping ratio and natural frequency
zeta = -log(PO/100) / sqrt(pi^2 + (log(PO/100))^2);
wn = 4 / ts / zeta;

% Calculate expected dominant closed-loop poles
s_d = -zeta*wn + i*wn*sqrt(1-zeta^2); % Complex conjugates
fprintf('Expected dominant closed-loop poles: %.4f + %.4fi\n', real(s_d), imag(s_d));

%% Step 2: Design the Compensator
[z,p,k] = zpkdata(G, 'v');
angle_sum = -180;

for i = 1:length(z) % Cumulative zero angles
    angle_z = rad2deg(angle(s_d - z(i)));
    angle_sum = angle_sum - angle_z;
end

for j = 1:length(p) % Cumulative pole angles
    angle_p = rad2deg(angle(s_d - p(j)));
    angle_sum = angle_sum + angle_p;
end

fprintf('The sum of original angles is: %.4f\n', angle_sum);
figure(1);
rlocus(G);

% Choose a zero, then calculate the pole
z_c = input('Please enter a zero after plotting the root loci: ');
angle_sum = angle_sum - rad2deg(angle(s_d - z_c));
p_c = real(s_d) - imag(s_d) / tand(-angle_sum);

% Calculate the compensated gain
z = [z; z_c];
p = [p; p_c];

len_z = prod(abs(s_d - z)); % Cumulative zero modules
len_p = prod(abs(s_d - p)); % Cumulative pole modules

kc = 1 / (k * len_z / len_p);
Gc = kc * tf([1 -z_c], [1 -p_c]);

m = input('Enter the transformation method: ', 's');
Gcz = c2d(Gc, T, m); % Compensator designed
display(Gcz);

%% Step 3: Closed-loop Simulink
% Define closed-loop transfer function
Gcl = feedback(Gz * Gcz, 1);

% Plot step response and extract the info
figure(2);
step(Gcl);
display(stepinfo(Gcl));