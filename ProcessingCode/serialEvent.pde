//This function will be called when the newline character has been received.
// It reads the messages received in the port (sent from the Arduinos).
void serialEvent(Serial port) {
  if (count<8) { // To avoid wrong readings, some lines are first read.
    print(count);
    count++;
    String inData = port.readStringUntil('\n');
    
  } else {

    try {
      String inData = port.readStringUntil('\n'); //Get the ASCII string received
      inData = trim(inData);                 // cut off white space (carriage return)

      if (inData.charAt(0) == 'S') {           // leading 'S' means Pulse Sensor data packet
        inData = inData.substring(1);        // cut off the leading 'S'
        Sensor = int(inData);                // convert the string to usable int
      }
      if (inData.charAt(0) == 'B') {          // leading 'B' for BPM data
        inData = inData.substring(1);        // cut off the leading 'B'
        BPM = int(inData);                   // convert the string to usable int
        beat = true;                         // set beat flag to advance heart rate graph
        heart = 20;                          // begin heart image 'swell' timer
      }
      if (inData.charAt(0) == 'A') {            // leading 'A' means accelerometer data
        inData = inData.substring(1);        // cut off the leading 'A'
        coordinates = (inData.split("/")); // Save the coordinates.
        x = float(coordinates[0])+0.1; 
        y = float(coordinates[1])+0.1;
        z = float(coordinates[2]);
      }
      if (inData.charAt(0) == 'T') {            // leading 'T' means temperature data
        inData = inData.substring(1);        // cut off the leading 'T'
        temp = inData;
      }
    }
    catch(Exception e) {
      println(e.toString());
    }
  }
}// END OF SERIAL EVENT
