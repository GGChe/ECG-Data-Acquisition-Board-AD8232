% T�tulo: Algoritmo de Pam-Tompkinds de la se�al
% Autor: Gabriel Galeote Checa
% DNI: 77231069J
% -----------------------------------------------------
% Limpieza del espacio de trabajo.
clear all
close all

% 1.- Cargar la se�al del ECG de un fichero externo

% C�digo para cargar ficheros de la base de datos
%ECG_1 = load('A00001m.mat'); % Cargamos el fichero con el ECG.
%ECG_1 = ECG_1.val(1,:);

% C�digo para cargar ficheros le�dos por el sistema
load ('ECG_exp_pac_4.txt');
ECG_1=ECG_exp_pac_4;

% Se invierte la se�al para obtenerla en la forma adecuada si se necesita.
ECG_1 = ECG_1*(-1); 

% C�lculo de la longitud de la secuencia
longitud = length (ECG_1);
muestras=longitud;

% Creaci�n del intervalo de representaci�n de la se�al, en muestras
m = 0:(longitud-1);

% Frecuencia de muestreo 100 para las propias, 500 para las bases de datos
Fs=54;

% Resoluci�n de la se�al (periodo de muestreo)
Ts = 1 / Fs;

% Intervalo de tiempo de representaci�n
t = 0:Ts:(longitud-1)/Fs;

% Factor  de escalado del vector a representar de forma que represente
% entre 0 y 35 Hz.
escalado=Fs/35;

% 2 - Eliminar el OFFSET de esta se�al del ECG.

% C�lculo de la se�al de ECG sin el nivel de continua, para ajustarla 
% en el eje Y.
ECG_sindc=ECG_1-mean(ECG_1);

% 3.- Primer an�lisis en frecuencia (FFT) de toda la se�al del ECG

% C�lculo de FFT de la se�al del ECG sin DC y generaci�n de un vector 
% con las muestras en frecuencia para el eje X de la representaci�n

% Obtenci�n de la se�al fft (transformada r�pida de fourier)
senal_fft = fft (ECG_sindc,longitud);

% c�lculo de la magnitud de la se�al fft
Magnitud = abs (senal_fft);

% C�lculo del eje X
EjeX = linspace (0,Fs-(Fs/longitud),longitud);

% Figura 1, subplot 2
% Representaci�n gr�fica de la magnitud en frecuencia del ECG sin DC
figure(1); subplot(2,1,1);
plot (t, ECG_sindc); grid on;
title('Representaci�n de ECG sin nivel de continua')
xlabel ('Tiempo (s)'); ylabel ('Tensi�n (mV)');

figure (1); subplot(2,1,2);
plot (EjeX(1:(longitud/2)+1), Magnitud(1:(longitud/2)+1)); grid;
title ('Representaci�n en Frecuencia del ECG sin nivel de continua');
xlabel ('Frecuencia (Hz)');ylabel('|Magnitud| (mV)');


% 4 - Representar la se�al del ECG sin OFFTSET y FFT entre 0 y 35 Hz

% Representaci�n gr�fica del ECG sin DC de nuevo en tiempo y en
% frecuencia.

figure(2); subplot(2,1,1);
plot (t, ECG_sindc); grid on;
title('Representaci�n de ECG sin nivel de continua')
xlabel ('Tiempo (s)'); ylabel ('Tensi�n (mV)');

figure(2); subplot(2,1,2);
plot(EjeX(1:(longitud/escalado)+1),Magnitud(1:(longitud/escalado)+1));
grid on;
title ('Representaci�n en Frecuencia del ECG sin nivel de continua');
xlabel ('Frecuencia (Hz)');ylabel('|Magnitud| (mV)');

% Se muestra a parte para que se vea en una escala mayor la se�al 
% sin nivel de continua
figure(21);
plot (t, ECG_sindc); grid on;
title('Representaci�n de ECG sin nivel de continua')
xlabel ('Tiempo (s)'); ylabel ('Tensi�n (mV)');

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

