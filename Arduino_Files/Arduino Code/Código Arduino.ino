/******************************************************************************
  Project: Arduino embedded code
  Author: Gabriel Galeote Checa
  Summary of connections:
    - Analog Inputs on AN 0, 1, and 2
    - SD card communicated through SPI bus as follows:
      - MOSI - pin 51
      - MISO - pin 50
      - CLK - pin 52
      - CS - pin 53

******************************************************************************/
#include <SPI.h>
#include <SD.h>

const int chipSelect = 53;
int read = 0;
File dataFile;

void setup() {
  // Initialize IO
  pinMode(10, INPUT); // Setup for leads off detection LO +
  pinMode(11, INPUT); // Setup for leads off detection LO -
  pinMode(chipSelect, OUTPUT);
  // Serial communication set to 9600 bauds, standard value.
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    return;
  }
  Serial.println("card initialized.");
}


void loop() {
  // Start first reading from the data acquisition board
  if ((digitalRead(10) == 1) || (digitalRead(11) == 1)) {
    Serial.println('!');
  }
  else {
    dataFile = SD.open("ECG.txt", FILE_WRITE);
    read = analogRead(A0);
    // if the file is available, write to it:
    if (dataFile) {
      dataFile.print(String(read));
      dataFile.print(" ");
      dataFile.close();
      // print to the serial port too:
      Serial.println(read);
    }
    // if the file isn't open, pop up an error:
    else {
      Serial.println("error opening ECG.txt");
    }
  }

}

