%----------------------------------------------------------------------
% Title: Signal Processing Code in Matlab
% Author: Gabriel Galeote Checa
% Last update: 21/04/2022
% This code is a signal processing code for ecg 
%----------------------------------------------------------------------
clear all;
close all;

% 1 - Load ecg signal
% Load "e1071230.MAT", remove dc component and graphic representation

% load('100m.mat');
 %ECG_1 = load('100m.mat');
 %ECG_1 = ECG_1.val(1,:);

load ('ECG_exp_pac_1.txt');
ECG_1=ECG_exp_pac_1;


%ECG_1 = 100m;

% Calculate the length of the sequence
n_samples = length (ECG_1);

% Sampling frequency
Fs = 360; 

% Sampling period
Ts = 1 / Fs; 

% Representation number of points
t = 0:Ts:(n_samples-1)/Fs;

% remove DC
ECG_no_DC = ECG_1 - mean (ECG_1);

% number of samples
n_samples = length (ECG_no_DC);

signal_fft = fft (ECG_no_DC,n_samples); 

% calculate magnitude of the fft
magnitude = abs (signal_fft); 

% X axis calculation
x_axis = linspace (0,Fs-(Fs/n_samples),n_samples); 

figure(1); subplot(2,1,1); 
plot (t, ECG_no_DC); grid on;
title('Representation of the ECG without DC')
xlabel ('Time (s)'); ylabel ('Amplitude (mV)');

figure(1); subplot(2,1,2);
plot (x_axis(1:(n_samples/2)+1), magnitude(1:(n_samples/2)+1)); grid on;
title ('FFT representation of the signal without DC');
xlabel ('Frequency (Hz)');ylabel('|Magnitude|');

% ---------------------------------------------

% Low pass filter

Fpass = 21;          % Passband Frequency
Fstop = 31;          % Stopband Frequency
Apass = 0.1;          % Passband Ripple (dB)
Astop = 30;          % Stopband Attenuation (dB)
match = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h1  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
H1 = design(h1, 'cheby2', 'MatchExactly', match);

% High Pass filter 

Fstop = 1;           % Stopband Frequency
Fpass = 9;           % Passband Frequency
Astop = 30;          % Stopband Attenuation (dB)
Apass = 1;         % Passband Ripple (dB)
match = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h2  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
H2 = design(h2, 'cheby2', 'MatchExactly', match);

% Signal Filtering
ECG_filtrado1 = filter (H1,ECG_no_DC);
ECG_filtrado2 = filter (H2,ECG_filtrado1);

signal_fft_1 = fft(ECG_filtrado1 ,n_samples);
signal_fft_2 = fft(ECG_filtrado2 ,n_samples);

% Calculate abs of the signal
magnitude1 = abs(signal_fft_1);
magnitude2 = abs(signal_fft_2);

figure(2); subplot(2,1,1);
plot(t,ECG_filtrado1); grid on;
title('ECG filtered with the low pass');
xlabel ('Time (s)'); ylabel ('Amplitude (mV)');

figure(2); subplot(2,1,2);
plot(x_axis(1:(n_samples/8)+1), magnitude1(1:(n_samples/8)+1)); grid on;
title ('magnitude ECG filtered');
xlabel ('Frequency (Hz)');ylabel ('|magnitude|');

% -----------------------------
figure(3); subplot(2,1,1);
plot(t,ECG_filtrado2); grid on;
title('ECG filtered by high pass');
xlabel ('Time (s)'); ylabel ('Amplitude (mV)');

figure(3); subplot(2,1,2);
plot(x_axis(1:(n_samples/8)+1), magnitude2(1:(n_samples/8)+1)); grid on;
title ('magnitude ECG filtrado');
xlabel ('Frequency (Hz)');ylabel ('|magnitude|');
