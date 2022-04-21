% % Pam Tompkins implementation for ecg beat detection
% Author: Gabriel Galeote Checa
% Clean Workspace
clear all
close all

% 1 - Load ECG signal from external file

% Load file from the data base
%ECG_1 = load('A00001m.mat');
%ECG_1 = ECG_1.val(1,:);

load ('ECG_exp_pac_4.txt');
ECG_1=ECG_exp_pac_4;

% (optional) Invert signal in case the polarization of the electrodes is not the correct
ECG_1 = ECG_1*(-1); 

% Calulate length of the signal
samples = length (ECG_1);

% Representation interval for the signal in samples units
m = 0:(samples-1);

% Sampling Frequency
Fs=54;

% Signal resolution
Ts = 1 / Fs;

% representation time interval
t = 0:Ts:(samples-1)/Fs;

% Scale factor of the vector from 0 to 35 Hz
scaling=Fs/35;

% 2 - Remove DC component (offset)

ECG_sindc=ECG_1-mean(ECG_1);

% 3.- Compute FFT

% Compute FFT of the ECG signal without DC
senal_fft = fft (ECG_sindc,samples);

% Magnitude of the FFT
magnitude = abs (senal_fft);

% Calculate X-axis
x_axis = linspace (0,Fs-(Fs/samples),samples);

% Figura 1, subplot 2
figure(1); subplot(2,1,1);
plot (t, ECG_sindc); grid on;
title('ECG without DC')
xlabel ('Time (s)'); ylabel ('Amplitude (mV)');

figure (1); subplot(2,1,2);
plot (x_axis(1:(samples/2)+1), magnitude(1:(samples/2)+1)); grid;
title ('FFT of the ECG without DC');
xlabel ('Frequency (Hz)');ylabel('|Magnitude| (mV)');


% 4 - Represent signal from 0 to 35 Hz

figure(2); subplot(2,1,1);
plot (t, ECG_sindc); grid on;
title('ECG without DC')
xlabel ('Time (s)'); ylabel ('Amplitude (mV)');

figure(2); subplot(2,1,2);
plot(x_axis(1:(samples/scaling)+1),magnitude(1:(samples/scaling)+1));
grid on;
title ('FFT of the signal without DC');
xlabel ('Frquency (Hz)');ylabel('|Magnitude| (mV)');

% ---------------------------------------------

% Low Pass Filter

Fpass = 14;          % Passband Frequency
Fstop = 20;          % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 30;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h2  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
H2 = design(h2, 'butter', 'MatchExactly', match);


% High Pass filter 

Fstop = 1;           % Stopband Frequency
Fpass = 6;           % Passband Frequency
Astop = 60;          % Stopband Attenuation (dB)
Apass = 1;         % Passband Ripple (dB)
match = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h1  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
H1 = design(h1, 'cheby2', 'MatchExactly', match);

% Filter
ecg_filtered_1 = filter (H1,ECG_sindc);
ecg_filtered_2 = filter (H2,ecg_filtered_1);

ECGFFT1 = fft(ecg_filtered_1 ,samples);
ECGFFT2 = fft(ecg_filtered_2 ,samples);

magnitude1 = abs(ECGFFT1);
magnitude2 = abs(ECGFFT2);

% Inverse fourier transform
ECGIFFT1 = ifft(ecg_filtered_1);
ECGIFFT2 = ifft(ecg_filtered_2);

% ----------------------------
figure(3); subplot(2,1,1);
plot(t,ecg_filtered_1); grid on;
title('High pass filter of the ECG');
xlabel ('Time (s)'); ylabel ('Amplitude (mV)');

figure(3); subplot(2,1,2);
plot(x_axis(1:(samples/2)+1), magnitude1(1:(samples/2)+1)); grid on;
title('High pass filtered FFT of the ECG');
xlabel ('Frequency (Hz)');ylabel ('|Magnitude|');

% -----------------------------
figure(4); subplot(2,1,1);
plot(t,ecg_filtered_2); grid on;
title('Low pass filter of the ECG');
xlabel ('Time (s)'); ylabel ('Amplitude (mV)');

figure(4); subplot(2,1,2);
plot(x_axis(1:(samples/2)+1), magnitude2(1:(samples/2)+1)); grid on;
title('Low pass filtered FFT of the ECG');
xlabel ('Frequency (Hz)');ylabel ('|Magnitude|');

% 5 - Derivative of the signal

w = 0:2*pi/samples:2*pi-(2*pi/samples);

H3 = (5.0 + 4.0.*exp(-1i*w) + 3.0.*exp(-1i*w*2) + 2.0.*exp(-1i*w*3)...
    + exp(-1i*w*4)- 1.0.*exp(-1i*w*6) - 2.0.*exp(-1i*w*7) - ...
    3.0.*exp(-1i*w*8) - 4.0.*exp(-1i*w*9) - 5.0.*exp(-1i*w*10)) / 110.0;

% Normalization of the filter
H3_norm = H3./max(abs(H3));

% Multiplate sample by sample in frequency
ECGFFT3 = ECGFFT2.*H3_norm;

ECGIFFT3 = ifft(ECGFFT3,samples);

% Figure 5
figure (5); subplot (2,1,1); 
plot (t,real(ECGIFFT3)); grid on;
title('ECG filtered by filter H5 (derivative)');
xlabel ('Time (s)'); ylabel ('Amplitude (mV)');

figure (5); subplot (2,1,2);
plot(x_axis(1:samples/scaling),abs(ECGFFT3(1:samples/scaling)));
grid on;
title('ECG FFT filtered by the filter  H5 (derivative)');
xlabel ('Frequency (Hz)'); ylabel ('|Magnitude| (mV)');