% Filtrado de la se�al
ECG_filtrado1 = filter (H1,ECG_sindc);
ECG_filtrado2 = filter (H2,ECG_filtrado1);

% Dibujo la se�al ECG_filtrado3 en funci�n del tiempo y de la frecuencia
ECGFFT1 = fft(ECG_filtrado1 ,longitud);
ECGFFT2 = fft(ECG_filtrado2 ,longitud);

% C�lculo del m�dulo de la se�al
Magnitud1 = abs(ECGFFT1);
Magnitud2 = abs(ECGFFT2);

% Calculo de las transformadas inversas de fourier
ECGIFFT1 = ifft(ECG_filtrado1);
ECGIFFT2 = ifft(ECG_filtrado2);

% ----------------------------
figure(3); subplot(2,1,1);
plot(t,ECG_filtrado1); grid on;
title('Representaci�n de ECG filtrado por pasa-alta');
xlabel ('Tiempo (s)'); ylabel ('Tensi�n (mV)');

figure(3); subplot(2,1,2);
plot(EjeX(1:(longitud/2)+1), Magnitud1(1:(longitud/2)+1)); grid on;
title ('Magnitud ECG filtrado por filtro pasa-alta');
xlabel ('Frecuencia (Hz)');ylabel ('|Magnitud|');

% -----------------------------
figure(4); subplot(2,1,1);
plot(t,ECG_filtrado2); grid on;
title('Representaci�n de ECG filtrado por pasa-baja');
xlabel ('Tiempo (s)'); ylabel ('Tensi�n (mV)');

figure(4); subplot(2,1,2);
plot(EjeX(1:(longitud/2)+1), Magnitud2(1:(longitud/2)+1)); grid on;
title ('Magnitud ECG filtrado por filtro pasa-baja');
xlabel ('Frecuencia (Hz)');ylabel ('|Magnitud|');

% -----------------------------------------------
% 5 - Calcular la derivada de la se�al
% -----------------------------------------------
w = 0:2*pi/longitud:2*pi-(2*pi/longitud);

% Definimos el filtro que calcula la derivada del ECG filtrado
H3 = (5.0 + 4.0.*exp(-1i*w) + 3.0.*exp(-1i*w*2) + 2.0.*exp(-1i*w*3)...
    + exp(-1i*w*4)- 1.0.*exp(-1i*w*6) - 2.0.*exp(-1i*w*7) - ...
    3.0.*exp(-1i*w*8) - 4.0.*exp(-1i*w*9) - 5.0.*exp(-1i*w*10)) / 110.0;

% Normalizaci�n del filtro
H3_norm = H3./max(abs(H3));

% Multiplicamos en frecuencia dato a dato la se�al ya filtrada
ECGFFT3 = ECGFFT2.*H3_norm;

% Calculamos FFT inversa.
ECGIFFT3 = ifft(ECGFFT3,muestras);

% Figura 5
% Representaci�n gr�fica la se�al derivada en frecuencia y en tiempo
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
% 6 - Elevar la se�al al cuadrado muestra a muestra, en el tiempo
%
% En este apartado se eleva la se�al al cuadrado
% ---------------------------------------------------------------

ECGIFFT4 = ECGIFFT3.^2; % Elevamos aqu� la se�al al cuadrado

% Figura 6, Representaci�n de la se�al elevada al cuadrado.
figure(6);
subplot (2,1,1); plot (t,real(ECGIFFT4)); grid on;
title('ECG filtrado en tiempo por el filtro H5 y elevado al cuadrado');
xlabel ('Tiempo (s)');
ylabel ('Amplitud (mV)');

% --------------------------------------------
% 9.- Aplicar una ventana de integraci�n a la se�al
%
% En este apartado se integra la se�al dentro de una ventana 
% de integraci�n para obtener los complejos QRS
% --------------------------------------------

