% Título: Algoritmo de Pam-Tompkinds de la señal
% Autor: Gabriel Galeote Checa
% DNI: 77231069J
% -----------------------------------------------------
% Limpieza del espacio de trabajo.
clear all
close all

% 1.- Cargar la señal del ECG de un fichero externo

% Código para cargar ficheros de la base de datos
%ECG_1 = load('A00001m.mat'); % Cargamos el fichero con el ECG.
%ECG_1 = ECG_1.val(1,:);

% Código para cargar ficheros leídos por el sistema
load ('ECG_exp_pac_4.txt');
ECG_1=ECG_exp_pac_4;

% Se invierte la señal para obtenerla en la forma adecuada si se necesita.
ECG_1 = ECG_1*(-1); 

% Cálculo de la longitud de la secuencia
longitud = length (ECG_1);
muestras=longitud;

% Creación del intervalo de representación de la señal, en muestras
m = 0:(longitud-1);

% Frecuencia de muestreo 100 para las propias, 500 para las bases de datos
Fs=54;

% Resolución de la señal (periodo de muestreo)
Ts = 1 / Fs;

% Intervalo de tiempo de representación
t = 0:Ts:(longitud-1)/Fs;

% Factor  de escalado del vector a representar de forma que represente
% entre 0 y 35 Hz.
escalado=Fs/35;

% 2 - Eliminar el OFFSET de esta señal del ECG.

% Cálculo de la señal de ECG sin el nivel de continua, para ajustarla 
% en el eje Y.
ECG_sindc=ECG_1-mean(ECG_1);

% 3.- Primer análisis en frecuencia (FFT) de toda la señal del ECG

% Cálculo de FFT de la señal del ECG sin DC y generación de un vector 
% con las muestras en frecuencia para el eje X de la representación

% Obtención de la señal fft (transformada rápida de fourier)
senal_fft = fft (ECG_sindc,longitud);

% cálculo de la magnitud de la señal fft
Magnitud = abs (senal_fft);

% Cálculo del eje X
EjeX = linspace (0,Fs-(Fs/longitud),longitud);

% Figura 1, subplot 2
% Representación gráfica de la magnitud en frecuencia del ECG sin DC
figure(1); subplot(2,1,1);
plot (t, ECG_sindc); grid on;
title('Representación de ECG sin nivel de continua')
xlabel ('Tiempo (s)'); ylabel ('Tensión (mV)');

figure (1); subplot(2,1,2);
plot (EjeX(1:(longitud/2)+1), Magnitud(1:(longitud/2)+1)); grid;
title ('Representación en Frecuencia del ECG sin nivel de continua');
xlabel ('Frecuencia (Hz)');ylabel('|Magnitud| (mV)');


% 4 - Representar la señal del ECG sin OFFTSET y FFT entre 0 y 35 Hz

% Representación gráfica del ECG sin DC de nuevo en tiempo y en
% frecuencia.

figure(2); subplot(2,1,1);
plot (t, ECG_sindc); grid on;
title('Representación de ECG sin nivel de continua')
xlabel ('Tiempo (s)'); ylabel ('Tensión (mV)');

figure(2); subplot(2,1,2);
plot(EjeX(1:(longitud/escalado)+1),Magnitud(1:(longitud/escalado)+1));
grid on;
title ('Representación en Frecuencia del ECG sin nivel de continua');
xlabel ('Frecuencia (Hz)');ylabel('|Magnitud| (mV)');

% Se muestra a parte para que se vea en una escala mayor la señal 
% sin nivel de continua
figure(21);
plot (t, ECG_sindc); grid on;
title('Representación de ECG sin nivel de continua')
xlabel ('Tiempo (s)'); ylabel ('Tensión (mV)');

% ---------------------------------------------

% Filtro pasa baja

Fpass = 14;          % Passband Frequency
Fstop = 20;          % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 30;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h2  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
H2 = design(h2, 'butter', 'MatchExactly', match);


% Filtro pasa alta 

Fstop = 1;           % Stopband Frequency
Fpass = 6;           % Passband Frequency
Astop = 60;          % Stopband Attenuation (dB)
Apass = 1;         % Passband Ripple (dB)
match = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h1  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
H1 = design(h1, 'cheby2', 'MatchExactly', match);

% Filtrado de la señal
ECG_filtrado1 = filter (H1,ECG_sindc);
ECG_filtrado2 = filter (H2,ECG_filtrado1);

% Dibujo la señal ECG_filtrado3 en función del tiempo y de la frecuencia
ECGFFT1 = fft(ECG_filtrado1 ,longitud);
ECGFFT2 = fft(ECG_filtrado2 ,longitud);

% Cálculo del módulo de la señal
Magnitud1 = abs(ECGFFT1);
Magnitud2 = abs(ECGFFT2);

% Calculo de las transformadas inversas de fourier
ECGIFFT1 = ifft(ECG_filtrado1);
ECGIFFT2 = ifft(ECG_filtrado2);