% 6 - Square the signal sample by sample

ECGIFFT4 = ECGIFFT3.^2; 

% Figure 6
figure(6);
subplot (2,1,1); plot (t,real(ECGIFFT4)); grid on;
title('ECG squared and filtered by H5');
xlabel ('Time (s)');
ylabel ('Amplitude (mV)');

% 9 - Signal integration window 

% Window time, by default 150 ms
window = 0.150;

% window number of samples
samples_window = ceil(Fs*window);

a = 1;
c=zeros(1,samples_window);
b = c+(1/samples_window);
ECG_integ = filter (b,a,ECGIFFT4);

% Figura 6, subplot 2
figure (6); subplot (2,1,2);
plot (t,real(ECG_integ));grid on;
title ('ECG filtered by H5, squared and integrated');
xlabel('Time (s)'); ylabel('Amplitude (mV)');

% 10 - QRS detection

% Training time
entren = 1;

ECG_integ = real(ECG_integ);

% spki will be 1/3 from the maximum of the signal integrated in the training time
spki = max (ECG_integ(1:entren*Fs)) / 3;

% npki will be the half of the mean on the integrated signal
npki = mean (ECG_integ(1:entren*Fs)) / 2;

% Initialize the threshold "thri1" that will check if the peak is noise (<= thri1) or signal (> thri1)
thri1 = npki +0.25*(spki-npki);

% Find peaks of the integrated signal
[pks,loc] = findpeaks(abs(ECG_integ));

QRS = zeros(1,samples);

thrs = zeros(1,samples);
spks = zeros(1,samples);
npks = zeros(1,samples);

% loop
for i = 1:length(pks)
    if(pks(i)>thri1) % is a peak
        spki = 0.125*pks(i)+0.875*spki;  % update spki
        QRS(loc(i))= 0.5*max(abs(ECG_integ));
        
    else
        % noise, then update npki
        npki = 0.125*pks(i)+0.875*npki;
    end
    thri1 = npki+0.25*(spki-npki);
    thrs(loc(i)) = thri1;
    spks(loc(i)) = spki;
    npks(loc(i)) = npki;
end;

% Figure 7, subplot 1
QRS_positivos = find(QRS > 0);

figure (7); subplot(2,1,1);
plot (t,ECG_integ); grid on;hold on;

plot(t(QRS_positivos),QRS(QRS_positivos),'m^');hold on;

thrs_positivos = find(thrs > 0);
plot(t(thrs_positivos), thrs(thrs_positivos), '*r'); hold on;

spks_positivos = find(spks > 0);
plot(t(spks_positivos),spks(spks_positivos), 'g+');hold on;

npks_positivos = find(npks > 0);
plot(t(npks_positivos),npks(npks_positivos), 'k.'); hold on;

legend('Signal','QRS','THRESHOLD I1','SPKI','NPKI');
title('ECG integrated + thri1 + spki + npki + QRS original');
xlabel('Time (s)'); ylabel('Amplitude (mV)');

% Figura 7, subplot 2
% Dibujamos la ECG sin DC para comprobar los sitios donde hay 
% complejos QRS
figure (7); subplot(2,1,2); plot(t,ECG_1);grid on;
title('ECG no DC');
xlabel('Time (s)'); ylabel('Amplitude (mV)');

% Algorithm improvement

samples_between_peaks = Fs*0.2;

[pks2,loc2] = findpeaks(ECG_integ,'MINPEAKDISTANCE',samples_between_peaks);

maxs = zeros(1,samples);
thrs_2 = zeros(1,samples);
spks_2 = zeros(1,samples);
npks_2 = zeros(1,samples);

for i = 1:length(pks2)
    if(pks2(i)>thri1)
        spki = 0.125*pks2(i)+0.875*spki;
        maxs(loc2(i)) = 0.5*max(abs(ECG_integ));
    else
        npki = 0.125*pks2(i)+0.875*npki;
    end
    thri1 = npki+0.25*(spki-npki);
    thrs_2(loc2(i))=thri1;
    spks_2(loc2(i)) = spki;
    npks_2(loc2(i)) = npki;
end
% Figure 8, subplot 1
% Plot integrated signal, the vector QRS, the vector THRI1, 
% the vector SPKI and the vector NPKI in a subplot by a hold on
maxs_posi=find(maxs > 0);

figure (8); subplot(2,1,1);
plot (t,ECG_integ); grid on; hold on;
plot(t(maxs_posi),maxs(maxs_posi),'m^'); hold on;

thrs_positives_2 = find(thrs_2 > 0);
plot(t(thrs_positives_2), thrs_2(thrs_positives_2), '*r');hold on;

spks_positives = find(spks_2 > 0);
plot(t(spks_positives),spks_2(spks_positives), 'g+');hold on;

npks_positives = find(npks_2 > 0);
plot(t(npks_positives),npks_2(npks_positives), 'k.'); hold on;

legend('SIGNAL','QRS','THRESHOLD I1','SPKI','NPKI');
title('ECG integrated + thri1 + spki + npki + QRS in the first improvement');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

% Figure 8, subplot 2
% Graphic representation of the ECG without DC 

figure (8);subplot(2,1,2);
plot (t,ECG_1); grid on;
title('ECG no DC');
xlabel('Time (s)'); ylabel('Amplitude (mV)');

% --------------------------------------
%          Statistics
% --------------------------------------

QRSdetected = findpeaks(maxs);

ntotalQRS = length(QRSdetected);

time = (samples/Fs); % in seconds
time_minutes = time / 60; % in minutes

cardiac_frequency = ntotalQRS/(time_minutes);
