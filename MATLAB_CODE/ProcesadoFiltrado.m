%----------------------------------------------------------------------
% Título: Código de Procesamiento de datos mediante MATLAB
% Autor: Gabriel Galeote Checa
% Fecha: XX/XX/XXXX
% En este código se realiza el desarrollo de la parte de proesamiento de
% datos obtenidos a partir de una lectura del electrocardiógrafo.
%----------------------------------------------------------------------
clear all;
close all;

% 1.- Señal de ECG
% En este apartado se va a cargar el ECG "e1071230.MAT", eliminar la componente de continua,
% y representarlo gráficamente en función del tiempo y de la frecuencia.

% load('100m.mat'); % Cargamos el fichero con el ECG.
 %ECG_1 = load('100m.mat'); % Cargamos el fichero con el ECG.
 %ECG_1 = ECG_1.val(1,:);

load ('ECG_exp_pac_1.txt');
ECG_1=ECG_exp_pac_1;


%ECG_1 = 100m;% Definimos ECG_1 como la variable de entrada con el ECG.

% Cálculo de la longitud de la secuencia
longitud = length (ECG_1);

% frec. de muestreo
Fs = 360; 

% Periodo de muestreo
Ts = 1 / Fs; 

% Creamos el intervalo de representación de la señal, en muestras
t = 0:Ts:(longitud-1)/Fs;

% A continuación, se elimina la componente de continua.
ECG_sin_DC = ECG_1 - mean (ECG_1);

% Número de muestras de la señal
longitud = length (ECG_sin_DC);

% obtención de la señal fft
senal_fft = fft (ECG_sin_DC,longitud); 

% cálculo de la magnitud a parte de la señal fft
Magnitud = abs (senal_fft); 

%Cálculo del eje X para la representación en frecuencia
EjeX = linspace (0,Fs-(Fs/longitud),longitud); 

figure(1); subplot(2,1,1); 
plot (t, ECG_sin_DC); grid on;
title('Representación de ECG sin nivel de continua')
xlabel ('Tiempo (s)'); ylabel ('Tensión (mV)');

figure(1); subplot(2,1,2);
plot (EjeX(1:(longitud/2)+1), Magnitud(1:(longitud/2)+1)); grid on;
title ('Representación en Frecuencia del ECG sin nivel de continua');
xlabel ('Frecuencia (Hz)');ylabel('|Magnitud|');

% ---------------------------------------------

% Filtro pasa baja

Fpass = 21;          % Passband Frequency
Fstop = 31;          % Stopband Frequency
Apass = 0.1;          % Passband Ripple (dB)
Astop = 30;          % Stopband Attenuation (dB)
match = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h1  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
H1 = design(h1, 'cheby2', 'MatchExactly', match);

% Filtro pasa alta 

Fstop = 1;           % Stopband Frequency
Fpass = 9;           % Passband Frequency
Astop = 30;          % Stopband Attenuation (dB)
Apass = 1;         % Passband Ripple (dB)
match = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h2  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
H2 = design(h2, 'cheby2', 'MatchExactly', match);

% Filtrado de la señal
ECG_filtrado1 = filter (H1,ECG_sin_DC);
ECG_filtrado2 = filter (H2,ECG_filtrado1);

% Dibujo la señal ECG_filtrado3 en función del tiempo y de la frecuencia
senal_fft_1 = fft(ECG_filtrado1 ,longitud);
senal_fft_2 = fft(ECG_filtrado2 ,longitud);

% Cálculo del módulo de la señal
Magnitud1 = abs(senal_fft_1);
Magnitud2 = abs(senal_fft_2);

% ----------------------------
figure(2); subplot(2,1,1);
plot(t,ECG_filtrado1); grid on;
title('Representación de ECG filtrado por pasa-baja');
xlabel ('Tiempo (s)'); ylabel ('Tensión (mV)');

figure(2); subplot(2,1,2);
plot(EjeX(1:(longitud/8)+1), Magnitud1(1:(longitud/8)+1)); grid on;
title ('Magnitud ECG filtrado');
xlabel ('Frecuencia (Hz)');ylabel ('|Magnitud|');

% -----------------------------
figure(3); subplot(2,1,1);
plot(t,ECG_filtrado2); grid on;
title('Representación de ECG filtrado por pasa-alta');
xlabel ('Tiempo (s)'); ylabel ('Tensión (mV)');

figure(3); subplot(2,1,2);
plot(EjeX(1:(longitud/8)+1), Magnitud2(1:(longitud/8)+1)); grid on;
title ('Magnitud ECG filtrado');
xlabel ('Frecuencia (Hz)');ylabel ('|Magnitud|');


