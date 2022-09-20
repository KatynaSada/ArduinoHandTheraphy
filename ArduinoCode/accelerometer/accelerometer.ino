
/*
 * Authors: Katyna Sada and Teresa Pardo
 * Date: May 25, 2021
 * Description: This code performs the readings of an AXDL345 with the chosen g range and sends the values of its coordinates to the XBee Port.
 * The arduino requires an input message from the port in order to select the range and start the readings. 
 */ 
#include <SPI.h> 
#include <SoftwareSerial.h>

#define SERIALBAUD 9600

// Adresses of the registers of the ADXL345
#define POWER_CTL 45 
#define DATA_FORMAT 49 
#define DATAX0 50 

#define ADXL345_RANGE_2G 0b00
#define ADXL345_RANGE_4G 0x01
#define ADXL345_RANGE_8G 0b10
#define ADXL345_RANGE_16G 0b11

// Divisor for converting to g units.
#define G_RANGE_2G 4 
#define G_RANGE_4G 8 
#define G_RANGE_8G 16 
#define G_RANGE_16G 32 

#define MEASUREMENT_MODE 0x08
#define DEVID 0 // Adress of the register

// Arduino pins used for SPI communication
#define CS1 10
#define MOSI 11
#define MISO 12
#define SCK 13

#define MAX_INPUT 1 //maximum number of characters in the message.

SoftwareSerial XBee(2,3);

int gRange; 

uint8_t arrayDevid[6];
uint8_t arrayPower[6];

int numRegisters = 6;
int milliseconds = 110; // Delay of 100 milliseconds.

int option;
uint8_t reading[6]; // Array to store the readings of the accelerometer.
String inData; // To store incoming data
char input_line[MAX_INPUT+1]; //Array to store the input message and null character
unsigned int input_pos = 0; //index into the input_line

bool startGame = 0; // Controls the readings of the accelerometer. 

void writeRegister(uint8_t,int8_t,uint8_t);
void readRegister(uint8_t,uint8_t,uint8_t,uint8_t);
void process_incoming_byte();
void process_data();
void setupRange(int,int);

void setup() {
  XBee.begin(SERIALBAUD);
  
  pinMode(CS1, OUTPUT);
  pinMode(MOSI, OUTPUT);
  pinMode(MISO, OUTPUT);
  pinMode(SCK, OUTPUT);

  SPI.begin();
  SPI.setDataMode(SPI_MODE3); // Set the clock polarity and phase to 1 (mode 3).
  SPI.setClockDivider(SPI_CLOCK_DIV2); // Set clock divider to 2 MHz.

  digitalWrite(CS1, HIGH); 

  writeRegister(POWER_CTL,MEASUREMENT_MODE,CS1); // Put the ADXL345 into Measurement Mode by writing 0x08 to the POWER_CTL register.
  readRegister(POWER_CTL,1,arrayPower,CS1); 
}

void loop() {
 if ( XBee.available()>0 ) {
  process_incoming_byte(); // Read the incoming message. 
 }

 // Depending on the chosen value received from the port, the accelerometer range is chosen. 
  if (option=='1'){ // 2G Range
    option='0'; 
    startGame = 0;  
    setupRange(ADXL345_RANGE_2G, G_RANGE_2G);
    startGame = 1;  
  }
  else if (option=='2'){ // 4G Rangel
    option='0';
    startGame = 0;  
    setupRange(ADXL345_RANGE_4G, G_RANGE_4G);
    startGame = 1;    
  }
  else if (option=='3'){ // 8G Range
    option='0';
    startGame = 0;
    setupRange(ADXL345_RANGE_8G, G_RANGE_8G);
    startGame = 1;   
  }
  else if (option=='4'){ // 16G Range
    option='0';
    startGame = 0;
    setupRange(ADXL345_RANGE_16G, G_RANGE_16G);
    startGame = 1;  
  }
  
   if (startGame){ // When a range is selected the readings start. 
   readAcceleration(CS1);
   }

}

