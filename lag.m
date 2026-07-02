clear; close all; clc;

%% Step 1: System Modeling
% Transfer function
s = tf('s');
G = input('Please enter the transfer function: ');

% Compensator aim
PM = input('Please enter the phase margin: ');
PO = input('Please enter the overshoot: ');
BW = input('Please enter the bandwidth: ');

% Settle the sampling period and phase margin allowance
PMA = input('Please enter the phase margin allowance: ');
T = input('Please enter the sampling period: ');

% Plot the Bode diagram
figure(1);
margin(G);

% A/D conversion
Gz = c2d(G, T, 'zoh');
display(Gz);

%% Step 2: Design the Compensator
PM = PM + PMA;
fprintf('The required phase margin: %.f\n', PM);

% Determine 0dB frequency and the gain margin
wc = input('Please enter 0dB frequency : ');
GM = input('Please enter the gain margin: ');

% Calculate lag factor and corner frequency
a = 10^(GM / 20);
w = 1/10 * wc;

% Compensator designed
Gc = 1/a * tf([1 w], [1 w/a]);
Gcz = c2d(Gc, T, 'matched');
display(Gcz);

%% Step 3: Index Detection
figure(2);
margin(Gz*Gcz);