
/*
 * Authors: Katyna Sada and Teresa Pardo (based on Pulse Sensor Amped 1.5 by Joel Murphy and Yury Gitman   http://www.pulsesensor.com)
 * Date: May 25, 2021
 * Description: This code:
    - Determines BPM
    - Reads the temperature from va TMP102 using the I2C protocol.
    - Prints All of the Above to Serial.
 */ 
    
#include <Wire.h> //To use the I2C protocol.
#include <SoftwareSerial.h>

#define MAX_INPUT 1 //maximum number of characters in the message.

// TEMPERATURE SENSOR --------------------------------------------
#define TEMP_A 0x48 // Address of the temperature sensor.
#define TMP102_TEMP 0x00 // Address of the register of the temperature sensor.

uint8_t values[2];
float resolution = 0.0625; // Resolution of the temperature sensor.

// PULSE SENSOR --------------------------------------------
int pulsePin = 0;                 // Pulse Sensor purple wire connected to analog pin 0

// Volatile Variables, used in the interrupt service routine!
volatile int BPM;                   // int that holds raw analog in 0, updated every 2mS
volatile int IBI = 600;             // int that holds the time interval between beats, (must be seeded)
volatile int Signal;                // holds the incoming raw data
volatile boolean Pulse = false;     // "True" when user's live heartbeat is detected. "False" when not a "live beat".
volatile boolean QS = false;        // becomes true when Arduino finds a beat.
//  --------------------------------------------


// Definition of variables required to read from port ---------
SoftwareSerial XBee(2,3);
bool stateT = false;// Determines if the temperature sensor should send or not data
bool stateP = false;// Determines if the pulse sensor should send or not data

int option=0; // Stores value received from port.
uint8_t reading[MAX_INPUT]; // Array to store the readings. 
String inData; // To store incoming data
char input_line[MAX_INPUT+1]; //Array to store the input message and null character
unsigned int input_pos = 0; //index into the input_line
void process_incoming_byte();
void process_data();

int milliseconds100 = 100; // Delay of 100 milliseconds.
int milliseconds10 = 10; // Delay of 10 milliseconds.

//  --------------------------------------------

void setup(){
  XBee.begin(9600); //To communicate with the PC
  Wire.begin(); //Join the I2C bus (for temperature sensor)
  
  interruptSetup(); // sets up to read Pulse Sensor signal every 2mS
}

void loop(){
  if ( XBee.available()>0 ) {
    process_incoming_byte(); // Read the incoming message. 
    }
  
  // Depending on the chosen value received from the port, the accelerometer range is chosen. 
  if (option=='6'){ // Pulse sensor
    option='0';
    stateP=!stateP; // In order to read or stop reading the pulse sensor. 
   } else if (option=='5'){ // Temperature sensor
    option='0';
    stateT=!stateT; // In order to read or stop reading the temperature sensor. 
   }
  
   if (stateP==true){
    sendDataToSerial('S', Signal); // output signal to serial 
    
    if (QS == true){ // A Heartbeat was found, BPM and IBI have been determined, quantified self "QS" true when arduino finds a heartbeat.
      sendDataToSerial('B',BPM);   // A beat happened, output that to serial.
      QS = false; // reset the quantified self flag for next time
      }
      delay(milliseconds10);      
    }
   
   if (stateT==true){
    readTemp(TEMP_A);   
    }
}


//  Sends data to port
void sendDataToSerial(char symbol, int data ){
    XBee.print(symbol);
    XBee.println(data);
  }

// Function that reads the temperature, scales it and prints it in degrees Celsius to the port.
float readTemp(byte addr){
  int n=2; // number of bytes to read
  readRegisters_I2C(addr, TMP102_TEMP, n);

  values[1] = values[1] >> 4;
  float t = (float) (((int)values[0]  << 4) | (int)values [1] ); 
  float convertedtemp = t*resolution;
 
  sendDataToSerial('T', convertedtemp); // leading 'T' means temperature data
  delay(milliseconds100);
  }

// The objective of this function is to read a specific number of bytes from the I2C device. 
void readRegisters_I2C(byte addr, byte reg, byte numBytes){
  Wire.beginTransmission(addr); // Prepare to communicate with slave that has that address.
  Wire.write(reg); // Define which register to read.
  Wire.endTransmission();
  
  Wire.beginTransmission(addr);
  Wire.requestFrom(addr, numBytes); // The slave gets a number of bytes from that address.
  int i = 0;
  while(Wire.available())
  { 
    values[i] = Wire.read();
    i++;
  }
  Wire.endTransmission();
}

// Function to read the bytes received from the port. 
void process_incoming_byte(){
    byte inByte = XBee.read(); // Read byte
    
    switch (inByte) {
        case '\n':   // If the character is New Line, then we process the message
            input_line[input_pos] = 0;  // terminating null byte
            process_data(); 
            input_pos = 0;  // Start writing at beginning of the buffer
            break;

        case '\r':   // Discard carriage return
            break;

        default:
            // keep adding characters to input_line until full, allow

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