// The purpose of this function is to write a register.
void writeRegister(uint8_t registerAddress, int8_t valueAccelerometer, uint8_t pinAccelerometer){
  digitalWrite(pinAccelerometer, LOW); // Activate the accelerometer working as an SPI slave.
  SPI.transfer(registerAddress); // Send the address of the accelerometer where the data should be read. 
  SPI.transfer(valueAccelerometer); // Send the register value.
  digitalWrite(pinAccelerometer, HIGH); // Deactivate the accelerometer.
}

// The purpose of this function is to read a register.
void readRegister (uint8_t registerAddress, uint8_t numRegisters, uint8_t *arrayAddress, uint8_t pinAccelerometer){
  uint8_t address = registerAddress|0x80;
  if(numRegisters > 1){
    address = address|0x40; 
  }
  
  digitalWrite(pinAccelerometer, LOW); // Activate the accelerometer working as an SPI slave.
  SPI.transfer(address); 
  
  for(int i = 0; i < numRegisters; i++){
  arrayAddress[i] = SPI.transfer(0); // Read the register values and write them in the array. 
  }

  digitalWrite(pinAccelerometer, HIGH); // Deactive accelerometer. 
}

// This function reads the values of an accelerometer, converts them to g units and prints is coordinates to the port. 
void readAcceleration(uint8_t pinAccelerometer){
  
  readRegister(DATAX0,numRegisters,reading,pinAccelerometer); // Reads the acceleration from the chosen accelerometer.  
 
  // Read the register values and convert them to int (each axis has 10 bits in 2 bytes).
  //To get the complete value, two bytes must be combined for each axis.
  int coordinates[3];
  float coordinatesG[3];

  coordinates[0] = (((int)reading[1])<<8)|((int)reading[0]);
  coordinates[1] = (((int)reading[3])<<8)|((int)reading[2]);
  coordinates[2] = (((int)reading[5])<<8)|((int)reading[4]);

  // Convert to g units.
  coordinatesG[0] = gUnits(coordinates[0],gRange);
  coordinatesG[1] = gUnits(coordinates[1],gRange);
  coordinatesG[2] = gUnits(coordinates[2],gRange);

  XBee.print("A"); // leading 'A' means accelerometer data 
  XBee.print(coordinatesG[0]); 
  XBee.print("/");
  XBee.print(coordinatesG[1]);
  XBee.print("/");
  XBee.println(coordinatesG[0]);
  
  delay(milliseconds);
}

// Function to convert a value to g units.
float gUnits(int number,int range)
{ 
    float gNumber;
    gNumber = range*number/1024.0;
    return gNumber;
}

// Function to read the bytes received from the port. 
void process_incoming_byte(){
    byte inByte = XBee.read(); // Read byte
    
    switch (inByte) {
        case '\n':   // If the character is New Line, then we process the message
            input_line[input_pos] = 0;  // terminating null byte
            process_data(); //
            input_pos = 0;  // Start writing at beginning of the buffer
            break;

        case '\r':   // Discard carriage return
            break;

        default:
            // keep adding characters to input_line until full

            // for the terminating null character
            if (input_pos < (MAX_INPUT)){
                input_line[input_pos++] = inByte;
            }
        break;
      }// end of switch
} // end of process_incoming_byte


void process_data(){
    option = input_line[0]; // The value received from port is stored on the option variable. 
 }

// Function to modify the range of measurement of the ADXL345 and the corresponding conversion value.
void setupRange(int ADXLchosenRange, int range){
  writeRegister(DATA_FORMAT,ADXLchosenRange,CS1); //Put the ADXL345 into the range by writing the ADXL345_RANGE value to the DATA_FORMAT register.
  readRegister(DATA_FORMAT,1,arrayDevid,CS1); // Read register and store it in arrayDevid.

  gRange=range; // Define conversion value.

  }