%Tiempo de ventana, por defecto 150 ms
tiempo_ventana = 0.150;

% N� de muestras de la ventana de integraci�n
muestras_vent = ceil(Fs*tiempo_ventana);

% Aplicar la ventana de integraci�n.
a = 1;
c=zeros(1,muestras_vent);
b = c+(1/muestras_vent);
ECG_integ = filter (b,a,ECGIFFT4);

% Figura 6, subplot 2
% Representamos gr�ficamente la se�al en el tiempo
figure (6); subplot (2,1,2);
plot (t,real(ECG_integ));grid on;
title ('ECG filrado por el filtro H5, elevado al cuadrado e integrado');
xlabel('Tiempo(s)'); ylabel('Amplitud (mV)');

% -----------------------------------------------------
% 10.- Algoritmo de detecci�n del QRS
% -----------------------------------------------------
% Inicializamos los valores de "spki" y "npki"

% Tiempo de entrenamiento
entren = 1;

ECG_integ = real(ECG_integ);

% spki ser� 1/3 del m�ximo de la se�al integrada en ese periodo
spki = max (ECG_integ(1:entren*Fs)) / 3;

% npki ser� la mitad de la media de la se�al integrada en ese periodo
npki = mean (ECG_integ(1:entren*Fs)) / 2;

% Inicializaci�n el umbral "thri1" que nos indicar� si el pico
% es de ruido (<= thri1) o se�al (> thri1)
thri1 = npki +0.25*(spki-npki);

% Buscamos los picos en la se�al integrada (utilizar "findpeaks")
[pks,loc] = findpeaks(abs(ECG_integ));

% Creaci�n de un vector relleno de ceros que indicar� si hay QRS en un
% punto o no. Si hay 0, no hay QRS, si hay otro valor, s� lo hay.
QRS = zeros(1,muestras);

% Vector para llevar el control de los "thri1", "npkis" y 
% "spkis" que hay. En la evaluaci�n de cada pico encontrado.
thrs = zeros(1,muestras);
spks = zeros(1,muestras);
npks = zeros(1,muestras);

%bucle para identificar si cada pico es de se�al o ruido.
for i = 1:length(pks)
    % Si el pico es mayor que threshold lo consideramos se�aly 
    % se actualiza el valor de spki y de threshold para el 
    % estudio del siguiente pico.
    if(pks(i)>thri1)
        spki = 0.125*pks(i)+0.875*spki;
        % El valor de maximo ser� en funci�n del m�ximo del ECG.
        QRS(loc(i))= 0.5*max(abs(ECG_integ));
        
    else
        %En caso contrario, el pico se considerar� ruido y actualiza
        % npki y a continuaci�n del threshold.
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

legend('SE�AL','QRS','THRESHOLD I1','SPKI','NPKI');
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

% En la funci�n findpeaks se especifica que la distancia entre 
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
        % El valor m�ximo ser� en funci�n del m�ximo del ECG.
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

legend('SE�AL','QRS','THRESHOLD I1','SPKI','NPKI');
title('ECG integrado + thri1 + spki + npki + QRS en la primera mejora');
xlabel('Tiempo(s)');
ylabel('Amplitud');

% Figura 8, subplot 2
% Representaci�n gr�fica de la ECG sin DC para comprobar los sitios 
% donde se han encontrado complejos QRS

figure (8);subplot(2,1,2);
plot (t,ECG_1); grid on;
title('ECG sin DC');
xlabel('Tiempo(s)'); ylabel('Amplitud');

% --------------------------------------
%          Apartado estad�stico
% --------------------------------------

QRSdetectado = findpeaks(maximos);

ntotalQRS = length(QRSdetectado);

tiempo=(longitud/Fs); % En segundos
tiempominutos = tiempo / 60; % en minutos

frecuenciacardiaca = ntotalQRS/(tiempominutos);
