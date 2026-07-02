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
PPM = input('Please enter the original phase margin: ');
PM = PM + PMA - PPM;
fprintf('The required phase margin: %.f\n', PM);

% Calculate lead factor and corner frequency
b = (1 - sind(PM)) / (1 + sind(PM));
GM = 1/sqrt(b);
wmax = input('Please enter the maximum frequency: ');
w = wmax / GM;
kc = sqrt(b) / abs(evalfr(G, wmax*i));

% Compensator designed
Gc = kc * 1/b * tf([1 w], [1 w/b]);
Gcz = c2d(Gc, T, 'matched');
display(Gcz);

%% Step 3: Index Detection
figure(2);
margin(Gz*Gcz);

% Plot step response and extract the info
Gcl = feedback(Gz * Gcz, 1);
figure(3);
step(Gcl);
display(stepinfo(Gcl));