% ----------------------------
figure(3); subplot(2,1,1);
plot(t,ECG_filtrado1); grid on;
title('Representación de ECG filtrado por pasa-alta');
xlabel ('Tiempo (s)'); ylabel ('Tensión (mV)');

figure(3); subplot(2,1,2);
plot(EjeX(1:(longitud/2)+1), Magnitud1(1:(longitud/2)+1)); grid on;
title ('Magnitud ECG filtrado por filtro pasa-alta');
xlabel ('Frecuencia (Hz)');ylabel ('|Magnitud|');

% -----------------------------
figure(4); subplot(2,1,1);
plot(t,ECG_filtrado2); grid on;
title('Representación de ECG filtrado por pasa-baja');
xlabel ('Tiempo (s)'); ylabel ('Tensión (mV)');

figure(4); subplot(2,1,2);
plot(EjeX(1:(longitud/2)+1), Magnitud2(1:(longitud/2)+1)); grid on;
title ('Magnitud ECG filtrado por filtro pasa-baja');
xlabel ('Frecuencia (Hz)');ylabel ('|Magnitud|');

% -----------------------------------------------
% 5 - Calcular la derivada de la señal
% -----------------------------------------------
w = 0:2*pi/longitud:2*pi-(2*pi/longitud);

% Definimos el filtro que calcula la derivada del ECG filtrado
H3 = (5.0 + 4.0.*exp(-1i*w) + 3.0.*exp(-1i*w*2) + 2.0.*exp(-1i*w*3)...
    + exp(-1i*w*4)- 1.0.*exp(-1i*w*6) - 2.0.*exp(-1i*w*7) - ...
    3.0.*exp(-1i*w*8) - 4.0.*exp(-1i*w*9) - 5.0.*exp(-1i*w*10)) / 110.0;

% Normalización del filtro
H3_norm = H3./max(abs(H3));

% Multiplicamos en frecuencia dato a dato la señal ya filtrada
ECGFFT3 = ECGFFT2.*H3_norm;

% Calculamos FFT inversa.
ECGIFFT3 = ifft(ECGFFT3,muestras);

% Figura 5
% Representación gráfica la señal derivada en frecuencia y en tiempo
figure (5); subplot (2,1,2);
plot(EjeX(1:muestras/escalado),abs(ECGFFT3(1:muestras/escalado)));
grid on;
title('ECG en frecuencia filtado por el filtro H5 (derivada)');
xlabel ('Frecuencia (Hz)'); ylabel ('|Magnitud| (mV)');

figure (5); subplot (2,1,1); 
plot (t,real(ECGIFFT3)); grid on;
title('ECG filtrado en tiempo por el filtro H5 (derivada)');
xlabel ('Tiempo (s)'); ylabel ('Amplitud (mV)');

% ---------------------------------------------------------------
% 6 - Elevar la señal al cuadrado muestra a muestra, en el tiempo
%
% En este apartado se eleva la señal al cuadrado
% ---------------------------------------------------------------

ECGIFFT4 = ECGIFFT3.^2; % Elevamos aquí la señal al cuadrado

% Figura 6, Representación de la señal elevada al cuadrado.
figure(6);
subplot (2,1,1); plot (t,real(ECGIFFT4)); grid on;
title('ECG filtrado en tiempo por el filtro H5 y elevado al cuadrado');
xlabel ('Tiempo (s)');
ylabel ('Amplitud (mV)');

% --------------------------------------------
% 9.- Aplicar una ventana de integración a la señal
%
% En este apartado se integra la señal dentro de una ventana 
% de integración para obtener los complejos QRS
% --------------------------------------------

%Tiempo de ventana, por defecto 150 ms
tiempo_ventana = 0.150;

% Nº de muestras de la ventana de integración
muestras_vent = ceil(Fs*tiempo_ventana);

% Aplicar la ventana de integración.
a = 1;
c=zeros(1,muestras_vent);
b = c+(1/muestras_vent);
ECG_integ = filter (b,a,ECGIFFT4);

% Figura 6, subplot 2
% Representamos gráficamente la señal en el tiempo
figure (6); subplot (2,1,2);
plot (t,real(ECG_integ));grid on;
title ('ECG filrado por el filtro H5, elevado al cuadrado e integrado');
xlabel('Tiempo(s)'); ylabel('Amplitud (mV)');

% -----------------------------------------------------
% 10.- Algoritmo de detección del QRS
% -----------------------------------------------------
% Inicializamos los valores de "spki" y "npki"

% Tiempo de entrenamiento
entren = 1;

ECG_integ = real(ECG_integ);

% spki será 1/3 del máximo de la señal integrada en ese periodo
spki = max (ECG_integ(1:entren*Fs)) / 3;

% npki será la mitad de la media de la señal integrada en ese periodo
npki = mean (ECG_integ(1:entren*Fs)) / 2;

% Inicialización el umbral "thri1" que nos indicará si el pico
% es de ruido (<= thri1) o señal (> thri1)
thri1 = npki +0.25*(spki-npki);

