import processing.opengl.*;
import processing.video.*;
import processing.serial.*;
import java.util.stream.*;

PFont font;
PFont portsFont;

Movie myMovie; // Object to play a song.
Serial port; // Object of the class Serial.

StopWatchTimer sw; // Timer

// Buttons to select the range
twoStateButton button2G;
twoStateButton button4G;
twoStateButton button8G;
twoStateButton button16G;

twoStateButton buttonTemp; // Buttons to switch on or off the temperature display
twoStateButton buttonPulse; // Buttons to switch on or off the pulse sensor display

twoStateButton buttonNext; // Button to switch the image

int count=0; // Initial counter to avoid wrong initial transmissions.

// ACCELEROMETER variables ----------
PImage img1, img2, img3, img4, img5, img6; // Images
PGraphics canvas; // To create the 3D environment.
String[] coordinates = new String[3]; // To save the received coordinates.
float x, y, z; // Accelerometer coordinates.

// TEMPERATURE variables ----------
float sizeBar; // To modify the size of the temperature bar.
String temp = "0"; // Variable to store the temperature.

// PULSE SENSOR variables ----------
int BPM=0;         // Holds heart rate value;
int heart = 0;   // This variable times the heart image 'pulse' on screen
boolean beat = false;    // Set when a heart beat is detected, then cleared when the BPM graph is advanced

int Sensor;      // Holds pulse sensor data from arduino.
int[] RawY;      // Holds heartbeat wavefrom data before scaling.
int[] ScaledY;   // Used to position scaled heartbeat waveform.
int[] rate;      // Used to position BPM data waveform.
float zoom;      // Used when scaling pulse waveform to pulse window.
float offset;    // Used when scaling pulse waveform to pulse window.
int PulseWindowWidth = 210;
int PulseWindowHeight = 100;

// Variables to control the game
int numRounds = 11; // Stores the total number of rounds (plus 1).
int round = 0; // Defines the game round.
boolean showScore=false; // Use to display the score when the game ends.
String[] words = new String[numRounds]; // Stores the words that define the image the patient has to look for.
int[] scores = new int[numRounds]; // Stores the score (seconds) of each round.

// Colors...
color eggshell = color(255, 253, 248);
color red = color(241, 94, 94);
color green = color(159, 241, 94);
color purple = color(239, 154, 13);
color orange = color(169, 17, 200);

void setup()
{
  port = new Serial(this, "/dev/cu.usbserial-DA01202H", 9600);
  port.bufferUntil('\n'); // The serialEvent function is called when the newline character is received.

  size(900, 600, P2D); // Size of screen.
  canvas = createGraphics(width, height, P3D); // Use to display the 3D environment.
  frameRate(60); // (Required for the canvas.)

  font = loadFont("Avenir-Book-18.vlw");
  textFont(font);

  myMovie = new Movie(this, "song.mp4");
  myMovie.play();
  myMovie.loop();
  img1 = loadImage("tecnun.jpg");
  img2 = loadImage("concierto.jpg");
  img3 = loadImage("ss.jpg");
  img4 = loadImage("globo.jpg");
  img5 = loadImage("montaña.jpg");
  img6 = loadImage("paris.jpg");

  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  zoom = 0.1;     // initialize scale of heartbeat window
  resetDataTraces(); // set the visualizer lines to 0

  button2G = new twoStateButton(0, 0, 225, 30, "2G", "2G", red, green);
  button4G = new twoStateButton(225, 0, 225, 30, "4G", "4G", red, green);
  button8G = new twoStateButton(450, 0, 225, 30, "8G", "8G", red, green);
  button16G = new twoStateButton(675, 0, 225, 30, "16G", "16G", red, green);

  buttonPulse = new twoStateButton(420, 475, 30, 30, "OFF", "ON", red, green);
  buttonTemp = new twoStateButton(850, 475, 30, 30, "OFF", "ON", red, green);

  buttonNext = new twoStateButton(572, 525, 60, 30, "cambiar", "cambiar", purple, orange);

  sw = new StopWatchTimer();
  sw.start();
  
  // Define the order of the game...
  words[0] = "concierto";
  words[1] = "globos aerostáticos";
  words[2] = "San Sebastián";
  words[3] = "Tecnun";
  words[4] = "Montañas";
  words[5] = "Paris (¡gíralo!)";
  words[6] = "concierto";
  words[7] = "Montañas";
  words[8] = "globos aerostáticos";
  words[9] = "Tecnun";
  words[10] = "¡HAS TERMINADO!";
}

