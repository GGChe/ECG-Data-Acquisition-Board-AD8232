# ECG Data Acquisition Device
This is a project done at the University of Malaga during a final Project Report. The aim of this project was to develope an ElectroCardioGraph(ECG), a device that can measure the heart's electrical signal generated during the systole and diastole of atriums and ventricles of this human organ. After obtaining that data, a signal processing was developed based on the Pan-Tompkins Algorythm in order to obtain the peak rate and then a possible control or action can be made after detecting an anomalous process.

This GITHUB project has been organised to distribute all the documents in different folders. 

The project is written in Spanish language. Anyway, the formal data and code can be read perfectly as well as the pictures given.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Components required:
- Arduino
- ECG Electrodes
- Print your PCBs
- SMD resistors:
  - 1x100Kohm
  - 3x1Mohm
  - 6x10Kohm
  - 2x180Kohm
  - 1x360Kohm
  - 1x1Kohm
  - 1x1.4Mohm
  - 1x10Kohm
  - 2x0ohm
- Capacitors:
  - 1x0.01uF
  - 2x0.33uF
  - 1x1500pF
  - 1x1000pF
  - 2x0.01uF
- Audio Jack SMT 3.5mm
- LED standard SMD
AD8232 SMD ECG front end

You will need to install some of the following softwares:
- Eagle (or any other PCB CAD software)
- MATLAB for the code
- SolidWorks for the Case

### Installing

Download the files, print the PCB and solder it. The final device should look like this:
![IMG_20170529_094447](https://user-images.githubusercontent.com/16301652/57015485-f528a600-6c0c-11e9-973a-2b1ea5bc4ee7.jpg)


## Running the tests

To run a test, you would need to download the code provided for arduino and upload it to the microcontroller. Then, connect the second board in the correct orientation and finally, connect the electrodes to the chest in the Einthoven Triangle. That's the best configuration for obtaining the high quality signal. However, do not worry about the microshocks because the current used in the system is not strong enough to produce any organic failure in the patient's body.

## Authors

* [Gabriel Galeote Checa](https://github.com/GGChe)

Any inquiry of consulting, please write an issue or send me a message to gabrielgaleote@uma.es

## License

This is an open source project with a creative commons license.