% Buscamos los picos en la señal integrada (utilizar "findpeaks")
[pks,loc] = findpeaks(abs(ECG_integ));

% Creación de un vector relleno de ceros que indicará si hay QRS en un
% punto o no. Si hay 0, no hay QRS, si hay otro valor, sí lo hay.
QRS = zeros(1,muestras);

% Vector para llevar el control de los "thri1", "npkis" y 
% "spkis" que hay. En la evaluación de cada pico encontrado.
thrs = zeros(1,muestras);
spks = zeros(1,muestras);
npks = zeros(1,muestras);

%bucle para identificar si cada pico es de señal o ruido.
for i = 1:length(pks)
    % Si el pico es mayor que threshold lo consideramos señaly 
    % se actualiza el valor de spki y de threshold para el 
    % estudio del siguiente pico.
    if(pks(i)>thri1)
        spki = 0.125*pks(i)+0.875*spki;
        % El valor de maximo será en función del máximo del ECG.
        QRS(loc(i))= 0.5*max(abs(ECG_integ));
        
    else
        %En caso contrario, el pico se considerará ruido y actualiza
        % npki y a continuación del threshold.
        npki = 0.125*pks(i)+0.875*npki;
    end
    thri1 = npki+0.25*(spki-npki);
    thrs(loc(i)) = thri1;
    spks(loc(i)) = spki;
    npks(loc(i)) = npki;
end;

% Figura 7, subplot 1
% Dibujamos la ECG integrada y el vector QRS en dos subplots
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

legend('SEÑAL','QRS','THRESHOLD I1','SPKI','NPKI');
title('ECG integrado + thri1 + spki + npki + QRS original');
xlabel('Tiempo(s)'); ylabel('Amplitud (mV)');

% Figura 7, subplot 2
% Dibujamos la ECG sin DC para comprobar los sitios donde hay 
% complejos QRS
figure (7); subplot(2,1,2); plot(t,ECG_1);grid on;
title('ECG sin DC');
xlabel('Tiempo(s)'); ylabel('Amplitud');

%----------------------------------------------------
% Mejora del algoritmo
% ---------------------------------------------------

muestras_entre_picos = Fs*0.2;

% En la función findpeaks se especifica que la distancia entre 
% picos debe ser del 20% de la frecuencia de muestreo. Es un valor 
% que se puede modificar para ir afinando el algoritmo.
[pks2,loc2] = findpeaks(ECG_integ,'MINPEAKDISTANCE',muestras_entre_picos);

maximos = zeros(1,muestras);
thrs_2 = zeros(1,muestras);
spks_2 = zeros(1,muestras);
npks_2 = zeros(1,muestras);

for i = 1:length(pks2)
    if(pks2(i)>thri1)
        spki = 0.125*pks2(i)+0.875*spki;
        % El valor máximo será en función del máximo del ECG.
        maximos(loc2(i)) = 0.5*max(abs(ECG_integ));
    else
        npki = 0.125*pks2(i)+0.875*npki;
    end
    thri1 = npki+0.25*(spki-npki);
    thrs_2(loc2(i))=thri1;
    spks_2(loc2(i)) = spki;
    npks_2(loc2(i)) = npki;
end
% Figura 8, subplot 1
% Dibujamos la ECG integrada, el vector QRS, el vector THRI1, 
% el vector SPKI y el vector NPKI en un subplot mediante hold on
maxs_posi=find(maximos > 0);

figure (8); subplot(2,1,1);
plot (t,ECG_integ); grid on; hold on;
plot(t(maxs_posi),maximos(maxs_posi),'m^'); hold on;

thrs_positivos_2 = find(thrs_2 > 0);
plot(t(thrs_positivos_2), thrs_2(thrs_positivos_2), '*r');hold on;

spks_positivos = find(spks_2 > 0);
plot(t(spks_positivos),spks_2(spks_positivos), 'g+');hold on;

npks_positivos = find(npks_2 > 0);
plot(t(npks_positivos),npks_2(npks_positivos), 'k.'); hold on;

legend('SEÑAL','QRS','THRESHOLD I1','SPKI','NPKI');
title('ECG integrado + thri1 + spki + npki + QRS en la primera mejora');
xlabel('Tiempo(s)');
ylabel('Amplitud');

% Figura 8, subplot 2
% Representación gráfica de la ECG sin DC para comprobar los sitios 
% donde se han encontrado complejos QRS

figure (8);subplot(2,1,2);
plot (t,ECG_1); grid on;
title('ECG sin DC');
xlabel('Tiempo(s)'); ylabel('Amplitud');

% --------------------------------------
%          Apartado estadístico
% --------------------------------------

QRSdetectado = findpeaks(maximos);

ntotalQRS = length(QRSdetectado);

tiempo=(longitud/Fs); % En segundos
tiempominutos = tiempo / 60; % en minutos

frecuenciacardiaca = ntotalQRS/(tiempominutos);