void draw() {
  textAlign(CENTER);
  textSize(16);

  virtualEnvironment(); // Draw and control the virtual environment
  
  // Draw a rectangle on top 
  fill(255, 160);
  stroke(0);
  strokeWeight(6);
  rect(3, height-150, width-6, 147); // x,y,width,height
  
  drawHeart();
  fill(eggshell);
  stroke(255);
  rect(200, 480, PulseWindowWidth, PulseWindowHeight);
  drawPulseWaveform();
  
  Temperature();

  button2G.display();
  button4G.display();
  button8G.display();
  button16G.display();

  textSize(12);
  buttonTemp.display();
  buttonPulse.display();
  buttonNext.display();
  
  // Game... 
  textSize(18);
  time(); // Timer
  fill(0, 0, 0);
  text("Busca la imagen de...", width-350, height-110); 

  if (sw.second()==59&&round<10) { // If more than 1 minute has passed the word changes automatically.
    scores[round]=sw.second(); // Saves the seconds taken to look for the image. 
    buttonNext.toggle();
    round = round+1; // Goes to next round. 
    sw.stop(); // Stops timer.
    sw.start(); // Starts timer again.
  }
  textSize(20);
  fill(169, 17, 200);
  text(words[round], width-350, height-85); // Write the next word.

  if (showScore) { // Print the score on the last round. 
    rectMode(CENTER);
    fill(255);
    stroke(255);
    rect(width/2, height/2, 300, 270);
    rectMode(CORNER);
    fill(0);
    text("Puntuación...", width/2, 210);

    for (int i = 0; i < scores.length-2; i++) {
      textSize(15);
      textAlign(LEFT);
      text(nf(i+1)+") "+words[i]+" = "+nf(scores[i]), 350, 235+i*20);
    }
    text("Total......................"+nf(IntStream.of(scores).sum()), 350, 245+9*20);
  }
  
}

// The purpose of this function is to display the temperature change.
void Temperature() {
  String tempString = "Temperature: ";
  strokeWeight(0);
  tempString = tempString+temp+"C";
  fill(0, 0, 0);
  text(tempString, width-140, height-100); // Show the temperature

  fill(0, 0, 0);
  text("0C", width-160, height-30); // Draw the minimum value

  fill(0, 0, 0);
  text("100C", width-60, height-30); // Draw the maximum value

  fill(255, 255, 255);
  
  rect(width-150, height-80, 100, 25); // Draw the white bar of the temperature

  fill(255, 0, 0);
  sizeBar = float(temp)+20; // Change the value of the temperature to float.
  rect(width-150, height-80, sizeBar, 25); // Draw the bar that changes with the value of temperature.
  circle(width-150, height-70,42);
  strokeWeight(1);
}

//  The purpose of this function is to draw the heart and make it beat. 
void drawHeart() {
  fill(0, 0, 0);
  text(BPM + " BPM", 70, 580);     // print the Beats Per Minute

  fill(241, 94, 94 );
  stroke(241, 94, 94 );
  // the 'heart' variable is set in serialEvent when arduino sees a beat happen
  heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
  heart = max(heart, 0);       // don't let the heart variable go into negative numbers
  if (heart > 0) {             // if a beat happened recently,
    strokeWeight(8);          // make the heart big
  }
  smooth();   // draw the heart with two bezier curves
  bezier(100, 50+400, 20, -20+400, 0, 140+400, 100, 150+400);
  bezier(100, 50+400, 190, -20+400, 200, 140+400, 100, 150+400);
  strokeWeight(1); // reset the strokeWeight for next time
}

//  The purpose of this function is to draw the pulse wave form.
void drawPulseWaveform() {
  // prepare pulse data points
  RawY[RawY.length-1] = (1023 - Sensor) - 212;   // place the new raw datapoint at the end of the array
  offset = map(zoom, 0.5, 1, 150, 0);   // calculate the offset needed at this scale
  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
    RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
    float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
    ScaledY[i] = constrain(int(dummy), 44, 556);   // transfer the raw data array to the scaled array
  }
  stroke(250, 0, 0);                               // red is a good color for the pulse waveform
  noFill();
  beginShape();                                  // using beginShape() renders fast
  for (int x = 1; x < ScaledY.length-1; x++) {
    vertex(x+200, ScaledY[x]+225);               //draw a line connecting the data points, position is defined by +200 and +225
  }
  endShape();
}

//  The purpose of this function is to reset the pulse wave form.
void resetDataTraces() {
  for (int i=0; i<RawY.length; i++) {
    RawY[i] = height/2; // initialize the pulse window data line to V/2
  }
}
