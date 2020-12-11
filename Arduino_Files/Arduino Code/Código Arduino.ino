/******************************************************************************
  Proyecto: ECG arduino
  Autor: Gabriel Galeote Checa
  The circuit:
   analog sensors on analog ins 0, 1, and 2
   SD card attached to SPI bus as follows:
 ** MOSI - pin 51
 ** MISO - pin 50
 ** CLK - pin 52
 ** CS - pin 53

******************************************************************************/
#include <SPI.h>
#include <SD.h>

const int chipSelect = 53;
int lectura = 0;
File dataFile;

void setup() {
  // initialize the serial communication:
  Serial.begin(9600);
  pinMode(10, INPUT); // Setup for leads off detection LO +
  pinMode(11, INPUT); // Setup for leads off detection LO -
  pinMode(chipSelect, OUTPUT);
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }


  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    // don't do anything more:
    return;
  }
  Serial.println("card initialized.");
}



void loop() {
  //Primero realizamos la lectura de datos desde la placa

  if ((digitalRead(10) == 1) || (digitalRead(11) == 1)) {

    Serial.println('!');

  }
  else {
    dataFile = SD.open("ECG.txt", FILE_WRITE);
    // send the value of analog input 0:
    lectura = analogRead(A0);

    // if the file is available, write to it:

    if (dataFile) {

      dataFile.print(String(lectura));
      dataFile.print(" ");
      dataFile.close();
      // print to the serial port too:
      Serial.println(lectura);
    }
    // if the file isn't open, pop up an error:
    else {
      Serial.println("error opening ECG.txt");
    }
  }

}

